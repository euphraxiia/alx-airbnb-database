# Database Schema Documentation

## Overview

This directory contains the SQL Data Definition Language (DDL) scripts for creating the Airbnb database schema. The schema is designed following Third Normal Form (3NF) principles and includes comprehensive constraints, foreign keys, and indexes for optimal performance.

## Files

- `schema.sql`: Complete database schema with CREATE TABLE statements, constraints, and indexes

## Database Information

- **Database Name**: `airbnb_db`
- **Engine**: InnoDB
- **Character Set**: utf8mb4
- **Collation**: utf8mb4_unicode_ci

## Schema Structure

### Tables Overview

The database consists of 9 tables organized into the following logical groups:

#### Core Entities
1. **users** - User accounts (owners and guests)
2. **properties** - Property listings
3. **bookings** - Reservations/bookings
4. **amenities** - Available amenities master list
5. **reviews** - Guest reviews for bookings
6. **payments** - Payment transactions
7. **messages** - Messages between users regarding bookings

#### Supporting Tables
8. **property_amenities** - Junction table (many-to-many: properties ↔ amenities)
9. **property_images** - Property photos/images

## Table Definitions

### 1. users

Stores user account information for both property owners and guests.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| first_name | VARCHAR(100) | NOT NULL | User's first name |
| last_name | VARCHAR(100) | NOT NULL | User's last name |
| email | VARCHAR(255) | NOT NULL, UNIQUE | User's email address |
| phone_number | VARCHAR(20) | NULL | Contact phone number |
| password_hash | VARCHAR(255) | NOT NULL | Hashed password |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes**: `email`, `phone_number`

---

### 2. properties

Stores property/listing information including location, pricing, and capacity.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique property identifier |
| owner_id | INT | NOT NULL, FK → users.id | Property owner |
| title | VARCHAR(255) | NOT NULL | Property title |
| description | TEXT | NULL | Property description |
| address_line1 | VARCHAR(255) | NOT NULL | Street address line 1 |
| address_line2 | VARCHAR(255) | NULL | Street address line 2 |
| city | VARCHAR(100) | NOT NULL | City |
| state | VARCHAR(100) | NOT NULL | State/province |
| postal_code | VARCHAR(20) | NOT NULL | Postal/ZIP code |
| country | VARCHAR(100) | NOT NULL | Country |
| latitude | DECIMAL(10,8) | NULL | Latitude coordinate |
| longitude | DECIMAL(11,8) | NULL | Longitude coordinate |
| price_per_night | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Price per night |
| max_guests | INT | NOT NULL, CHECK > 0 | Maximum guest capacity |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes**: 
- `owner_id` (FK)
- `(city, state, country)` - Location search
- `price_per_night` - Price filtering
- `(latitude, longitude)` - Geographic queries
- FULLTEXT on `(title, description)` - Search functionality

---

### 3. amenities

Master list of available amenities (e.g., WiFi, Pool, Parking).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique amenity identifier |
| name | VARCHAR(100) | NOT NULL, UNIQUE | Amenity name |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes**: `name`

---

### 4. property_amenities

Junction table for many-to-many relationship between properties and amenities.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| property_id | INT | PRIMARY KEY, FK → properties.id | Property reference |
| amenity_id | INT | PRIMARY KEY, FK → amenities.id | Amenity reference |

**Indexes**: 
- Composite PRIMARY KEY: `(property_id, amenity_id)`
- `amenity_id` - Reverse lookup

---

### 5. property_images

Stores images/photos associated with properties.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique image identifier |
| property_id | INT | NOT NULL, FK → properties.id | Property reference |
| image_url | VARCHAR(500) | NOT NULL | Image URL/path |
| is_primary | BOOLEAN | DEFAULT FALSE | Primary image flag |
| sort_order | INT | NULL | Display order |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Upload timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Indexes**: 
- `property_id` (FK)
- `(property_id, is_primary)` - Primary image lookup

---

### 6. bookings

Stores booking/reservation information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique booking identifier |
| property_id | INT | NOT NULL, FK → properties.id | Booked property |
| guest_id | INT | NOT NULL, FK → users.id | Guest user |
| check_in_date | DATE | NOT NULL | Check-in date |
| check_out_date | DATE | NOT NULL | Check-out date |
| total_price | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Total booking price |
| status | ENUM | NOT NULL, DEFAULT 'pending' | Booking status |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Booking creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Status Values**: `pending`, `confirmed`, `cancelled`, `completed`

**Constraints**: 
- CHECK: `check_out_date > check_in_date`

**Indexes**: 
- `property_id` (FK)
- `guest_id` (FK)
- `(check_in_date, check_out_date)` - Date range queries
- `status` - Status filtering
- `(property_id, check_in_date, check_out_date)` - Conflict checking

---

### 7. reviews

Stores guest reviews for completed bookings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique review identifier |
| booking_id | INT | NOT NULL, UNIQUE, FK → bookings.id | Booking reference |
| rating | INT | NOT NULL, CHECK 1-5 | Rating (1-5 stars) |
| comment | TEXT | NULL | Review comment |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Review creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Constraints**: 
- UNIQUE on `booking_id` (one review per booking)

**Indexes**: 
- `booking_id` (FK, UNIQUE)
- `rating` - Rating analysis

---

### 8. payments

