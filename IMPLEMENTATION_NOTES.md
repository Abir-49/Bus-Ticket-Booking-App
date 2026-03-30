# Bus Ticket Booking - Seat Selection Database Integration

## Implementation Summary

### ✅ Changes Completed

#### 1. **BusTrip Model** - [BusTrip.swift](BusTicketBooking/Models/BusTrip.swift)
- Added `seatMatrix: String` field (40-character binary string)
- Updated Firestore initializer to read seatMatrix from database
- Default value: all zeros (all seats available) if not provided
- Structure: 10 rows × 4 columns = 40 seats (indices 0-39)

#### 2. **Booking Model** - [Booking.swift](BusTicketBooking/Models/Booking.swift) (NEW)
- Created new `Booking` struct for representing seat bookings
- Fields:
  - `id`: Unique booking identifier
  - `busTrip`: Reference to booked bus trip
  - `userId`: User who made the booking
  - `seatIndices`: Array of booked seat indices (0-39)
  - `seatLabels`: Array of seat display names (A1, A2, etc.)
  - `totalPrice`: Total booking cost
  - `bookingDate`: Timestamp of booking
  - `status`: BookingStatus enum (confirmed/cancelled/pending)
- Includes Firestore initializer and serialization methods

#### 3. **SeatHelper Utility** - [SeatHelper.swift](BusTicketBooking/Models/SeatHelper.swift) (NEW)
Provides utility functions for seat operations:
- `indexToLabel()`: Converts seat index (0-39) → seat label (A1-J4)
  - Index formula: `row = index / 4`, `col = index % 4`
  - Labels: A1-A4, B1-B4, ..., J1-J4
- `labelToIndex()`: Converts seat label → seat index
- `isSeatBooked()`: Checks if seat is booked in matrix
- `updateSeatMatrix()`: Updates matrix when seats are booked
- `getBookedSeatIndices()`: Returns all booked seat indices
- `getAvailableSeatIndices()`: Returns all available seat indices

#### 4. **BookingViewModel** - [BookingViewModel.swift](BusTicketBooking/ViewModels/BookingViewModel.swift) (NEW)
Handles all database operations for bookings:
- `bookSeats()`: Main function to book seats
  - Uses batch writes for atomicity
  - Updates busTrip seatMatrix in database
  - Creates new booking record
  - Returns success/failure
- `fetchUserBookings()`: Retrieves user's past bookings
- `fetchTripBookings()`: Gets bookings for specific bus trip
- `cancelBooking()`: Cancels booking and frees up seats
  - Updates seatMatrix to mark seats as available (0)

#### 5. **SeatSelectionView** - [SeatSelectionView.swift](BusTicketBooking/Views/SeatSelectionView.swift)
Completely redesigned with database integration:
- **Seat Display**: Shows seats with proper labels (A1, A2, A3, A4, then B1, etc.)
  - Uses `SeatHelper.indexToLabel()` for naming
  - 10x4 grid layout with aisle separator
- **Booked Seat Detection**: Reads from `trip.seatMatrix`
  - Uses `SeatHelper.isSeatBooked()` to check status
- **Seat Selection**: Stores selected seat indices (0-39)
- **Booking Confirmation**:
  - Gets current user from Firebase Auth
  - Calls `bookingViewModel.bookSeats()`
  - Shows success alert and dismisses on confirmation
  - Displays error messages if booking fails
- **UI Indicators**:
  - Gray: Available
  - Blue: Selected
  - Red (opacity): Booked

#### 6. **SeedService** - [SeedService.swift](BusTicketBooking/ViewModels/SeedService.swift)
Updated to initialize database with seat data:
- Changed seed version from "v1" → "v2" to trigger re-seeding
- **generateSeatMatrix()** function:
  - Creates 40-character binary string
  - Randomly books 3-7 front seats (rows A and B)
  - Front seats indices: 0-7 (A1-A4, B1-B4)
  - Simulates realistic bus occupancy
- Applies seatMatrix to all 59 bus trips before seeding

### Database Structure

#### Collections:
1. **busTrips**
   - id (auto)
   - busName, source, destination (string)
   - departureTime, arrivalTime (string)
   - availableSeats, ticketPrice (int)
   - busType (string)
   - **seatMatrix** (string - NEW)

2. **bookings** (NEW)
   - userId (string)
   - busTripId (string)
   - seatIndices (array of ints)
   - seatLabels (array of strings)
   - totalPrice (int)
   - bookingDate (timestamp/float)
   - status (string)

3. **popularRoutes** (unchanged)
4. **Other existing collections** (unchanged)

### Seat Matrix Format

**10 Rows × 4 Columns = 40 Seats**

```
Row A (indices 0-3):   A1 A2 | A3 A4
Row B (indices 4-7):   B1 B2 | B3 B4
Row C (indices 8-11):  C1 C2 | C3 C4
...
Row J (indices 36-39): J1 J2 | J3 J4

Binary String Example:
"1100010000000000000000000000000000000000"
├─ Position 0-3: A1(1) A2(1) A3(0) A4(0) - A1,A2 booked, A3,A4 available
├─ Position 4-7: B1(0) B2(1) B3(0) B4(0) - B2 booked, rest available
└─ Position 8-39: All zeros (all available)
```

### Backward Compatibility

✅ **All previous code structures maintained:**
- Existing BusTrip fields unchanged (busName, source, destination, etc.)
- Existing Views and ViewModels still work
- AuthViewModel and other services unaffected
- Only new `seatMatrix` field added (defaults to all zeros if missing)
- No breaking changes to existing database queries

### User Flow

1. **Seed Database** → All bus trips get initialized with random front seat bookings
2. **User Searches** → Fetches bus trips (includes seatMatrix)
3. **User Selects Trip** → Views seat selection screen
4. **Seat Selection** → User selects seats (A1, A2, etc.)
5. **Confirm Booking** → 
   - Validates user authentication
   - Calls `bookingViewModel.bookSeats()`
   - Updates busTrip seatMatrix in Firestore
   - Creates booking record
   - Shows success alert
6. **Next User** → Sees updated seat availability

### Testing Checklist

- ✅ No compilation errors
- ✅ All models properly structured
- ✅ Database serialization ready
- ✅ Seat labeling correct (A1-J4)
- ✅ Binary matrix operations working
- ✅ Firebase batch writes configured
- ✅ Error handling in place
- ✅ Backward compatible with existing code
- ✅ Seed version incremented (v2)
- ✅ Previous data won't break (seatMatrix optional with default)

### Files Created/Modified

**NEW FILES:**
- BusTicketBooking/Models/Booking.swift
- BusTicketBooking/Models/SeatHelper.swift
- BusTicketBooking/ViewModels/BookingViewModel.swift

**MODIFIED FILES:**
- BusTicketBooking/Models/BusTrip.swift
- BusTicketBooking/Views/SeatSelectionView.swift
- BusTicketBooking/ViewModels/SeedService.swift
