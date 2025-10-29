-- =====================================================
-- Complex SQL Queries with Joins
-- Database: airbnb_db
-- Description: Queries demonstrating INNER JOIN, LEFT JOIN, and FULL OUTER JOIN
-- =====================================================

USE airbnb_db;

-- =====================================================
-- Query 1: INNER JOIN
-- Retrieve all bookings and the respective users who made those bookings
-- =====================================================
SELECT 
    b.id AS booking_id,
    b.property_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number
FROM bookings b
INNER JOIN users u ON b.guest_id = u.id
ORDER BY b.created_at DESC;

-- =====================================================
-- Query 2: LEFT JOIN
-- Retrieve all properties and their reviews, including properties that have no reviews
-- =====================================================
SELECT 
    p.id AS property_id,
    p.title,
    p.address_line1,
    p.city,
    p.state,
    p.country,
    p.price_per_night,
    b.id AS booking_id,
    r.id AS review_id,
    r.rating,
    r.comment AS review_comment,
    r.created_at AS review_created_at
FROM properties p
LEFT JOIN bookings b ON p.id = b.property_id
LEFT JOIN reviews r ON b.id = r.booking_id
ORDER BY p.id, r.created_at DESC;

-- =====================================================
-- Query 3: FULL OUTER JOIN (Simulated)
-- Retrieve all users and all bookings, even if the user has no booking 
-- or a booking is not linked to a user
-- Note: MySQL doesn't support FULL OUTER JOIN, so we simulate it using UNION
-- =====================================================
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.id AS booking_id,
    b.property_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price,
    b.status AS booking_status
FROM users u
LEFT JOIN bookings b ON u.id = b.guest_id

UNION

SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    b.id AS booking_id,
    b.property_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price,
    b.status AS booking_status
FROM bookings b
LEFT JOIN users u ON b.guest_id = u.id
WHERE u.id IS NULL

ORDER BY user_id, booking_id;

-- =====================================================
-- Alternative Query 3 (if you want to see NULLs more clearly)
-- This version helps identify orphaned bookings (bookings without valid users)
-- =====================================================
-- SELECT 
--     COALESCE(u.id, NULL) AS user_id,
--     COALESCE(u.first_name, 'N/A') AS first_name,
--     COALESCE(u.last_name, 'N/A') AS last_name,
--     COALESCE(u.email, 'No User') AS email,
--     b.id AS booking_id,
--     b.property_id,
--     b.check_in_date,
--     b.check_out_date,
--     b.total_price,
--     b.status AS booking_status,
--     CASE 
--         WHEN u.id IS NULL THEN 'Orphaned Booking'
--         WHEN b.id IS NULL THEN 'User with No Bookings'
--         ELSE 'Normal Booking'
--     END AS record_type
-- FROM users u
-- LEFT JOIN bookings b ON u.id = b.guest_id
-- 
-- UNION
-- 
-- SELECT 
--     u.id AS user_id,
--     u.first_name,
--     u.last_name,
--     u.email,
--     b.id AS booking_id,
--     b.property_id,
--     b.check_in_date,
--     b.check_out_date,
--     b.total_price,
--     b.status AS booking_status,
--     'Orphaned Booking' AS record_type
-- FROM bookings b
-- LEFT JOIN users u ON b.guest_id = u.id
-- WHERE u.id IS NULL
-- 
-- ORDER BY record_type, user_id, booking_id;
-- =====================================================
