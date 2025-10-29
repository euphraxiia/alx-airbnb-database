-- =====================================================
-- Table Partitioning for Large Datasets
-- Database: airbnb_db
-- Description: Partitioning the bookings table by check_in_date (start_date) for performance optimization
-- =====================================================

USE airbnb_db;

-- =====================================================
-- PARTITIONING STRATEGY
-- =====================================================
-- Strategy: RANGE partitioning by YEAR(check_in_date)
-- Benefits:
--   - Partition pruning for date range queries
--   - Improved query performance on large datasets
--   - Easier data management (archiving old partitions)
--   - Better parallel processing
--
-- Partition Structure:
--   - p2024: Bookings from 2024 and earlier
--   - p2025: Bookings from 2025
--   - p2026: Bookings from 2026
--   - p2027: Bookings from 2027
--   - p_future: Bookings from 2028 and later
-- =====================================================

-- =====================================================
-- Method 1: Create New Partitioned Table (Recommended for Production)
-- =====================================================
-- Use this method when migrating existing data
-- Step 1: Create the partitioned table structure

CREATE TABLE IF NOT EXISTS bookings_partitioned (
    id INT AUTO_INCREMENT,
    property_id INT NOT NULL,
    guest_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id, check_in_date),  -- Partition key must be part of PRIMARY KEY
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_property (property_id),
    INDEX idx_guest (guest_id),
    INDEX idx_dates (check_in_date, check_out_date),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY RANGE (YEAR(check_in_date)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =====================================================
-- Step 2: Migrate Data from Original Table
-- =====================================================
-- Copy data from bookings to bookings_partitioned
-- INSERT INTO bookings_partitioned 
-- SELECT * FROM bookings;

-- =====================================================
-- Step 3: Verify Data Migration
-- =====================================================
-- Check row counts match
-- SELECT 
--     'original' AS source, COUNT(*) AS count FROM bookings
-- UNION ALL
-- SELECT 
--     'partitioned' AS source, COUNT(*) AS count FROM bookings_partitioned;

-- =====================================================
-- Method 2: Partition Existing Table (Alternative - Requires Table Recreation)
-- =====================================================
-- NOTE: This requires dropping and recreating the table
-- Only use in development or when data loss is acceptable
-- 
-- DROP TABLE IF EXISTS bookings_backup;
-- CREATE TABLE bookings_backup AS SELECT * FROM bookings;
-- 
-- ALTER TABLE bookings 
-- PARTITION BY RANGE (YEAR(check_in_date)) (
--     PARTITION p2024 VALUES LESS THAN (2025),
--     PARTITION p2025 VALUES LESS THAN (2026),
--     PARTITION p2026 VALUES LESS THAN (2027),
--     PARTITION p2027 VALUES LESS THAN (2028),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );
--
-- Note: This will fail if bookings table already exists with data
-- because partitioning key (check_in_date) must be part of PRIMARY KEY

-- =====================================================
-- PERFORMANCE TEST QUERIES
-- =====================================================

-- =====================================================
-- Test Query 1: Date Range Query (Should benefit from partition pruning)
-- =====================================================
-- Query bookings within a specific year range
SELECT 
    b.id,
    b.property_id,
    b.guest_id,
    b.check_in_date,
    b.check_out_date,
    b.status,
    b.total_price
FROM bookings_partitioned b
WHERE b.check_in_date >= '2025-01-01'
  AND b.check_in_date < '2026-01-01'
ORDER BY b.check_in_date;

-- EXPLAIN ANALYZE for Test Query 1
-- EXPLAIN ANALYZE
-- SELECT 
--     b.id,
--     b.property_id,
--     b.guest_id,
--     b.check_in_date,
--     b.check_out_date,
--     b.status,
--     b.total_price
-- FROM bookings_partitioned b
-- WHERE b.check_in_date >= '2025-01-01'
--   AND b.check_in_date < '2026-01-01'
-- ORDER BY b.check_in_date;

-- =====================================================
-- Test Query 2: Single Year Query (Maximum partition pruning)
-- =====================================================
-- Query all bookings for a specific year
SELECT 
    COUNT(*) AS booking_count,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_booking_value
FROM bookings_partitioned b
WHERE YEAR(b.check_in_date) = 2025;

-- EXPLAIN ANALYZE for Test Query 2
-- EXPLAIN ANALYZE
-- SELECT 
--     COUNT(*) AS booking_count,
--     SUM(total_price) AS total_revenue,
--     AVG(total_price) AS avg_booking_value
-- FROM bookings_partitioned b
-- WHERE YEAR(b.check_in_date) = 2025;

-- =====================================================
-- Test Query 3: Multi-Year Range Query
-- =====================================================
-- Query bookings across multiple years
SELECT 
    YEAR(b.check_in_date) AS booking_year,
    COUNT(*) AS bookings_count,
    SUM(b.total_price) AS yearly_revenue
FROM bookings_partitioned b
WHERE b.check_in_date >= '2024-01-01'
  AND b.check_in_date < '2027-01-01'
GROUP BY YEAR(b.check_in_date)
ORDER BY booking_year;

-- EXPLAIN ANALYZE for Test Query 3
-- EXPLAIN ANALYZE
-- SELECT 
--     YEAR(b.check_in_date) AS booking_year,
--     COUNT(*) AS bookings_count,
--     SUM(b.total_price) AS yearly_revenue
-- FROM bookings_partitioned b
-- WHERE b.check_in_date >= '2024-01-01'
--   AND b.check_in_date < '2027-01-01'
-- GROUP BY YEAR(b.check_in_date)
-- ORDER BY booking_year;

-- =====================================================
-- Test Query 4: JOIN with Partitioned Table
-- =====================================================
-- Test performance of JOINs with partitioned table
SELECT 
    b.id AS booking_id,
    b.check_in_date,
    b.status,
    u.first_name,
    u.last_name,
    p.title AS property_title
FROM bookings_partitioned b
INNER JOIN users u ON b.guest_id = u.id
INNER JOIN properties p ON b.property_id = p.id
WHERE b.check_in_date >= '2025-07-01'
  AND b.check_in_date < '2025-08-01'
ORDER BY b.check_in_date;

-- EXPLAIN ANALYZE for Test Query 4
-- EXPLAIN ANALYZE
-- SELECT 
--     b.id AS booking_id,
--     b.check_in_date,
--     b.status,
--     u.first_name,
--     u.last_name,
--     p.title AS property_title
-- FROM bookings_partitioned b
-- INNER JOIN users u ON b.guest_id = u.id
-- INNER JOIN properties p ON b.property_id = p.id
-- WHERE b.check_in_date >= '2025-07-01'
--   AND b.check_in_date < '2025-08-01'
-- ORDER BY b.check_in_date;

-- =====================================================
-- PARTITION INFORMATION QUERIES
-- =====================================================

-- View partition information
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'airbnb_db'
  AND TABLE_NAME = 'bookings_partitioned'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_ORDINAL_POSITION;

-- View partition statistics
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS DATA_SIZE_MB,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS INDEX_SIZE_MB
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = 'airbnb_db'
  AND TABLE_NAME = 'bookings_partitioned'
  AND PARTITION_NAME IS NOT NULL;

-- =====================================================
-- PARTITION MAINTENANCE OPERATIONS
-- =====================================================

-- Add a new partition for 2028
-- ALTER TABLE bookings_partitioned
-- REORGANIZE PARTITION p_future INTO (
--     PARTITION p2028 VALUES LESS THAN (2029),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- Drop old partition (e.g., archive data before 2024)
-- ALTER TABLE bookings_partitioned DROP PARTITION p2024;

-- Merge partitions (combine two partitions)
-- ALTER TABLE bookings_partitioned
-- REORGANIZE PARTITION p2024, p2025 INTO (
--     PARTITION p2024_2025 VALUES LESS THAN (2026)
-- );

-- =====================================================
-- COMPARISON QUERIES (Non-Partitioned vs Partitioned)
-- =====================================================

-- Query on non-partitioned table (baseline)
-- SELECT 
--     COUNT(*) AS booking_count
-- FROM bookings b
-- WHERE b.check_in_date >= '2025-01-01'
--   AND b.check_in_date < '2026-01-01';

-- Query on partitioned table (optimized)
-- SELECT 
--     COUNT(*) AS booking_count
-- FROM bookings_partitioned b
-- WHERE b.check_in_date >= '2025-01-01'
--   AND b.check_in_date < '2026-01-01';

-- =====================================================
-- NOTES ON PARTITIONING
-- =====================================================
-- 1. Partition Key Requirements:
--    - Must be part of PRIMARY KEY or UNIQUE KEY
--    - Cannot use AUTO_INCREMENT alone as primary key
--    - Must use composite key: PRIMARY KEY (id, check_in_date)
--
-- 2. Limitations:
--    - Foreign keys referencing partitioned tables have restrictions
--    - Some operations work at partition level, not table level
--    - Full-text indexes have limitations with partitioned tables
--
-- 3. Best Practices:
--    - Choose partition key based on common WHERE clause filters
--    - Keep number of partitions reasonable (avoid > 100 partitions)
--    - Monitor partition sizes and plan for partition maintenance
--    - Use partition pruning in queries (WHERE clause matching partition key)
--
-- 4. Performance Benefits:
--    - Partition pruning: Only scan relevant partitions
--    - Parallel operations: Each partition can be processed separately
--    - Data management: Easy to archive/delete old partitions
--    - Index efficiency: Smaller indexes per partition
-- =====================================================

