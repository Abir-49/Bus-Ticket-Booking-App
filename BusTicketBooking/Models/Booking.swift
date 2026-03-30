//
//  Booking.swift
//  BusTicketBooking
//
//  Created by macos on 30/3/26.
//

import Foundation

struct Booking: Identifiable {
    let id: String
    let busTrip: BusTrip
    let userId: String
    let seatIndices: [Int] // Indices in the 40-seat matrix (0-39)
    let seatLabels: [String] // Display names (A1, A2, etc.)
    let totalPrice: Int
    let bookingDate: Date
    let status: BookingStatus
    
    enum BookingStatus: String {
        case confirmed = "confirmed"
        case cancelled = "cancelled"
        case pending = "pending"
    }
    
    // MARK: - Firestore Initializer
    init?(documentID: String, data: [String: Any], busTrip: BusTrip) {
        guard
            let userId = data["userId"] as? String,
            let seatIndices = data["seatIndices"] as? [Int],
            let seatLabels = data["seatLabels"] as? [String],
            let totalPrice = data["totalPrice"] as? Int,
            let timestamp = data["bookingDate"] as? TimeInterval,
            let statusStr = data["status"] as? String,
            let status = BookingStatus(rawValue: statusStr)
        else { return nil }
        
        self.id = documentID
        self.busTrip = busTrip
        self.userId = userId
        self.seatIndices = seatIndices
        self.seatLabels = seatLabels
        self.totalPrice = totalPrice
        self.bookingDate = Date(timeIntervalSince1970: timestamp)
        self.status = status
    }
    
    // MARK: - Initializer
    init(busTripId: String, busTrip: BusTrip, userId: String, seatIndices: [Int], seatLabels: [String], totalPrice: Int) {
        self.id = UUID().uuidString
        self.busTrip = busTrip
        self.userId = userId
        self.seatIndices = seatIndices
        self.seatLabels = seatLabels
        self.totalPrice = totalPrice
        self.bookingDate = Date()
        self.status = .confirmed
    }
    
    // MARK: - Firestore Dict
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "busTripId": busTrip.id,
            "seatIndices": seatIndices,
            "seatLabels": seatLabels,
            "totalPrice": totalPrice,
            "bookingDate": bookingDate.timeIntervalSince1970,
            "status": status.rawValue
        ]
    }
}
