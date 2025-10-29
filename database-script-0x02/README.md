# Seed Data for Airbnb Database

## Overview

This directory contains SQL scripts to populate the `airbnb_db` database with realistic sample data for development and testing.

## Files

- `seed.sql` — Inserts sample data for all tables in the schema.

## Prerequisites

- MySQL server installed and running
- The schema from `database-script-0x01/schema.sql` has been created in `airbnb_db`

## How to Run

From the repository root:

```bash
mysql -u root -p < database-script-0x01/schema.sql
mysql -u root -p < database-script-0x02/seed.sql
```

Alternatively, in an interactive MySQL session:

```sql
SOURCE database-script-0x01/schema.sql;
SOURCE database-script-0x02/seed.sql;
```

## What This Seeds

### Users (3)
- Alice Johnson (owner of properties 1 and 2)
- Bob Smith (owner of property 3)
- Charlie Lee (owner of property 4)

### Properties (4)
- Sunny Beach House (Santa Monica, CA)
- Cozy Downtown Loft (San Francisco, CA)
- Mountain Cabin Retreat (Aspen, CO)
- Charming Paris Studio (Paris, France)

### Amenities (10)
- WiFi, Air Conditioning, Heating, Kitchen, Washer, Dryer, Free Parking, Hot Tub, Pool, Pets Allowed

### Property Amenities
- Each property is assigned a realistic set of amenities

### Property Images (6)
- Primary images and a few secondary images per property

### Bookings (4)
- Mix of statuses: completed, confirmed, pending, canceled

### Reviews (1)
- Review for the completed booking

### Payments (2)
- Payments for completed and confirmed bookings

### Messages (4)
- Conversational messages between guest and host regarding bookings

## Notes

- The seed file clears existing data in a safe referential order using `TRUNCATE TABLE` with `FOREIGN_KEY_CHECKS` temporarily disabled
- Explicit IDs are used for deterministic relationships across tables
- Timestamps use `NOW()` for creation/update with some realistic fixed times for events

## Verification

After running the seed, verify data counts:

```sql
USE airbnb_db;
SELECT COUNT(*) AS users FROM users;
SELECT COUNT(*) AS properties FROM properties;
SELECT COUNT(*) AS amenities FROM amenities;
SELECT COUNT(*) AS property_amenities FROM property_amenities;
SELECT COUNT(*) AS property_images FROM property_images;
SELECT COUNT(*) AS bookings FROM bookings;
SELECT COUNT(*) AS reviews FROM reviews;
SELECT COUNT(*) AS payments FROM payments;
SELECT COUNT(*) AS messages FROM messages;
```

Sample joins to verify relationships:

```sql
-- Properties with owners
SELECT p.id, p.title, u.email AS owner_email
FROM properties p
JOIN users u ON p.owner_id = u.id
ORDER BY p.id;

-- Bookings with property and guest
SELECT b.id, p.title AS property, u.email AS guest, b.status
FROM bookings b
JOIN properties p ON b.property_id = p.id
JOIN users u ON b.guest_id = u.id
ORDER BY b.id;

-- Amenities for a property
SELECT p.title, a.name AS amenity
FROM property_amenities pa
JOIN properties p ON pa.property_id = p.id
JOIN amenities a ON pa.amenity_id = a.id
WHERE p.id = 1
ORDER BY a.name;
```
