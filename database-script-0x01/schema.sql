-- =====================================================
-- Airbnb Database Schema
-- Database: airbnb_db
-- Version: 1.0
-- Description: Complete schema definition for Airbnb-like application
-- =====================================================

-- Drop database if exists (for development/testing)
-- DROP DATABASE IF EXISTS airbnb_db;

-- Create database
CREATE DATABASE IF NOT EXISTS airbnb_db;
USE airbnb_db;

-- =====================================================
-- Table: users
-- Description: Stores user account information
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) DEFAULT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: properties
-- Description: Stores property/listing information
-- =====================================================
CREATE TABLE IF NOT EXISTS properties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255) DEFAULT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) DEFAULT NULL,
    longitude DECIMAL(11, 8) DEFAULT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night >= 0),
    max_guests INT NOT NULL CHECK (max_guests > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_owner (owner_id),
    INDEX idx_location (city, state, country),
    INDEX idx_price (price_per_night),
    INDEX idx_coordinates (latitude, longitude),
    FULLTEXT INDEX idx_search (title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: amenities
-- Description: Stores available amenities (pool, wifi, etc.)
-- =====================================================
CREATE TABLE IF NOT EXISTS amenities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: property_amenities
-- Description: Junction table linking properties to amenities
-- =====================================================
CREATE TABLE IF NOT EXISTS property_amenities (
    property_id INT NOT NULL,
    amenity_id INT NOT NULL,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES amenities(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_amenity (amenity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: property_images
-- Description: Stores images associated with properties
-- =====================================================
CREATE TABLE IF NOT EXISTS property_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_property (property_id),
    INDEX idx_primary (property_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: bookings
-- Description: Stores booking/reservation information
-- =====================================================
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    guest_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_property (property_id),
    INDEX idx_guest (guest_id),
    INDEX idx_dates (check_in_date, check_out_date),
    INDEX idx_status (status),
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: reviews
-- Description: Stores guest reviews for completed bookings
-- =====================================================
CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_rating (rating),
    INDEX idx_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: payments
-- Description: Stores payment information for bookings
-- =====================================================
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    method VARCHAR(50) NOT NULL,
    status ENUM('pending', 'authorized', 'captured', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_ref VARCHAR(255) DEFAULT NULL,
    processed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_booking (booking_id),
    INDEX idx_status (status),
    INDEX idx_transaction (transaction_ref),
    INDEX idx_processed (processed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: messages
-- Description: Stores messages between users regarding bookings
-- =====================================================
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    sender_id INT NOT NULL,
    body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_booking (booking_id),
    INDEX idx_sender (sender_id),
    INDEX idx_sent_at (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Additional Indexes for Query Optimization
-- =====================================================

-- Composite index for searching properties by location and price range
CREATE INDEX idx_property_location_price ON properties(city, state, price_per_night);

-- Composite index for checking booking date conflicts
CREATE INDEX idx_booking_property_dates ON bookings(property_id, check_in_date, check_out_date);

-- Index for user bookings by status and date
CREATE INDEX idx_user_bookings_status ON bookings(guest_id, status, check_in_date);

-- Index for property owner's bookings
CREATE INDEX idx_owner_bookings ON bookings(property_id, status, check_in_date);

-- =====================================================
-- End of Schema Definition
-- =====================================================

