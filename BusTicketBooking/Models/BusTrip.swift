//
//  BusTrip.swift
//  BusTicketBooking
//
//  Created by macos on 4/3/26.
//

import Foundation

struct BusTrip: Identifiable {
    let id: String
    let busName: String
    let source: String
    let destination: String
    let departureTime: String
    let arrivalTime: String
    let availableSeats: Int
    let ticketPrice: Int
    let busType: String

    // MARK: - Firestore Initializer
    init?(documentID: String, data: [String: Any]) {
        guard
            let busName = data["busName"] as? String,
            let source = data["source"] as? String,
            let destination = data["destination"] as? String,
            let departureTime = data["departureTime"] as? String,
            let arrivalTime = data["arrivalTime"] as? String,
            let availableSeats = data["availableSeats"] as? Int,
            let ticketPrice = data["ticketPrice"] as? Int,
            let busType = data["busType"] as? String
        else { return nil }

        self.id = documentID
        self.busName = busName
        self.source = source
        self.destination = destination
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.availableSeats = availableSeats
        self.ticketPrice = ticketPrice
        self.busType = busType
    }

    // MARK: - Computed Properties
    var duration: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
        guard let dep = formatter.date(from: departureTime),
              let arr = formatter.date(from: arrivalTime) else {
            return "--"
        }
        var diff = arr.timeIntervalSince(dep)
        if diff < 0 { diff += 24 * 3600 } // overnight trip
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if minutes == 0 { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
    }

    var priceFormatted: String {
        "৳\(ticketPrice)"
    }
}
