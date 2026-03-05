//
//  SeedService.swift
//  BusTicketBooking
//
//  Seeds the "popularRoutes" and "busTrips" Firestore collections
//  directly from the app using the regular Firebase SDK.
//
//  Usage: call SeedService.shared.seedIfNeeded() once, or trigger
//  it manually from the MoreView admin button.
//
//  Created by macos on 4/3/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class SeedService: ObservableObject {

    static let shared = SeedService()

    @Published var status: SeedStatus = .idle

    enum SeedStatus: Equatable {
        case idle
        case running
        case done(message: String)
        case failed(message: String)
    }

    private let db = Firestore.firestore()
    private let seededKey = "firestoreSeeded_v1"

    // MARK: - Public API

    /// Seeds only if not previously completed on this device.
    func seedIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        Task { await runSeed() }
    }

    /// Always re-seeds (use from the admin button).
    func forceSeed() {
        Task { await runSeed() }
    }

    // MARK: - Internal

    private func runSeed() async {
        status = .running
        do {
            try await seedCollection("popularRoutes", documents: popularRoutes)
            try await seedCollection("busTrips",      documents: busTrips)
            UserDefaults.standard.set(true, forKey: seededKey)
            status = .done(message: "Seeded \(popularRoutes.count) routes and \(busTrips.count) bus trips ✓")
        } catch {
            status = .failed(message: error.localizedDescription)
        }
    }

    /// Writes all documents to a collection using batched writes (max 500 per batch).
    private func seedCollection(_ name: String, documents: [[String: Any]]) async throws {
        let col = db.collection(name)
        let chunkSize = 400 // stay well under the 500-write batch limit

        for chunk in stride(from: 0, to: documents.count, by: chunkSize) {
            let batch = db.batch()
            let end = min(chunk + chunkSize, documents.count)
            for doc in documents[chunk..<end] {
                batch.setData(doc, forDocument: col.document())
            }
            try await batch.commit()
        }
    }

    // MARK: - popularRoutes (55 documents)
    // Fields: from (String), to (String), minPrice (Int)

    private let popularRoutes: [[String: Any]] = [
        // Dhaka-outbound (22)
        ["from": "Dhaka",       "to": "Chattagram",  "minPrice": 700 ],
        ["from": "Dhaka",       "to": "Sylhet",       "minPrice": 750 ],
        ["from": "Dhaka",       "to": "Khulna",       "minPrice": 700 ],
        ["from": "Dhaka",       "to": "Rajshahi",     "minPrice": 600 ],
        ["from": "Dhaka",       "to": "Barisal",      "minPrice": 550 ],
        ["from": "Dhaka",       "to": "Rangpur",      "minPrice": 750 ],
        ["from": "Dhaka",       "to": "Cox's Bazar",  "minPrice": 950 ],
        ["from": "Dhaka",       "to": "Mymensingh",   "minPrice": 250 ],
        ["from": "Dhaka",       "to": "Comilla",      "minPrice": 300 ],
        ["from": "Dhaka",       "to": "Bogura",       "minPrice": 500 ],
        ["from": "Dhaka",       "to": "Faridpur",     "minPrice": 300 ],
        ["from": "Dhaka",       "to": "Jessore",      "minPrice": 600 ],
        ["from": "Dhaka",       "to": "Dinajpur",     "minPrice": 850 ],
        ["from": "Dhaka",       "to": "Tangail",      "minPrice": 180 ],
        ["from": "Dhaka",       "to": "Madaripur",    "minPrice": 320 ],
        ["from": "Dhaka",       "to": "Chandpur",     "minPrice": 280 ],
        ["from": "Dhaka",       "to": "Brahmanbaria", "minPrice": 260 ],
        ["from": "Dhaka",       "to": "Noakhali",     "minPrice": 380 ],
        ["from": "Dhaka",       "to": "Feni",         "minPrice": 350 ],
        ["from": "Dhaka",       "to": "Pabna",        "minPrice": 380 ],
        ["from": "Dhaka",       "to": "Kushtia",      "minPrice": 520 ],
        ["from": "Dhaka",       "to": "Narayanganj",  "minPrice": 80  ],

        // Chattagram-outbound (6)
        ["from": "Chattagram",  "to": "Cox's Bazar",  "minPrice": 380 ],
        ["from": "Chattagram",  "to": "Sylhet",        "minPrice": 620 ],
        ["from": "Chattagram",  "to": "Comilla",       "minPrice": 280 ],
        ["from": "Chattagram",  "to": "Feni",          "minPrice": 200 ],
        ["from": "Chattagram",  "to": "Noakhali",      "minPrice": 260 ],
        ["from": "Chattagram",  "to": "Brahmanbaria",  "minPrice": 380 ],

        // Khulna-outbound (5)
        ["from": "Khulna",      "to": "Barisal",       "minPrice": 180 ],
        ["from": "Khulna",      "to": "Jessore",       "minPrice": 150 ],
        ["from": "Khulna",      "to": "Faridpur",      "minPrice": 360 ],
        ["from": "Khulna",      "to": "Rajshahi",      "minPrice": 430 ],
        ["from": "Khulna",      "to": "Kushtia",       "minPrice": 230 ],

        // Rajshahi-outbound (4)
        ["from": "Rajshahi",    "to": "Bogura",        "minPrice": 180 ],
        ["from": "Rajshahi",    "to": "Rangpur",       "minPrice": 320 ],
        ["from": "Rajshahi",    "to": "Dinajpur",      "minPrice": 400 ],
        ["from": "Rajshahi",    "to": "Pabna",         "minPrice": 160 ],

        // Sylhet-outbound (3)
        ["from": "Sylhet",      "to": "Habiganj",      "minPrice": 180 ],
        ["from": "Sylhet",      "to": "Moulvibazar",   "minPrice": 150 ],
        ["from": "Sylhet",      "to": "Brahmanbaria",  "minPrice": 360 ],

        // Rangpur-outbound (2)
        ["from": "Rangpur",     "to": "Dinajpur",      "minPrice": 160 ],
        ["from": "Rangpur",     "to": "Bogura",        "minPrice": 200 ],

        // Mymensingh-outbound (2)
        ["from": "Mymensingh",  "to": "Tangail",       "minPrice": 160 ],
        ["from": "Mymensingh",  "to": "Jamalpur",      "minPrice": 110 ],

        // Barisal-outbound (2)
        ["from": "Barisal",     "to": "Faridpur",      "minPrice": 230 ],
        ["from": "Barisal",     "to": "Madaripur",     "minPrice": 180 ],

        // Comilla-outbound (3)
        ["from": "Comilla",     "to": "Noakhali",      "minPrice": 220 ],
        ["from": "Comilla",     "to": "Feni",          "minPrice": 170 ],
        ["from": "Comilla",     "to": "Chandpur",      "minPrice": 130 ],

        // Reverse & inter-city (6)
        ["from": "Khulna",      "to": "Dhaka",         "minPrice": 700 ],
        ["from": "Sylhet",      "to": "Dhaka",         "minPrice": 750 ],
        ["from": "Rajshahi",    "to": "Dhaka",         "minPrice": 600 ],
        ["from": "Narayanganj", "to": "Chandpur",      "minPrice": 130 ],
        ["from": "Habiganj",    "to": "Moulvibazar",   "minPrice": 130 ],
        ["from": "Feni",        "to": "Noakhali",      "minPrice": 130 ],
    ]

    // MARK: - busTrips (59 documents)
    // Fields: busName, source, destination, departureTime,
    //         arrivalTime, availableSeats, ticketPrice, busType

    private let busTrips: [[String: Any]] = [
        // Dhaka → Chattagram (6)
        ["busName": "Green Line Paribahan", "source": "Dhaka", "destination": "Chattagram", "departureTime": "08:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 22, "ticketPrice": 850,  "busType": "AC"    ],
        ["busName": "Shyamoli Paribahan",   "source": "Dhaka", "destination": "Chattagram", "departureTime": "10:30 AM", "arrivalTime": "04:30 PM", "availableSeats": 20, "ticketPrice": 750,  "busType": "Non-AC"],
        ["busName": "BRTC",                 "source": "Dhaka", "destination": "Chattagram", "departureTime": "11:30 PM", "arrivalTime": "05:30 AM", "availableSeats": 15, "ticketPrice": 1000, "busType": "AC"    ],
        ["busName": "Hanif Enterprise",     "source": "Dhaka", "destination": "Chattagram", "departureTime": "07:00 AM", "arrivalTime": "01:00 PM", "availableSeats": 25, "ticketPrice": 900,  "busType": "AC"    ],
        ["busName": "Soudia Paribahan",     "source": "Dhaka", "destination": "Chattagram", "departureTime": "09:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 18, "ticketPrice": 800,  "busType": "Non-AC"],
        ["busName": "National Travels",     "source": "Dhaka", "destination": "Chattagram", "departureTime": "05:00 PM", "arrivalTime": "11:00 PM", "availableSeats": 22, "ticketPrice": 870,  "busType": "AC"    ],

        // Dhaka → Sylhet (5)
        ["busName": "Ena Transport",        "source": "Dhaka", "destination": "Sylhet",     "departureTime": "08:00 AM", "arrivalTime": "03:00 PM", "availableSeats": 30, "ticketPrice": 900,  "busType": "AC"    ],
        ["busName": "Silk Line",            "source": "Dhaka", "destination": "Sylhet",     "departureTime": "10:00 PM", "arrivalTime": "05:00 AM", "availableSeats": 12, "ticketPrice": 980,  "busType": "AC"    ],
        ["busName": "Shohagh Paribahan",    "source": "Dhaka", "destination": "Sylhet",     "departureTime": "07:30 AM", "arrivalTime": "02:30 PM", "availableSeats": 20, "ticketPrice": 850,  "busType": "Non-AC"],
        ["busName": "SR Travels",           "source": "Dhaka", "destination": "Sylhet",     "departureTime": "03:00 PM", "arrivalTime": "10:00 PM", "availableSeats": 25, "ticketPrice": 920,  "busType": "AC"    ],
        ["busName": "Eagle Paribahan",      "source": "Dhaka", "destination": "Sylhet",     "departureTime": "11:00 PM", "arrivalTime": "06:00 AM", "availableSeats": 10, "ticketPrice": 1050, "busType": "AC"    ],

        // Dhaka → Khulna (5)
        ["busName": "Hanif Enterprise",     "source": "Dhaka", "destination": "Khulna",     "departureTime": "07:00 AM", "arrivalTime": "01:00 PM", "availableSeats": 30, "ticketPrice": 800,  "busType": "AC"    ],
        ["busName": "Shyamoli Paribahan",   "source": "Dhaka", "destination": "Khulna",     "departureTime": "09:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 20, "ticketPrice": 750,  "busType": "Non-AC"],
        ["busName": "Eagle Paribahan",      "source": "Dhaka", "destination": "Khulna",     "departureTime": "08:30 AM", "arrivalTime": "02:30 PM", "availableSeats": 25, "ticketPrice": 850,  "busType": "AC"    ],
        ["busName": "Desh Travels",         "source": "Dhaka", "destination": "Khulna",     "departureTime": "11:00 PM", "arrivalTime": "05:00 AM", "availableSeats": 18, "ticketPrice": 900,  "busType": "AC"    ],
        ["busName": "Meghna Paribahan",     "source": "Dhaka", "destination": "Khulna",     "departureTime": "06:00 PM", "arrivalTime": "12:00 AM", "availableSeats": 22, "ticketPrice": 780,  "busType": "Non-AC"],

        // Dhaka → Rajshahi (4)
        ["busName": "Desh Travels",         "source": "Dhaka", "destination": "Rajshahi",   "departureTime": "07:30 AM", "arrivalTime": "01:30 PM", "availableSeats": 28, "ticketPrice": 700,  "busType": "AC"    ],
        ["busName": "National Travels",     "source": "Dhaka", "destination": "Rajshahi",   "departureTime": "10:00 AM", "arrivalTime": "04:00 PM", "availableSeats": 22, "ticketPrice": 650,  "busType": "Non-AC"],
        ["busName": "Hanif Enterprise",     "source": "Dhaka", "destination": "Rajshahi",   "departureTime": "11:00 PM", "arrivalTime": "05:00 AM", "availableSeats": 15, "ticketPrice": 780,  "busType": "AC"    ],
        ["busName": "BRTC",                 "source": "Dhaka", "destination": "Rajshahi",   "departureTime": "08:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 35, "ticketPrice": 620,  "busType": "Non-AC"],

        // Dhaka → Cox's Bazar (4)
        ["busName": "Green Line Paribahan", "source": "Dhaka", "destination": "Cox's Bazar","departureTime": "10:00 PM", "arrivalTime": "07:00 AM", "availableSeats": 20, "ticketPrice": 1100, "busType": "AC"    ],
        ["busName": "Saintmartin Express",  "source": "Dhaka", "destination": "Cox's Bazar","departureTime": "09:00 PM", "arrivalTime": "06:00 AM", "availableSeats": 25, "ticketPrice": 1200, "busType": "AC"    ],
        ["busName": "Royal Coach",          "source": "Dhaka", "destination": "Cox's Bazar","departureTime": "08:30 PM", "arrivalTime": "05:30 AM", "availableSeats": 18, "ticketPrice": 1300, "busType": "AC"    ],
        ["busName": "Unique Bus Service",   "source": "Dhaka", "destination": "Cox's Bazar","departureTime": "07:00 PM", "arrivalTime": "04:00 AM", "availableSeats": 22, "ticketPrice": 1050, "busType": "Non-AC"],

        // Dhaka → Barisal (3)
        ["busName": "BRTC",                 "source": "Dhaka", "destination": "Barisal",    "departureTime": "08:00 AM", "arrivalTime": "01:00 PM", "availableSeats": 30, "ticketPrice": 580,  "busType": "Non-AC"],
        ["busName": "Desh Travels",         "source": "Dhaka", "destination": "Barisal",    "departureTime": "10:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 20, "ticketPrice": 680,  "busType": "AC"    ],
        ["busName": "Meghna Paribahan",     "source": "Dhaka", "destination": "Barisal",    "departureTime": "07:30 AM", "arrivalTime": "12:30 PM", "availableSeats": 25, "ticketPrice": 560,  "busType": "Non-AC"],

        // Dhaka → Rangpur (3)
        ["busName": "Hanif Enterprise",     "source": "Dhaka", "destination": "Rangpur",    "departureTime": "08:00 AM", "arrivalTime": "03:00 PM", "availableSeats": 25, "ticketPrice": 850,  "busType": "AC"    ],
        ["busName": "National Travels",     "source": "Dhaka", "destination": "Rangpur",    "departureTime": "09:00 PM", "arrivalTime": "04:00 AM", "availableSeats": 20, "ticketPrice": 900,  "busType": "AC"    ],
        ["busName": "Nabil Express",        "source": "Dhaka", "destination": "Rangpur",    "departureTime": "10:00 AM", "arrivalTime": "05:00 PM", "availableSeats": 30, "ticketPrice": 780,  "busType": "Non-AC"],

        // Dhaka → Mymensingh (3)
        ["busName": "Eagle Paribahan",      "source": "Dhaka", "destination": "Mymensingh", "departureTime": "07:30 AM", "arrivalTime": "10:00 AM", "availableSeats": 35, "ticketPrice": 280,  "busType": "Non-AC"],
        ["busName": "Akota Transport",      "source": "Dhaka", "destination": "Mymensingh", "departureTime": "02:00 PM", "arrivalTime": "04:30 PM", "availableSeats": 30, "ticketPrice": 300,  "busType": "AC"    ],
        ["busName": "SR Travels",           "source": "Dhaka", "destination": "Mymensingh", "departureTime": "06:00 PM", "arrivalTime": "08:30 PM", "availableSeats": 28, "ticketPrice": 260,  "busType": "Non-AC"],

        // Dhaka → Comilla (3)
        ["busName": "Shyamoli Paribahan",   "source": "Dhaka", "destination": "Comilla",    "departureTime": "08:00 AM", "arrivalTime": "11:00 AM", "availableSeats": 30, "ticketPrice": 350,  "busType": "Non-AC"],
        ["busName": "Meghna Paribahan",     "source": "Dhaka", "destination": "Comilla",    "departureTime": "12:00 PM", "arrivalTime": "03:00 PM", "availableSeats": 25, "ticketPrice": 320,  "busType": "Non-AC"],
        ["busName": "Green Line Paribahan", "source": "Dhaka", "destination": "Comilla",    "departureTime": "04:00 PM", "arrivalTime": "07:00 PM", "availableSeats": 20, "ticketPrice": 400,  "busType": "AC"    ],

        // Dhaka → Dinajpur (3)
        ["busName": "Hanif Enterprise",     "source": "Dhaka", "destination": "Dinajpur",   "departureTime": "09:00 PM", "arrivalTime": "06:00 AM", "availableSeats": 22, "ticketPrice": 950,  "busType": "AC"    ],
        ["busName": "Nabil Express",        "source": "Dhaka", "destination": "Dinajpur",   "departureTime": "10:00 PM", "arrivalTime": "07:00 AM", "availableSeats": 18, "ticketPrice": 900,  "busType": "Non-AC"],
        ["busName": "National Travels",     "source": "Dhaka", "destination": "Dinajpur",   "departureTime": "08:00 PM", "arrivalTime": "05:00 AM", "availableSeats": 25, "ticketPrice": 1000, "busType": "AC"    ],

        // Chattagram → Cox's Bazar (3)
        ["busName": "Saintmartin Express",  "source": "Chattagram", "destination": "Cox's Bazar", "departureTime": "07:00 AM", "arrivalTime": "11:00 AM", "availableSeats": 30, "ticketPrice": 450, "busType": "AC"    ],
        ["busName": "Royal Coach",          "source": "Chattagram", "destination": "Cox's Bazar", "departureTime": "09:00 AM", "arrivalTime": "01:00 PM", "availableSeats": 25, "ticketPrice": 500, "busType": "AC"    ],
        ["busName": "SR Travels",           "source": "Chattagram", "destination": "Cox's Bazar", "departureTime": "02:00 PM", "arrivalTime": "06:00 PM", "availableSeats": 28, "ticketPrice": 400, "busType": "Non-AC"],

        // Khulna → Dhaka (3)
        ["busName": "Shohagh Paribahan",    "source": "Khulna", "destination": "Dhaka",     "departureTime": "07:00 AM", "arrivalTime": "01:00 PM", "availableSeats": 25, "ticketPrice": 800,  "busType": "Non-AC"],
        ["busName": "Eagle Paribahan",      "source": "Khulna", "destination": "Dhaka",     "departureTime": "09:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 20, "ticketPrice": 850,  "busType": "AC"    ],
        ["busName": "Soudia Paribahan",     "source": "Khulna", "destination": "Dhaka",     "departureTime": "08:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 22, "ticketPrice": 750,  "busType": "Non-AC"],

        // Sylhet → Dhaka (3)
        ["busName": "Ena Transport",        "source": "Sylhet", "destination": "Dhaka",     "departureTime": "08:00 AM", "arrivalTime": "03:00 PM", "availableSeats": 28, "ticketPrice": 900,  "busType": "AC"    ],
        ["busName": "Silk Line",            "source": "Sylhet", "destination": "Dhaka",     "departureTime": "10:00 PM", "arrivalTime": "05:00 AM", "availableSeats": 15, "ticketPrice": 980,  "busType": "AC"    ],
        ["busName": "Desh Travels",         "source": "Sylhet", "destination": "Dhaka",     "departureTime": "07:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 22, "ticketPrice": 840,  "busType": "Non-AC"],

        // Rajshahi → Dhaka (3)
        ["busName": "Desh Travels",         "source": "Rajshahi", "destination": "Dhaka",   "departureTime": "06:30 AM", "arrivalTime": "12:30 PM", "availableSeats": 30, "ticketPrice": 700,  "busType": "AC"    ],
        ["busName": "BRTC",                 "source": "Rajshahi", "destination": "Dhaka",   "departureTime": "09:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 35, "ticketPrice": 620,  "busType": "Non-AC"],
        ["busName": "Nabil Express",        "source": "Rajshahi", "destination": "Dhaka",   "departureTime": "08:30 AM", "arrivalTime": "02:30 PM", "availableSeats": 20, "ticketPrice": 730,  "busType": "AC"    ],

        // Chattagram → Sylhet (2)
        ["busName": "Silk Line",            "source": "Chattagram", "destination": "Sylhet", "departureTime": "07:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 25, "ticketPrice": 750, "busType": "AC"    ],
        ["busName": "Shyamoli Paribahan",   "source": "Chattagram", "destination": "Sylhet", "departureTime": "08:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 20, "ticketPrice": 700, "busType": "Non-AC"],

        // Khulna → Rajshahi (2)
        ["busName": "Akota Transport",      "source": "Khulna", "destination": "Rajshahi",  "departureTime": "08:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 25, "ticketPrice": 580,  "busType": "Non-AC"],
        ["busName": "Meghna Paribahan",     "source": "Khulna", "destination": "Rajshahi",  "departureTime": "09:00 PM", "arrivalTime": "03:00 AM", "availableSeats": 20, "ticketPrice": 620,  "busType": "AC"    ],

        // Barisal → Dhaka (2)
        ["busName": "BRTC",                 "source": "Barisal", "destination": "Dhaka",    "departureTime": "07:00 AM", "arrivalTime": "12:00 PM", "availableSeats": 30, "ticketPrice": 560,  "busType": "Non-AC"],
        ["busName": "Meghna Paribahan",     "source": "Barisal", "destination": "Dhaka",    "departureTime": "05:00 PM", "arrivalTime": "10:00 PM", "availableSeats": 25, "ticketPrice": 600,  "busType": "Non-AC"],

        // Rangpur → Dhaka (2)
        ["busName": "Hanif Enterprise",     "source": "Rangpur", "destination": "Dhaka",    "departureTime": "06:00 PM", "arrivalTime": "01:00 AM", "availableSeats": 25, "ticketPrice": 850,  "busType": "AC"    ],
        ["busName": "Nabil Express",        "source": "Rangpur", "destination": "Dhaka",    "departureTime": "07:00 AM", "arrivalTime": "02:00 PM", "availableSeats": 28, "ticketPrice": 780,  "busType": "Non-AC"],
    ]
}
