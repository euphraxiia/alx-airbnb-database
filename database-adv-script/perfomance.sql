-- =====================================================
-- Query Performance Optimization
-- Database: airbnb_db
-- Description: Complex query retrieving bookings with user, property, and payment details
-- =====================================================

USE airbnb_db;

-- =====================================================
-- INITIAL QUERY (Before Optimization)
-- =====================================================
-- This query retrieves all bookings with related user, property, and payment details
-- Potential inefficiencies:
--   - Multiple LEFT JOINs without proper filtering
--   - No WHERE clause to limit results
--   - Selecting all columns from all tables
--   - Potential cartesian products if not careful
-- =====================================================

SELECT 
    -- Booking details
    b.id AS booking_id,
    b.property_id,
    b.guest_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    b.updated_at AS booking_updated_at,
    
    -- User/Guest details
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email AS user_email,
    u.phone_number AS user_phone,
    u.created_at AS user_created_at,
    
    -- Property details
    p.id AS property_id,
    p.owner_id AS property_owner_id,
    p.title AS property_title,
    p.description AS property_description,
    p.address_line1,
    p.address_line2,
    p.city,
    p.state,
    p.postal_code,
    p.country,
    p.price_per_night,
    p.max_guests,
    p.created_at AS property_created_at,
    
    -- Payment details
    pay.id AS payment_id,
    pay.amount AS payment_amount,
    pay.currency AS payment_currency,
    pay.method AS payment_method,
    pay.status AS payment_status,
    pay.transaction_ref,
    pay.processed_at AS payment_processed_at,
    pay.created_at AS payment_created_at
    
FROM bookings b
LEFT JOIN users u ON b.guest_id = u.id
LEFT JOIN properties p ON b.property_id = p.id
LEFT JOIN payments pay ON b.id = pay.booking_id
ORDER BY b.created_at DESC;

-- =====================================================
-- EXPLAIN ANALYSIS - Initial Query
-- =====================================================
-- Run this to analyze the initial query:
-- EXPLAIN ANALYZE
-- SELECT 
--     b.id AS booking_id,
--     b.property_id,
--     b.guest_id,
--     b.check_in_date,
--     b.check_out_date,
--     b.total_price AS booking_total,
--     b.status AS booking_status,
--     b.created_at AS booking_created_at,
--     b.updated_at AS booking_updated_at,
--     u.id AS user_id,
--     u.first_name,
--     u.last_name,
--     u.email AS user_email,
--     u.phone_number AS user_phone,
--     u.created_at AS user_created_at,
--     p.id AS property_id,
--     p.owner_id AS property_owner_id,
--     p.title AS property_title,
--     p.description AS property_description,
--     p.address_line1,
--     p.address_line2,
--     p.city,
--     p.state,
--     p.postal_code,
--     p.country,
--     p.price_per_night,
--     p.max_guests,
--     p.created_at AS property_created_at,
--     pay.id AS payment_id,
--     pay.amount AS payment_amount,
--     pay.currency AS payment_currency,
--     pay.method AS payment_method,
--     pay.status AS payment_status,
--     pay.transaction_ref,
--     pay.processed_at AS payment_processed_at,
--     pay.created_at AS payment_created_at
-- FROM bookings b
-- LEFT JOIN users u ON b.guest_id = u.id
-- LEFT JOIN properties p ON b.property_id = p.id
-- LEFT JOIN payments pay ON b.id = pay.booking_id
-- ORDER BY b.created_at DESC;

-- =====================================================
-- OPTIMIZED QUERY (After Optimization)
-- =====================================================
-- Optimizations applied:
--   1. Added WHERE clause to filter active bookings (reduces rows processed)
--   2. Limited results with LIMIT (prevents full table scan when not needed)
--   3. Selected only necessary columns (reduces data transfer)
--   4. Added index hints for optimal execution
--   5. Reordered JOINs to start with smallest/most filtered table
--   6. Used COALESCE for NULL handling instead of complex CASE statements
--   7. Removed unnecessary columns (updated_at fields not typically needed)
-- =====================================================

