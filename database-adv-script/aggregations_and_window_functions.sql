-- =====================================================
-- SQL Aggregations and Window Functions
-- Database: airbnb_db
-- Description: Queries demonstrating aggregation functions and window functions
-- =====================================================

USE airbnb_db;

-- =====================================================
-- Query 1: Aggregation with COUNT and GROUP BY
-- Find the total number of bookings made by each user
-- =====================================================
SELECT 
    u.id AS user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_price,
    MIN(b.check_in_date) AS first_booking_date,
    MAX(b.check_in_date) AS last_booking_date
FROM users u
LEFT JOIN bookings b ON u.id = b.guest_id
GROUP BY u.id, u.first_name, u.last_name, u.email
ORDER BY total_bookings DESC, u.last_name, u.first_name;

-- =====================================================
-- Alternative Query 1: Using only COUNT and GROUP BY (simpler version)
-- =====================================================
-- SELECT 
--     u.id AS user_id,
--     u.first_name,
--     u.last_name,
--     u.email,
--     COUNT(b.id) AS total_bookings
-- FROM users u
-- LEFT JOIN bookings b ON u.id = b.guest_id
-- GROUP BY u.id, u.first_name, u.last_name, u.email
-- ORDER BY total_bookings DESC;

-- =====================================================
-- Query 2: Window Functions (ROW_NUMBER and RANK)
-- Rank properties based on the total number of bookings they have received
-- =====================================================
SELECT 
    p.id AS property_id,
    p.title,
    p.city,
    p.state,
    p.country,
    p.price_per_night,
    COUNT(b.id) AS total_bookings,
    -- RANK: Assigns the same rank to properties with the same number of bookings
    -- Skips ranks when there are ties (e.g., 1, 2, 2, 4, 5)
    RANK() OVER (ORDER BY COUNT(b.id) DESC) AS booking_rank,
    -- DENSE_RANK: Like RANK but doesn't skip ranks (e.g., 1, 2, 2, 3, 4)
    DENSE_RANK() OVER (ORDER BY COUNT(b.id) DESC) AS booking_dense_rank,
    -- ROW_NUMBER: Assigns unique sequential numbers, even for ties
    -- Breaks ties arbitrarily (e.g., 1, 2, 3, 4, 5)
    ROW_NUMBER() OVER (ORDER BY COUNT(b.id) DESC, p.id ASC) AS booking_row_number
FROM properties p
LEFT JOIN bookings b ON p.id = b.property_id
GROUP BY p.id, p.title, p.city, p.state, p.country, p.price_per_night
ORDER BY total_bookings DESC, p.title;

-- =====================================================
-- Alternative Query 2: Using Window Functions with more details
-- Shows booking revenue and average booking price per property
-- =====================================================
-- SELECT 
--     p.id AS property_id,
--     p.title,
--     p.city,
--     p.price_per_night,
--     COUNT(b.id) AS total_bookings,
--     SUM(b.total_price) AS total_revenue,
--     AVG(b.total_price) AS avg_booking_value,
--     RANK() OVER (ORDER BY COUNT(b.id) DESC) AS booking_count_rank,
--     RANK() OVER (ORDER BY SUM(b.total_price) DESC) AS revenue_rank,
--     ROW_NUMBER() OVER (ORDER BY COUNT(b.id) DESC, p.id ASC) AS row_num
-- FROM properties p
-- LEFT JOIN bookings b ON p.id = b.property_id
-- GROUP BY p.id, p.title, p.city, p.price_per_night
-- ORDER BY total_bookings DESC;

-- =====================================================
-- Additional Examples: Window Functions
-- =====================================================

-- Example: Rank users by total bookings using window function
-- SELECT 
--     u.id,
--     u.first_name,
--     u.last_name,
--     COUNT(b.id) AS booking_count,
--     RANK() OVER (ORDER BY COUNT(b.id) DESC) AS user_rank
-- FROM users u
-- LEFT JOIN bookings b ON u.id = b.guest_id
-- GROUP BY u.id, u.first_name, u.last_name;

-- Example: Partitioned window function - Rank bookings within each property
-- SELECT 
--     b.id AS booking_id,
--     b.property_id,
--     p.title AS property_title,
--     b.check_in_date,
--     b.total_price,
--     ROW_NUMBER() OVER (PARTITION BY b.property_id ORDER BY b.check_in_date) AS booking_seq_number,
--     RANK() OVER (PARTITION BY b.property_id ORDER BY b.total_price DESC) AS price_rank_in_property
-- FROM bookings b
-- INNER JOIN properties p ON b.property_id = p.id
-- ORDER BY b.property_id, b.check_in_date;

-- =====================================================
