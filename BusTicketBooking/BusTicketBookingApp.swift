//
//  BusTicketBookingApp.swift
//  BusTicketBooking
//
//  Created by macos on 26/2/26.
//

import SwiftUI
import FirebaseCore

@main
struct BusTicketBookingApp: App {
    
    init() {
        FirebaseApp.configure()
        // Auto-seed on the very first launch.
        // SeedService checks UserDefaults so it will never run twice.
        Task { @MainActor in
            SeedService.shared.seedIfNeeded()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
