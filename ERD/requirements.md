# Airbnb Database ERD Requirements

This document identifies core entities, attributes, and relationships for an Airbnb-like database. It also includes a Mermaid ER diagram (in `erd.mmd`) that can be imported into Draw.io (diagrams.net).

## Entities and Attributes

1. User
   - id (PK)
   - first_name
   - last_name
   - email (unique)
   - phone_number (nullable)
   - password_hash
   - created_at
   - updated_at

2. Property
   - id (PK)
   - owner_id (FK → User.id)
   - title
   - description
   - address_line1
   - address_line2 (nullable)
   - city
   - state
   - postal_code
   - country
   - latitude (nullable)
   - longitude (nullable)
   - price_per_night
   - max_guests
   - created_at
   - updated_at

3. Booking
   - id (PK)
   - property_id (FK → Property.id)
   - guest_id (FK → User.id)
   - check_in_date
   - check_out_date
   - total_price
   - status (enum: pending, confirmed, cancelled, completed)
   - created_at
   - updated_at

4. Review
   - id (PK)
   - booking_id (FK → Booking.id, unique)
   - rating (1-5)
   - comment (nullable)
   - created_at
   - updated_at

5. Payment
   - id (PK)
   - booking_id (FK → Booking.id, unique)
   - amount
   - currency (e.g., USD)
   - method (e.g., card, paypal)
   - status (enum: pending, authorized, captured, failed, refunded)
   - transaction_ref (nullable)
   - processed_at (nullable)
   - created_at
   - updated_at

6. Amenity
   - id (PK)
   - name (unique)
   - created_at
   - updated_at

7. PropertyAmenity (junction)
   - property_id (FK → Property.id)
   - amenity_id (FK → Amenity.id)
   - (PK: property_id, amenity_id)

8. PropertyImage
   - id (PK)
   - property_id (FK → Property.id)
   - image_url
   - is_primary (boolean)
   - sort_order (nullable)
   - created_at
   - updated_at

9. Message
   - id (PK)
   - booking_id (FK → Booking.id)
   - sender_id (FK → User.id)
   - body
   - sent_at

## Relationships

- User (owner) 1 — n Property
- User (guest) 1 — n Booking
- Property 1 — n Booking
- Booking 1 — 1 Review
- Booking 1 — 1 Payment
- Property n — n Amenity (via PropertyAmenity)
- Property 1 — n PropertyImage
- Booking 1 — n Message
- User 1 — n Message (as sender)

Notes and constraints:
- A Property must have exactly one owner (User).
- A Booking must have exactly one guest (User) and one Property.
- A Review is created for at most one Booking; one Booking can have at most one Review.
- A Payment is associated with exactly one Booking; one Booking can have at most one Payment.
- Amenities are reusable across properties via the junction table.
- Basic soft-deletes are not included; add `deleted_at` if needed.

## Diagram

See `ERD/erd.mmd` for a Mermaid `erDiagram`. You can import it into Draw.io:
1. Open `https://app.diagrams.net`.
2. File → New → Blank Diagram.
3. Arrange → Insert → Advanced → Mermaid.
4. Paste the contents of `erd.mmd` and Insert.


