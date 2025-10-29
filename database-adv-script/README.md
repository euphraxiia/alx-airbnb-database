# Database Advanced Scripts - Complex Queries

This directory contains SQL queries demonstrating different types of JOIN operations and subqueries on the Airbnb database.

## Files

- `joins_queries.sql` - Contains three complex queries using different JOIN types
- `subqueries.sql` - Contains queries demonstrating correlated and non-correlated subqueries

## Prerequisites

1. Ensure the database schema has been created using `database-script-0x01/schema.sql`
2. Ensure seed data has been loaded using `database-script-0x02/seed.sql`
3. Make sure you're connected to MySQL/MariaDB

## Joins Queries Overview

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

---

## Subqueries Queries Overview

This section demonstrates both **correlated** and **non-correlated subqueries**.

### Query 1: Non-Correlated Subquery
**Objective:** Find all properties where the average rating is greater than 4.0 using a subquery.

**What it does:**
- Uses a non-correlated subquery in the FROM clause (derived table)
- The subquery calculates the average rating per property from reviews
- Filters properties with average rating > 4.0 using HAVING clause
- Joins the result back to the properties table for complete property information
- Returns property details along with average rating and review count

**How it works:**
- The subquery executes once, independently of the outer query
- Groups reviews by property_id through bookings
- Calculates AVG(rating) and filters results
- The outer query joins this result set with the properties table

**Example Use Case:**
- Identify top-rated properties for featured listings
- Quality assurance: Find properties that consistently receive high ratings
- Marketing campaigns: Highlight highly-rated properties

### Query 2: Correlated Subquery
**Objective:** Find users who have made more than 3 bookings using a correlated subquery.

**What it does:**
- Uses a correlated subquery in the WHERE clause
- For each user, the subquery counts their bookings by referencing the outer query's user ID
- The subquery uses `b.guest_id = u.id` to correlate with the outer query
- Filters users where the booking count > 3
- Also includes the booking count in the SELECT clause for display

**How it works:**
- The subquery executes once for each row in the outer query
- It references values from the outer query (`u.id`)
- Each execution counts bookings for that specific user
- Returns only users who meet the condition (> 3 bookings)

**Example Use Case:**
- Customer loyalty programs: Identify frequent customers
- VIP user identification: Find high-value customers
- Booking activity analysis: Track most active users

### Key Differences

| Feature | Non-Correlated Subquery | Correlated Subquery |
|---------|------------------------|---------------------|
| **Execution** | Runs once, independently | Runs once per row of outer query |
| **Performance** | Generally faster | Can be slower with large datasets |
| **Dependencies** | No reference to outer query | References columns from outer query |
| **Use Case** | Filtering based on aggregated data | Row-by-row condition checking |

## Running the Subquery Queries

```bash
# Option 1: Run the entire file
mysql -u your_username -p airbnb_db < subqueries.sql

# Option 2: Run individual queries in MySQL client
mysql -u your_username -p airbnb_db
mysql> source subqueries.sql;

# Option 3: Copy and paste individual queries into your MySQL client
```

## Expected Results (Subqueries)

Based on the seed data:

1. **Non-Correlated Subquery (Properties with avg rating > 4.0):** 
   - Should return property with ID 1 (the only property with a review, rating 5.0)
   - Average rating displayed will be 5.0

2. **Correlated Subquery (Users with > 3 bookings):**
   - Based on seed data, may return no users (each user has ≤ 2 bookings)
   - To see results, you may need to add more bookings to the seed data
   - If you have users with > 3 bookings, they will be returned with their booking count

## Notes on Subqueries

- **Non-correlated subqueries** are more efficient as they execute once
- **Correlated subqueries** provide more flexibility but can be slower
- Both query files include alternative approaches commented out for learning
- Consider using indexes on foreign keys (guest_id, property_id, booking_id) for better performance
