//
//  BusCardView.swift
//  BusTicketBooking
//
//  Created by macos on 4/3/26.
//

import SwiftUI

struct BusCardView: View {

    let trip: BusTrip

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Bus name & type badge
            HStack {
                Text(trip.busName)
                    .font(.headline)

                Spacer()

                Text(trip.busType)
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.primaryMaroon.opacity(0.15))
                    .foregroundColor(Theme.primaryMaroon)
                    .cornerRadius(6)
            }

            // Times row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.departureTime)
                        .font(.subheadline)
                        .bold()
                    Text(trip.source)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(trip.duration)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(trip.arrivalTime)
                        .font(.subheadline)
                        .bold()
                    Text(trip.destination)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // Seats & Price
            HStack {
                Label("\(trip.availableSeats) seats", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(trip.availableSeats <= 5 ? .red : .green)

                Spacer()

                Text(trip.priceFormatted)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Theme.primaryMaroon)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}
