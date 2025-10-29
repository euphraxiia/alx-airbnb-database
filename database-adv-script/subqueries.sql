-- =====================================================
-- SQL Subqueries (Correlated and Non-Correlated)
-- Database: airbnb_db
-- Description: Queries demonstrating subquery techniques
-- =====================================================

USE airbnb_db;

-- =====================================================
-- Query 1: Non-Correlated Subquery
-- Find all properties where the average rating is greater than 4.0
-- =====================================================
SELECT 
    p.id AS property_id,
    p.title,
    p.address_line1,
    p.city,
    p.state,
    p.country,
    p.price_per_night,
    p.max_guests,
    subquery.avg_rating,
    subquery.review_count
FROM properties p
INNER JOIN (
    -- Subquery: Calculate average rating per property
    SELECT 
        b.property_id,
        AVG(r.rating) AS avg_rating,
        COUNT(r.id) AS review_count
    FROM reviews r
    INNER JOIN bookings b ON r.booking_id = b.id
    GROUP BY b.property_id
    HAVING AVG(r.rating) > 4.0
) AS subquery ON p.id = subquery.property_id
ORDER BY subquery.avg_rating DESC, p.title;

-- =====================================================
-- Alternative Query 1: Using WHERE IN (simpler approach)
-- =====================================================
-- SELECT 
--     p.id AS property_id,
--     p.title,
--     p.address_line1,
--     p.city,
--     p.state,
--     p.country,
--     p.price_per_night,
--     p.max_guests
-- FROM properties p
-- WHERE p.id IN (
--     SELECT b.property_id
--     FROM reviews r
--     INNER JOIN bookings b ON r.booking_id = b.id
--     GROUP BY b.property_id
--     HAVING AVG(r.rating) > 4.0
-- )
-- ORDER BY p.title;

-- =====================================================
-- Query 2: Correlated Subquery
-- Find users who have made more than 3 bookings
-- =====================================================
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    (SELECT COUNT(*) 
     FROM bookings b 
     WHERE b.guest_id = u.id) AS booking_count,
    u.created_at AS user_since
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM bookings b 
    WHERE b.guest_id = u.id
) > 3
ORDER BY booking_count DESC, u.last_name, u.first_name;

-- =====================================================
-- Alternative Query 2: Using EXISTS with correlated subquery
-- =====================================================
-- SELECT 
--     u.id AS user_id,
--     u.first_name,
--     u.last_name,
--     u.email,
--     u.phone_number,
--     (SELECT COUNT(*) 
--      FROM bookings b 
--      WHERE b.guest_id = u.id) AS booking_count,
--     u.created_at AS user_since
-- FROM users u
-- WHERE EXISTS (
--     SELECT 1
--     FROM bookings b
--     WHERE b.guest_id = u.id
--     HAVING COUNT(*) > 3
-- )
-- ORDER BY booking_count DESC, u.last_name, u.first_name;

-- =====================================================
-- Additional Examples for Learning
-- =====================================================

-- Example: Scalar subquery in SELECT clause
-- Get properties with their average rating (including those with no reviews)
-- SELECT 
--     p.id,
--     p.title,
--     p.city,
--     COALESCE(
--         (SELECT AVG(r.rating)
--          FROM reviews r
--          INNER JOIN bookings b ON r.booking_id = b.id
--          WHERE b.property_id = p.id),
--         0
--     ) AS avg_rating
-- FROM properties p
-- ORDER BY avg_rating DESC;

-- =====================================================
