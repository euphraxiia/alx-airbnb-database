# Database Advanced Scripts - Complex Queries

This directory contains SQL queries demonstrating different types of JOIN operations and subqueries on the Airbnb database.

## Files

- `joins_queries.sql` - Contains three complex queries using different JOIN types
- `subqueries.sql` - Contains queries demonstrating correlated and non-correlated subqueries
- `aggregations_and_window_functions.sql` - Contains queries demonstrating aggregation functions and window functions
- `database_index.sql` - Contains CREATE INDEX statements for query optimization
- `index_performance.md` - Documentation of index performance analysis with EXPLAIN results
- `perfomance.sql` - Contains initial and optimized complex query for booking retrieval
- `optimization_report.md` - Detailed analysis of query optimization with EXPLAIN results and performance metrics
- `partitioning.sql` - Contains table partitioning implementation for bookings table by check_in_date
- `partition_performance.md` - Performance analysis report for partitioned tables with EXPLAIN results and improvements
- `performance_monitoring.md` - Continuous performance monitoring report with EXPLAIN ANALYZE and SHOW PROFILE analysis, bottleneck identification, and optimization implementations

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

---

## Aggregations and Window Functions Overview

This section demonstrates **aggregation functions** (COUNT, SUM, AVG, etc.) with GROUP BY, and **window functions** (RANK, DENSE_RANK, ROW_NUMBER) for advanced data analysis.

### Query 1: Aggregation with COUNT and GROUP BY
**Objective:** Find the total number of bookings made by each user using COUNT function and GROUP BY clause.

**What it does:**
- Joins `users` with `bookings` to get user booking information
- Uses `COUNT(b.id)` to count bookings per user
- Uses `GROUP BY` to aggregate data by user
- Includes additional aggregations: SUM, AVG, MIN, MAX for comprehensive analysis
- Uses LEFT JOIN to include users with zero bookings (showing 0 count)

**Aggregation functions used:**
- `COUNT(b.id)` - Counts the number of bookings per user
- `SUM(b.total_price)` - Total amount spent by each user
- `AVG(b.total_price)` - Average booking price per user
- `MIN(b.check_in_date)` - Earliest booking date
- `MAX(b.check_in_date)` - Most recent booking date

**Example Use Case:**
- Customer analytics: Analyze booking patterns by user
- Generate user activity reports
- Identify most active customers
- Calculate customer lifetime value metrics

### Query 2: Window Functions (RANK, DENSE_RANK, ROW_NUMBER)
**Objective:** Rank properties based on the total number of bookings they have received using window functions.

**What it does:**
- Calculates total bookings per property using COUNT and GROUP BY
- Applies three different window functions to rank properties:
  - **RANK()**: Assigns same rank for ties, skips ranks after ties (1, 2, 2, 4, 5...)
  - **DENSE_RANK()**: Assigns same rank for ties, doesn't skip ranks (1, 2, 2, 3, 4...)
  - **ROW_NUMBER()**: Assigns unique sequential numbers, breaks ties arbitrarily (1, 2, 3, 4, 5...)
- Orders by booking count descending to rank most popular properties first

**Window function syntax:**
```sql
RANK() OVER (ORDER BY COUNT(b.id) DESC)
```

**Key differences between ranking functions:**

| Function | Behavior with Ties | Example Output |
|----------|-------------------|----------------|
| **RANK()** | Same rank, skips next ranks | 1, 2, 2, 4, 5 |
| **DENSE_RANK()** | Same rank, no skipping | 1, 2, 2, 3, 4 |
| **ROW_NUMBER()** | Unique numbers (breaks ties) | 1, 2, 3, 4, 5 |

**Example Use Case:**
- Property performance analysis: Identify most popular properties
- Marketing prioritization: Focus on top-ranked properties
- Competitive analysis: Compare property booking volumes
- Business intelligence: Generate property rankings for reports

## Running the Aggregation and Window Function Queries

```bash
# Option 1: Run the entire file
mysql -u your_username -p airbnb_db < aggregations_and_window_functions.sql

# Option 2: Run individual queries in MySQL client
mysql -u your_username -p airbnb_db
mysql> source aggregations_and_window_functions.sql;

# Option 3: Copy and paste individual queries into your MySQL client
```

## Expected Results (Aggregations and Window Functions)

Based on the seed data:

1. **Aggregation Query (Bookings per user):**
   - Should return 3 rows (one per user)
   - Users with bookings will show counts ≥ 1
   - Users without bookings will show 0 count
   - User ID 1 should show 2 bookings (based on seed data: bookings 3 and 4)
   - User ID 2 should show 1 booking (booking 1)
   - User ID 3 should show 1 booking (booking 2)

2. **Window Function Query (Property rankings):**
   - Should return 4 rows (one per property)
   - Properties will be ranked by booking count
   - Properties with the same booking count will have the same RANK() and DENSE_RANK()
   - ROW_NUMBER() will assign unique numbers, using property_id as tie-breaker
   - Based on seed data, properties with bookings should rank higher than those without

## Notes on Aggregations and Window Functions

- **GROUP BY** is required when using aggregation functions with non-aggregated columns
- **Window functions** (like RANK) operate on result sets after aggregation
- Window functions don't collapse rows like GROUP BY - they add computed columns
- **PARTITION BY** can be used in window functions to create separate ranking groups
- MySQL 8.0+ supports window functions (RANK, ROW_NUMBER, DENSE_RANK, etc.)
- For older MySQL versions (< 8.0), window functions are not available
- Use indexes on foreign keys (guest_id, property_id) for better aggregation performance
