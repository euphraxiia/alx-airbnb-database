# Database Advanced Scripts - Complex Queries with Joins

This directory contains SQL queries demonstrating different types of JOIN operations on the Airbnb database.

## Files

- `joins_queries.sql` - Contains three complex queries using different JOIN types

## Prerequisites

1. Ensure the database schema has been created using `database-script-0x01/schema.sql`
2. Ensure seed data has been loaded using `database-script-0x02/seed.sql`
3. Make sure you're connected to MySQL/MariaDB

## Queries Overview

### Query 1: INNER JOIN
**Objective:** Retrieve all bookings and the respective users who made those bookings.

**What it does:**
- Joins the `bookings` table with the `users` table on `guest_id`
- Returns only bookings that have a valid associated user (no NULL matches)
- Displays booking details along with user information

**Example Use Case:**
- Generate a report of all bookings with customer information
- Track which users have made bookings

### Query 2: LEFT JOIN
**Objective:** Retrieve all properties and their reviews, including properties that have no reviews.

**What it does:**
- Starts with the `properties` table (left table)
- Left joins with `bookings` to connect properties to bookings
- Left joins with `reviews` to get review information
- Returns all properties, even if they have no bookings or no reviews
- Properties without reviews will have NULL values in review-related columns

**Example Use Case:**
- Generate a property listing showing review status
- Identify properties that haven't received any reviews yet
- Marketing analysis of property performance

### Query 3: FULL OUTER JOIN (Simulated)
**Objective:** Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

**What it does:**
- Since MySQL doesn't natively support FULL OUTER JOIN, this query simulates it using UNION
- First part: Left join users to bookings (gets all users with their bookings)
- Second part: Right join bookings to users where user is NULL (gets orphaned bookings)
- UNION combines both results, removing duplicates
- Returns:
  - Users with bookings
  - Users without any bookings (booking columns will be NULL)
  - Bookings that don't have a valid user (user columns will be NULL)

**Example Use Case:**
- Data integrity check: Find orphaned bookings or users without bookings
- Complete user activity report
- Auditing and data validation

## Running the Queries

```bash
# Option 1: Run the entire file
mysql -u your_username -p airbnb_db < joins_queries.sql

# Option 2: Run individual queries in MySQL client
mysql -u your_username -p airbnb_db
mysql> source joins_queries.sql;

# Option 3: Copy and paste individual queries into your MySQL client
```

## Expected Results

Based on the seed data:

1. **INNER JOIN Query:** Should return 4 rows (all 4 bookings from seed data)
2. **LEFT JOIN Query:** Should return at least 4 rows (one row per property, with review information where available)
3. **FULL OUTER JOIN Query:** Should return 3 users (some with bookings, some without) plus any orphaned bookings

## Notes

- The FULL OUTER JOIN simulation uses UNION to combine LEFT and RIGHT JOIN results
- NULL values in result sets indicate missing relationships (expected behavior)
- All queries include ORDER BY clauses for consistent result ordering
- The queries can be modified to filter by specific criteria (dates, status, etc.)

## Database Schema Reference

Key relationships:
- `bookings.guest_id` → `users.id`
- `bookings.property_id` → `properties.id`
- `reviews.booking_id` → `bookings.id`

For complete schema details, see `../database-script-0x01/schema.sql`
