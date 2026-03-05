//
//  Theme.swift
//  BusTicketBooking
//
//  Created by macos on 26/2/26.
//

import SwiftUI

struct Theme {
    
    // MARK: - Primary Color (Purple)
    static var primaryColor: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 210/255, green: 190/255, blue: 255/255, alpha: 1.0) // Light purple
            : UIColor(red: 95/255, green: 40/255, blue: 160/255, alpha: 1.0)   // Deep purple
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 210/255, green: 190/255, blue: 255/255, alpha: 1.0)
            : NSColor(red: 95/255, green: 40/255, blue: 160/255, alpha: 1.0)
        }))
        #endif
    }

    // MARK: - Secondary Color (Blue)
    static var secondaryColor1: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 130/255, green: 200/255, blue: 255/255, alpha: 1.0) // Light blue
            : UIColor(red: 0/255, green: 90/255, blue: 180/255, alpha: 1.0)    // Deep blue
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 130/255, green: 200/255, blue: 255/255, alpha: 1.0)
            : NSColor(red: 0/255, green: 90/255, blue: 180/255, alpha: 1.0)
        }))
        #endif
    }

    // MARK: - Success Color (Green)
    static var secondaryColor2: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 130/255, green: 230/255, blue: 160/255, alpha: 1.0) // Light green
            : UIColor(red: 0/255, green: 120/255, blue: 70/255, alpha: 1.0)    // Deep green
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 130/255, green: 230/255, blue: 160/255, alpha: 1.0)
            : NSColor(red: 0/255, green: 120/255, blue: 70/255, alpha: 1.0)
        }))
        #endif
    }

    // MARK: - Danger Color (Red)
    static var dangerColor: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 255/255, green: 150/255, blue: 150/255, alpha: 1.0)
            : UIColor(red: 180/255, green: 0/255, blue: 0/255, alpha: 1.0)
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 255/255, green: 150/255, blue: 150/255, alpha: 1.0)
            : NSColor(red: 180/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }))
        #endif
    }

    // MARK: - Legacy aliases (for compatibility)

    @available(*, deprecated, message: "Use primaryColor instead")
    static var primaryMaroon: Color { primaryColor }

    @available(*, deprecated, message: "Use secondaryColor1 instead")
    static var lightMaroon: Color { secondaryColor1 }

    @available(*, deprecated, message: "Use secondaryColor2 instead")
    static var accent: Color { secondaryColor2 }

    // MARK: - Background

    static var background: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 10/255, green: 12/255, blue: 30/255, alpha: 1.0)
            : UIColor(red: 250/255, green: 249/255, blue: 252/255, alpha: 1.0)
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 10/255, green: 12/255, blue: 30/255, alpha: 1.0)
            : NSColor(red: 250/255, green: 249/255, blue: 252/255, alpha: 1.0)
        }))
        #endif
    }

    // Alias
    static var adaptiveBackground: Color { background }

    // MARK: - Card Background

    static var cardBackground: Color {
        #if os(iOS)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 20/255, green: 24/255, blue: 42/255, alpha: 1.0)
            : UIColor.white
        })
        #else
        return Color(NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(red: 20/255, green: 24/255, blue: 42/255, alpha: 1.0)
            : NSColor.white
        }))
        #endif
    }
}