Stores payment transaction information for bookings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique payment identifier |
| booking_id | INT | NOT NULL, UNIQUE, FK → bookings.id | Booking reference |
| amount | DECIMAL(10,2) | NOT NULL, CHECK ≥ 0 | Payment amount |
| currency | VARCHAR(3) | NOT NULL, DEFAULT 'USD' | Currency code (ISO 4217) |
| method | VARCHAR(50) | NOT NULL | Payment method |
| status | ENUM | NOT NULL, DEFAULT 'pending' | Payment status |
| transaction_ref | VARCHAR(255) | NULL | External transaction reference |
| processed_at | TIMESTAMP | NULL | Processing timestamp |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last update timestamp |

**Status Values**: `pending`, `authorized`, `captured`, `failed`, `refunded`

**Constraints**: 
- UNIQUE on `booking_id` (one payment per booking)

**Indexes**: 
- `booking_id` (FK, UNIQUE)
- `status` - Status filtering
- `transaction_ref` - Transaction lookup
- `processed_at` - Processing queries

---

### 9. messages

Stores messages between users regarding bookings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique message identifier |
| booking_id | INT | NOT NULL, FK → bookings.id | Associated booking |
| sender_id | INT | NOT NULL, FK → users.id | Message sender |
| body | TEXT | NOT NULL | Message content |
| sent_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Send timestamp |

**Indexes**: 
- `booking_id` (FK)
- `sender_id` (FK)
- `sent_at` - Chronological ordering

---

## Relationships

### One-to-Many Relationships

- **User → Property**: One user can own many properties (`users.id` → `properties.owner_id`)
- **User → Booking**: One user can make many bookings (`users.id` → `bookings.guest_id`)
- **Property → Booking**: One property can have many bookings (`properties.id` → `bookings.property_id`)
- **Property → PropertyImage**: One property can have many images (`properties.id` → `property_images.property_id`)
- **Booking → Message**: One booking can have many messages (`bookings.id` → `messages.booking_id`)
- **User → Message**: One user can send many messages (`users.id` → `messages.sender_id`)

### One-to-One Relationships

- **Booking → Review**: One booking can have one review (`bookings.id` → `reviews.booking_id`, UNIQUE)
- **Booking → Payment**: One booking can have one payment (`bookings.id` → `payments.booking_id`, UNIQUE)

### Many-to-Many Relationships

- **Property ↔ Amenity**: Many properties can have many amenities (via `property_amenities` junction table)

## Foreign Key Constraints

All foreign keys are set with appropriate actions:

- **ON DELETE RESTRICT**: Prevents deletion of parent records when child records exist (users, properties, bookings)
- **ON DELETE CASCADE**: Automatically deletes child records when parent is deleted (property_amenities, property_images, messages)
- **ON UPDATE CASCADE**: Updates foreign key values when parent primary key changes

## Indexes Strategy

Indexes are created for:

1. **Primary Keys**: Automatic indexes on all PRIMARY KEY columns
2. **Foreign Keys**: Indexed for JOIN performance
3. **Unique Columns**: Indexed for uniqueness enforcement (`email`, `name`)
4. **Search Columns**: Full-text search on property title/description
5. **Query Optimization**: 
   - Composite indexes for common query patterns
   - Date range indexes for booking conflict checks
   - Location-based indexes for geographic queries
   - Status indexes for filtering

## Usage

### Creating the Database

```bash
mysql -u root -p < schema.sql
```

Or execute interactively:

```bash
mysql -u root -p
source schema.sql;
```

### Verification

After creating the database, verify tables were created:

```sql
USE airbnb_db;
SHOW TABLES;
DESCRIBE users;
-- Repeat for other tables
```

### Checking Constraints

```sql
-- View foreign keys
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    REFERENCED_TABLE_SCHEMA = 'airbnb_db';

-- View indexes
SHOW INDEX FROM properties;
```

## Constraints Summary

### Check Constraints

- `properties.price_per_night >= 0`
- `properties.max_guests > 0`
- `bookings.total_price >= 0`
- `bookings.check_out_date > check_in_date`
- `reviews.rating >= 1 AND rating <= 5`
- `payments.amount >= 0`

### Unique Constraints

- `users.email` (UNIQUE)
- `amenities.name` (UNIQUE)
- `reviews.booking_id` (UNIQUE)
- `payments.booking_id` (UNIQUE)
- `property_amenities(property_id, amenity_id)` (Composite PRIMARY KEY)

### NOT NULL Constraints

All critical fields are marked NOT NULL to ensure data integrity:
- User identification fields
- Property essential fields
- Booking dates and prices
- Review ratings
- Payment amounts

## Best Practices

1. **Always use parameterized queries** to prevent SQL injection
2. **Use transactions** for operations affecting multiple tables
3. **Monitor index usage** and adjust as query patterns change
4. **Backup regularly** before schema changes
5. **Test constraints** with sample data before production deployment

## Notes

- The schema uses `TIMESTAMP` with automatic initialization and updates
- Character set `utf8mb4` supports full Unicode including emojis
- `InnoDB` engine provides ACID compliance and foreign key support
- Soft deletes are not implemented; add `deleted_at` column if needed
- Consider adding indexes for specific application query patterns

## Future Enhancements

Potential additions to consider:

- Soft delete support (`deleted_at` columns)
- Audit logging table
- User roles/permissions table
- Notification preferences
- Property availability calendar
- Pricing history/changes tracking
- Currency conversion support

---

**Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: alx-airbnb-database project

