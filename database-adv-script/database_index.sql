-- =====================================================
-- Database Index Optimization
-- Database: airbnb_db
-- Description: Additional indexes to improve query performance
-- Based on analysis of high-usage columns in WHERE, JOIN, and ORDER BY clauses
-- =====================================================

USE airbnb_db;

-- =====================================================
-- Measure Performance BEFORE Adding Indexes
-- =====================================================
-- Tip: Run these EXPLAIN ANALYZE statements BEFORE the CREATE INDEX section
-- to capture baseline performance. Requires MySQL 8.0.18+.

-- 1) Bookings ordered by created_at (used in joins_queries.sql)
EXPLAIN ANALYZE
SELECT 
    b.id, b.property_id, b.guest_id, b.created_at
FROM bookings b
ORDER BY b.created_at DESC
LIMIT 20;

-- 2) User bookings with JOIN and ORDER BY (joins_queries.sql)
EXPLAIN ANALYZE
SELECT 
    b.id, b.created_at, u.id AS user_id
FROM bookings b
INNER JOIN users u ON b.guest_id = u.id
ORDER BY b.created_at DESC
LIMIT 20;

-- 3) Properties filtered by location and price (common search)
EXPLAIN ANALYZE
SELECT 
    p.id, p.city, p.state, p.price_per_night
FROM properties p
WHERE p.city = 'San Francisco'
  AND p.state = 'CA'
  AND p.price_per_night <= 250
ORDER BY p.price_per_night;

-- 4) Aggregation: bookings per user (aggregations_and_window_functions.sql)
EXPLAIN ANALYZE
SELECT 
    u.id,
    COUNT(b.id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.id = b.guest_id
GROUP BY u.id
ORDER BY total_bookings DESC
LIMIT 20;

-- =====================================================
-- Analysis Summary
-- =====================================================
-- High-usage columns identified from query patterns:
--
-- USERS table:
--   - id (PK, already indexed) ✓
--   - email (already indexed) ✓
--   - first_name, last_name (used in ORDER BY, searches)
--   - created_at (used in ORDER BY, filtering)
--
-- BOOKINGS table:
--   - id (PK, already indexed) ✓
--   - guest_id (already indexed) ✓
--   - property_id (already indexed) ✓
--   - status (already indexed) ✓
--   - check_in_date, check_out_date (already indexed) ✓
--   - created_at (used in ORDER BY, date range queries)
--   - total_price (used in aggregations, sorting)
--
-- PROPERTIES table:
--   - id (PK, already indexed) ✓
--   - owner_id (already indexed) ✓
--   - city, state, country (already indexed) ✓
--   - price_per_night (already indexed) ✓
--   - created_at (used in ORDER BY, date filtering)
--   - max_guests (used in WHERE clauses for filtering)
--
-- REVIEWS table:
--   - booking_id (already indexed) ✓
--   - rating (already indexed) ✓
--   - created_at (used in ORDER BY)
--
-- =====================================================
-- Additional Recommended Indexes
-- =====================================================

-- =====================================================
-- USERS Table Indexes
-- =====================================================

-- Index for sorting and searching by user name
-- Used in ORDER BY clauses: ORDER BY u.last_name, u.first_name
-- Also useful for name-based searches
CREATE INDEX IF NOT EXISTS idx_users_name ON users(last_name, first_name);

-- Index for filtering and sorting by creation date
-- Useful for finding new users, user analytics
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Composite index for common user search patterns (name + email lookup)
-- Useful when searching by name and filtering by date
CREATE INDEX IF NOT EXISTS idx_users_name_created ON users(last_name, first_name, created_at);

-- =====================================================
-- BOOKINGS Table Indexes
-- =====================================================

-- Index for sorting by creation date (most common ORDER BY)
-- Used in: ORDER BY b.created_at DESC
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at);

-- Index for sorting and filtering by total price
-- Used in aggregations and sorting by booking value
CREATE INDEX IF NOT EXISTS idx_bookings_total_price ON bookings(total_price);

-- Composite index for guest bookings ordered by date
-- Optimizes queries: SELECT * FROM bookings WHERE guest_id = ? ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_bookings_guest_created ON bookings(guest_id, created_at DESC);

-- Composite index for property bookings ordered by date
-- Optimizes queries: SELECT * FROM bookings WHERE property_id = ? ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_bookings_property_created ON bookings(property_id, created_at DESC);

-- Composite index for status-based queries with date filtering
-- Common pattern: WHERE status = 'confirmed' AND created_at > ?
CREATE INDEX IF NOT EXISTS idx_bookings_status_created ON bookings(status, created_at);

-- Composite index for date range queries with status
-- Used in: WHERE check_in_date BETWEEN ? AND ? AND status = ?
CREATE INDEX IF NOT EXISTS idx_bookings_dates_status ON bookings(check_in_date, check_out_date, status);

