-- =====================================================
-- Airbnb Database Seed Data
-- Database: airbnb_db
-- Version: 1.0
-- Description: Inserts realistic sample data for development/testing
-- =====================================================

-- Ensure the correct database is selected
USE airbnb_db;

-- Optional: Clear existing data (keep referential integrity ordering)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE messages;
TRUNCATE TABLE payments;
TRUNCATE TABLE reviews;
TRUNCATE TABLE bookings;
TRUNCATE TABLE property_images;
TRUNCATE TABLE property_amenities;
TRUNCATE TABLE amenities;
TRUNCATE TABLE properties;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- Users
-- =====================================================
INSERT INTO users (id, first_name, last_name, email, phone_number, password_hash, created_at, updated_at) VALUES
    (1, 'Alice', 'Johnson', 'alice@example.com', '+1234567890', '$2b$10$alicehash', NOW(), NOW()),
    (2, 'Bob', 'Smith', 'bob@example.com', '+1987654321', '$2b$10$bobhashxx', NOW(), NOW()),
    (3, 'Charlie', 'Lee', 'charlie@example.com', NULL, '$2b$10$charlieyy', NOW(), NOW());

-- =====================================================
-- Properties
-- =====================================================
INSERT INTO properties (
    id, owner_id, title, description, address_line1, address_line2,
    city, state, postal_code, country, latitude, longitude,
    price_per_night, max_guests, created_at, updated_at
) VALUES
    (1, 1, 'Sunny Beach House', 'Oceanfront home with stunning views', '123 Ocean Ave', NULL,
     'Santa Monica', 'CA', '90401', 'USA', 34.0195, -118.4912, 350.00, 6, NOW(), NOW()),
    (2, 1, 'Cozy Downtown Loft', 'Modern loft near restaurants and nightlife', '45 Market St', 'Apt 5B',
     'San Francisco', 'CA', '94105', 'USA', 37.7890, -122.4010, 220.00, 3, NOW(), NOW()),
    (3, 2, 'Mountain Cabin Retreat', 'Secluded cabin with hot tub', '78 Pine Ridge Rd', NULL,
     'Aspen', 'CO', '81611', 'USA', 39.1911, -106.8175, 275.00, 5, NOW(), NOW()),
    (4, 3, 'Charming Paris Studio', 'Quaint studio near the Seine', '10 Rue de Rivoli', NULL,
     'Paris', 'Île-de-France', '75004', 'France', 48.8556, 2.3570, 140.00, 2, NOW(), NOW());

-- =====================================================
-- Amenities
-- =====================================================
INSERT INTO amenities (id, name, created_at, updated_at) VALUES
    (1, 'WiFi', NOW(), NOW()),
    (2, 'Air Conditioning', NOW(), NOW()),
    (3, 'Heating', NOW(), NOW()),
    (4, 'Kitchen', NOW(), NOW()),
    (5, 'Washer', NOW(), NOW()),
    (6, 'Dryer', NOW(), NOW()),
    (7, 'Free Parking', NOW(), NOW()),
    (8, 'Hot Tub', NOW(), NOW()),
    (9, 'Pool', NOW(), NOW()),
    (10, 'Pets Allowed', NOW(), NOW());

-- =====================================================
-- Property Amenities (junction)
-- =====================================================
INSERT INTO property_amenities (property_id, amenity_id) VALUES
    (1, 1), (1, 2), (1, 4), (1, 7), (1, 9),
    (2, 1), (2, 3), (2, 4), (2, 5),
    (3, 1), (3, 3), (3, 4), (3, 8), (3, 7),
    (4, 1), (4, 3), (4, 4), (4, 5);

-- =====================================================
-- Property Images
-- =====================================================
INSERT INTO property_images (id, property_id, image_url, is_primary, sort_order, created_at, updated_at) VALUES
    (1, 1, 'https://example.com/images/prop1_main.jpg', TRUE, 1, NOW(), NOW()),
    (2, 1, 'https://example.com/images/prop1_view.jpg', FALSE, 2, NOW(), NOW()),
    (3, 2, 'https://example.com/images/prop2_main.jpg', TRUE, 1, NOW(), NOW()),
    (4, 3, 'https://example.com/images/prop3_main.jpg', TRUE, 1, NOW(), NOW()),
    (5, 3, 'https://example.com/images/prop3_hot_tub.jpg', FALSE, 2, NOW(), NOW()),
    (6, 4, 'https://example.com/images/prop4_main.jpg', TRUE, 1, NOW(), NOW());

-- =====================================================
-- Bookings
-- =====================================================
INSERT INTO bookings (
    id, property_id, guest_id, check_in_date, check_out_date,
    total_price, status, created_at, updated_at
) VALUES
    (1, 1, 2, '2025-07-01', '2025-07-05', 1400.00, 'completed', NOW(), NOW()),
    (2, 2, 3, '2025-08-10', '2025-08-12', 440.00, 'confirmed', NOW(), NOW()),
    (3, 3, 1, '2025-09-15', '2025-09-20', 1375.00, 'pending', NOW(), NOW()),
    (4, 4, 1, '2025-10-05', '2025-10-08', 420.00, 'cancelled', NOW(), NOW());

-- =====================================================
-- Reviews (one per booking)
-- Only for completed bookings (id=1)
-- =====================================================
INSERT INTO reviews (id, booking_id, rating, comment, created_at, updated_at) VALUES
    (1, 1, 5, 'Amazing stay! Beautiful views and great host.', NOW(), NOW());

-- =====================================================
-- Payments (one per booking)
-- Completed and confirmed bookings typically have payments
-- =====================================================
INSERT INTO payments (
    id, booking_id, amount, currency, method, status,
    transaction_ref, processed_at, created_at, updated_at
) VALUES
    (1, 1, 1400.00, 'USD', 'card', 'captured', 'TXN-20250701-ALICE-0001', '2025-07-01 10:00:00', NOW(), NOW()),
    (2, 2, 440.00, 'USD', 'card', 'authorized', 'TXN-20250810-BOB-0002', '2025-08-10 09:30:00', NOW(), NOW());

-- =====================================================
-- Messages (between users regarding bookings)
-- =====================================================
INSERT INTO messages (id, booking_id, sender_id, body, sent_at) VALUES
    (1, 1, 2, 'Hi, what time is check-in?', '2025-06-25 14:00:00'),
    (2, 1, 1, 'Check-in is after 3 PM. Looking forward to hosting you!', '2025-06-25 14:10:00'),
    (3, 2, 3, 'Can I get early check-in?', '2025-08-05 09:00:00'),
    (4, 2, 1, 'Early check-in at 1 PM is fine.', '2025-08-05 09:15:00');

-- =====================================================
-- Done
-- =====================================================
