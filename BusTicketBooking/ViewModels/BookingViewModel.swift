//
//  BookingViewModel.swift
//  BusTicketBooking
//
//  Created by macos on 30/3/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class BookingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookings: [Booking] = []
    
    private let db = Firestore.firestore()
    
    // MARK: - Booking Management
    
    /// Book seats for a bus trip
    func bookSeats(_ seatIndices: [Int], for trip: BusTrip, userId: String, totalPrice: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // Update seat matrix in busTrips
            let seatLabels = seatIndices.map { SeatHelper.indexToLabel($0) }
            let updatedMatrix = SeatHelper.updateSeatMatrix(trip.seatMatrix, bookingIndices: seatIndices)
            
            // Create booking record
            let bookingData: [String: Any] = [
                "userId": userId,
                "busTripId": trip.id,
                "seatIndices": seatIndices,
                "seatLabels": seatLabels,
                "totalPrice": totalPrice,
                "bookingDate": Date().timeIntervalSince1970,
                "status": "confirmed"
            ]
            
            // Use a batch write to ensure atomicity
            let batch = db.batch()
            
            // Update busTrip seatMatrix
            let busRef = db.collection("busTrips").document(trip.id)
            batch.updateData(["seatMatrix": updatedMatrix], forDocument: busRef)
            
            // Create booking document
            let bookingRef = db.collection("bookings").document()
            batch.setData(bookingData, forDocument: bookingRef)
            
            try await batch.commit()
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Failed to book seats: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    /// Fetch bookings for a user
    func fetchUserBookings(userId: String) {
        isLoading = true
        errorMessage = nil
        
        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "bookingDate", descending: true)
            .getDocuments { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Unable to load bookings: \(error.localizedDescription)"
                        return
                    }
                    
                    // For now, just store the count or basic info
                    // Full implementation would fetch BusTrip data for each booking
                    self.bookings = []
                }
            }
    }
    
    /// Fetch all bookings for a specific bus trip
    func fetchTripBookings(tripId: String) async throws -> [Booking] {
        let snapshot = try await db.collection("bookings")
            .whereField("busTripId", isEqualTo: tripId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            // Return basic booking info without full BusTrip data
            // This is for getting booked seat info
            nil
        }
    }
    
    /// Cancel a booking
    func cancelBooking(_ booking: Booking) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // Update booking status
            try await db.collection("bookings").document(booking.id)
                .updateData(["status": "cancelled"])
            
            // Update seat matrix by removing booked seats
            let currentTrip = booking.busTrip
            var updatedMatrix = Array(currentTrip.seatMatrix)
            for index in booking.seatIndices {
                if index >= 0 && index < updatedMatrix.count {
                    updatedMatrix[index] = "0"
                }
            }
            
            try await db.collection("busTrips").document(currentTrip.id)
                .updateData(["seatMatrix": String(updatedMatrix)])
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Failed to cancel booking: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