-- =====================================================
-- PROPERTIES Table Indexes
-- =====================================================

-- Index for sorting by creation date
-- Used in: ORDER BY p.created_at DESC (newest listings first)
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON properties(created_at);

-- Index for filtering by maximum guests
-- Common query: WHERE max_guests >= ? (search filters)
CREATE INDEX IF NOT EXISTS idx_properties_max_guests ON properties(max_guests);

-- Composite index for price-based searches
-- Useful for: WHERE price_per_night BETWEEN ? AND ? ORDER BY price_per_night
CREATE INDEX IF NOT EXISTS idx_properties_price_created ON properties(price_per_night, created_at);

-- Note: idx_properties_location_price already exists in schema (city, state, price_per_night)
-- Skipping to avoid duplicate

-- Composite index for owner's properties with creation date
-- Optimizes: SELECT * FROM properties WHERE owner_id = ? ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_properties_owner_created ON properties(owner_id, created_at DESC);

-- =====================================================
-- REVIEWS Table Indexes
-- =====================================================

-- Index for sorting reviews by creation date
-- Used in: ORDER BY r.created_at DESC (newest reviews first)
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at);

-- Composite index for rating-based queries
-- Common: WHERE rating >= ? ORDER BY created_at DESC
CREATE INDEX IF NOT EXISTS idx_reviews_rating_created ON reviews(rating, created_at DESC);

-- =====================================================
-- Additional Composite Indexes for Complex Queries
-- =====================================================

-- For property reviews aggregation queries
-- Optimizes: JOIN reviews -> bookings -> properties grouped by property_id
CREATE INDEX IF NOT EXISTS idx_bookings_property_status ON bookings(property_id, status);

-- For user booking aggregation queries
-- Optimizes aggregations like: COUNT, SUM grouped by guest_id
CREATE INDEX IF NOT EXISTS idx_bookings_guest_status_price ON bookings(guest_id, status, total_price);

-- =====================================================
-- Performance Monitoring Optimizations
-- =====================================================
-- Indexes identified through EXPLAIN ANALYZE and SHOW PROFILE analysis

-- Covering index for user booking aggregations
-- Optimizes: SELECT COUNT(b.id), SUM(b.total_price), AVG(b.total_price), MIN/MAX(check_in_date)
--            WHERE guest_id = ? GROUP BY guest_id
CREATE INDEX IF NOT EXISTS idx_bookings_guest_agg ON bookings(guest_id, total_price, check_in_date);

-- Composite index for property bookings with date filtering
-- Optimizes: Property booking queries with date ranges
CREATE INDEX IF NOT EXISTS idx_properties_bookings_dates ON bookings(property_id, check_in_date, check_out_date);

-- Note: idx_bookings_created_at already exists above
-- Note: idx_reviews_created_at already exists above  
-- Note: idx_users_name already exists above

-- =====================================================
-- Measure Performance AFTER Adding Indexes
-- =====================================================
-- Run the same statements again to compare with the baseline.

-- 1) Bookings ordered by created_at (should avoid filesort with index)
EXPLAIN ANALYZE
SELECT 
    b.id, b.property_id, b.guest_id, b.created_at
FROM bookings b
ORDER BY b.created_at DESC
LIMIT 20;

-- 2) User bookings with JOIN and ORDER BY
EXPLAIN ANALYZE
SELECT 
    b.id, b.created_at, u.id AS user_id
FROM bookings b
INNER JOIN users u ON b.guest_id = u.id
ORDER BY b.created_at DESC
LIMIT 20;

-- 3) Properties filtered by location and price
EXPLAIN ANALYZE
SELECT 
    p.id, p.city, p.state, p.price_per_night
FROM properties p
WHERE p.city = 'San Francisco'
  AND p.state = 'CA'
  AND p.price_per_night <= 250
ORDER BY p.price_per_night;

-- 4) Aggregation: bookings per user
EXPLAIN ANALYZE
SELECT 
    u.id,
    COUNT(b.id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON u.id = b.guest_id
GROUP BY u.id
ORDER BY total_bookings DESC
LIMIT 20;

-- =====================================================
-- Note on Existing Indexes
-- =====================================================
-- The schema already includes many well-designed indexes:
--   - Foreign key indexes (automatically created or explicitly defined)
--   - Composite indexes for common query patterns
--   - Full-text indexes for search functionality
--
-- These additional indexes complement the existing ones and target
-- specific query patterns identified in actual queries (joins_queries.sql,
-- subqueries.sql, aggregations_and_window_functions.sql)

-- =====================================================
-- Index Maintenance
-- =====================================================
-- To view all indexes on a table:
--   SHOW INDEX FROM table_name;
--
-- To analyze index usage:
--   EXPLAIN SELECT ... FROM table_name WHERE ...;
--
-- To drop an index (if needed):
--   DROP INDEX index_name ON table_name;

-- =====================================================
-- End of Index Definitions
-- =====================================================

