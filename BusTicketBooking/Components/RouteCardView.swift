//
//  RouteCardView.swift
//  BusTicketBooking
//
//  Created by macos on 26/2/26.
//

import SwiftUI

struct RouteCardView: View {

    let route: Route
    var onBook: (() -> Void)? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(route.from) → \(route.to)")
                    .bold()
                Text(route.displayPrice)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button("Book") {
                onBook?()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
        .padding(.vertical, 5)
    }
}