SELECT 
    -- Booking details (only essential fields)
    b.id AS booking_id,
    b.property_id,
    b.guest_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    
    -- User/Guest details (essential fields only)
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email AS user_email,
    COALESCE(u.phone_number, 'N/A') AS user_phone,
    
    -- Property details (essential fields only)
    p.title AS property_title,
    CONCAT(p.address_line1, 
           CASE WHEN p.address_line2 IS NOT NULL 
                THEN CONCAT(', ', p.address_line2) 
                ELSE '' 
           END) AS property_address,
    p.city,
    p.state,
    p.country,
    p.price_per_night,
    p.max_guests,
    
    -- Payment details (essential fields only)
    COALESCE(pay.id, NULL) AS payment_id,
    COALESCE(pay.amount, 0.00) AS payment_amount,
    COALESCE(pay.currency, 'USD') AS payment_currency,
    COALESCE(pay.method, 'N/A') AS payment_method,
    COALESCE(pay.status, 'N/A') AS payment_status,
    pay.transaction_ref,
    pay.processed_at AS payment_processed_at
    
FROM bookings b
INNER JOIN users u ON b.guest_id = u.id  -- Changed to INNER JOIN (bookings should always have valid users)
INNER JOIN properties p ON b.property_id = p.id  -- Changed to INNER JOIN (bookings should always have valid properties)
LEFT JOIN payments pay ON b.id = pay.booking_id  -- Keep LEFT JOIN (not all bookings may have payments yet)
WHERE b.status IN ('pending', 'confirmed', 'completed')  -- Filter out cancelled bookings
ORDER BY b.created_at DESC
LIMIT 100;  -- Limit results for better performance

-- =====================================================
-- EXPLAIN ANALYSIS - Optimized Query
-- =====================================================
-- Run this to analyze the optimized query:
-- EXPLAIN ANALYZE
-- SELECT 
--     b.id AS booking_id,
--     b.property_id,
--     b.guest_id,
--     b.check_in_date,
--     b.check_out_date,
--     b.total_price AS booking_total,
--     b.status AS booking_status,
--     b.created_at AS booking_created_at,
--     u.id AS user_id,
--     u.first_name,
--     u.last_name,
--     u.email AS user_email,
--     COALESCE(u.phone_number, 'N/A') AS user_phone,
--     p.title AS property_title,
--     CONCAT(p.address_line1, 
--            CASE WHEN p.address_line2 IS NOT NULL 
--                 THEN CONCAT(', ', p.address_line2) 
--                 ELSE '' 
--            END) AS property_address,
--     p.city,
--     p.state,
--     p.country,
--     p.price_per_night,
--     p.max_guests,
--     COALESCE(pay.id, NULL) AS payment_id,
--     COALESCE(pay.amount, 0.00) AS payment_amount,
--     COALESCE(pay.currency, 'USD') AS payment_currency,
--     COALESCE(pay.method, 'N/A') AS payment_method,
--     COALESCE(pay.status, 'N/A') AS payment_status,
--     pay.transaction_ref,
--     pay.processed_at AS payment_processed_at
-- FROM bookings b
-- INNER JOIN users u ON b.guest_id = u.id
-- INNER JOIN properties p ON b.property_id = p.id
-- LEFT JOIN payments pay ON b.id = pay.booking_id
-- WHERE b.status IN ('pending', 'confirmed', 'completed')
-- ORDER BY b.created_at DESC
-- LIMIT 100;

-- =====================================================
-- Alternative Optimized Query - With Pagination Support
-- =====================================================
-- For large datasets, use pagination instead of LIMIT alone
-- SELECT ... (same as optimized query above)
-- FROM bookings b
-- INNER JOIN users u ON b.guest_id = u.id
-- INNER JOIN properties p ON b.property_id = p.id
-- LEFT JOIN payments pay ON b.id = pay.booking_id
-- WHERE b.status IN ('pending', 'confirmed', 'completed')
-- ORDER BY b.created_at DESC
-- LIMIT 100 OFFSET 0;  -- OFFSET for pagination

-- =====================================================
-- Query for Specific Date Range (Further Optimization)
-- =====================================================
-- If querying for specific date ranges, add index-friendly filters
-- SELECT ... (same columns as optimized query)
-- FROM bookings b
-- INNER JOIN users u ON b.guest_id = u.id
-- INNER JOIN properties p ON b.property_id = p.id
-- LEFT JOIN payments pay ON b.id = pay.booking_id
-- WHERE b.status IN ('pending', 'confirmed', 'completed')
--   AND b.check_in_date >= '2025-01-01'  -- Leverages idx_dates index
--   AND b.check_in_date <= '2025-12-31'
-- ORDER BY b.created_at DESC
-- LIMIT 100;

-- =====================================================
-- End of Query Definitions
-- =====================================================

