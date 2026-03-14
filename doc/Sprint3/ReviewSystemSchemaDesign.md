# Review System Schema Design

This document defines the backend database design for passenger reviews per trip.

## Scope

- One passenger review per completed trip booking.
- A review belongs to one booking.
- A review references both passenger (reviewer) and driver (reviewee).

## Proposed Prisma Model

```prisma
enum ReviewStatus {
  PUBLISHED
  HIDDEN
}

model Review {
  id          String       @id @default(cuid())
  bookingId   String       @unique
  booking     Booking      @relation(fields: [bookingId], references: [id], onDelete: Cascade)

  reviewerId  String
  reviewer    User         @relation("PassengerReviews", fields: [reviewerId], references: [id], onDelete: Cascade)

  revieweeId  String
  reviewee    User         @relation("DriverReviews", fields: [revieweeId], references: [id], onDelete: Cascade)

  rating      Int
  comment     String?
  status      ReviewStatus @default(PUBLISHED)

  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt

  @@index([revieweeId, createdAt])
  @@index([reviewerId, createdAt])
  @@index([status])
}
```

## Relation Additions to Existing Models

```prisma
model User {
  passengerReviews Review[] @relation("PassengerReviews")
  driverReviews    Review[] @relation("DriverReviews")
}

model Booking {
  review Review?
}
```

## Constraints and Validation Rules

- `@unique(bookingId)` enforces one review per booking at database level.
- API must validate booking route status is `COMPLETED` before create.
- API must validate reviewer is the booking passenger.
- API must set `revieweeId` from route driver, not from client input.
- `rating` should be constrained to 1-5 at validation layer.

## Why this design

- Keeps review ownership tied to an actual trip booking.
- Prevents duplicate reviews with a hard database constraint.
- Supports driver profile aggregation via `revieweeId` index.
- Keeps moderation option open with `ReviewStatus`.
