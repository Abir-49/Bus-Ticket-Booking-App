//
//  SeatSelectionView.swift
//  BusTicketBooking
//
//  Created by macos on 5/3/26.
//

import SwiftUI

struct SeatSelectionView: View {

    let trip: BusTrip

    private let columns = 4          // seats per row (2 + aisle + 2)
    private let totalRows = 10

    @State private var selectedSeats: Set<Int> = []

    var body: some View {
        VStack(spacing: 0) {

            // Trip summary header
            VStack(spacing: 4) {
                Text(trip.busName)
                    .font(.headline)
                Text("\(trip.source) → \(trip.destination)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.cardBackground)

            ScrollView {
                VStack(spacing: 20) {

                    // Legend
                    HStack(spacing: 20) {
                        legendItem(color: .gray.opacity(0.25), label: "Available")
                        legendItem(color: Theme.primaryColor, label: "Selected")
                        legendItem(color: Theme.dangerColor.opacity(0.4), label: "Booked")
                    }
                    .padding(.top)

                    // Seat grid
                    VStack(spacing: 10) {
                        // Driver row
                        HStack {
                            Spacer()
                            Image(systemName: "steeringwheel")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                        .padding(.bottom, 4)

                        ForEach(0..<totalRows, id: \.self) { row in
                            HStack(spacing: 8) {
                                seatButton(seatNumber: row * columns + 1)
                                seatButton(seatNumber: row * columns + 2)

                                // Aisle
                                Spacer()
                                    .frame(width: 28)

                                seatButton(seatNumber: row * columns + 3)
                                seatButton(seatNumber: row * columns + 4)
                            }
                        }
                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(16)

                    // Selection summary
                    if !selectedSeats.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Selected Seats")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(selectedSeats.sorted().map { "\($0)" }.joined(separator: ", "))
                                    .font(.subheadline)
                                    .bold()
                            }
                            HStack {
                                Text("Total Price")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("৳\(selectedSeats.count * trip.ticketPrice)")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Theme.primaryColor)
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }

            // Confirm button
            Button(action: {
                // Confirm booking action placeholder
            }) {
                Text(selectedSeats.isEmpty
                     ? "Select a Seat"
                     : "Confirm  •  ৳\(selectedSeats.count * trip.ticketPrice)")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedSeats.isEmpty ? Color.gray : Theme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .disabled(selectedSeats.isEmpty)
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Select Seat")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func isSeatBooked(_ number: Int) -> Bool {
        // Seats beyond available count are marked booked
        number > trip.availableSeats
    }

    @ViewBuilder
    private func seatButton(seatNumber: Int) -> some View {
        let booked = isSeatBooked(seatNumber)
        let selected = selectedSeats.contains(seatNumber)

        Button {
            if !booked {
                if selected {
                    selectedSeats.remove(seatNumber)
                } else {
                    selectedSeats.insert(seatNumber)
                }
            }
        } label: {
            Text("\(seatNumber)")
                .font(.caption)
                .bold()
                .frame(width: 42, height: 42)
                .background(
                    booked ? Theme.dangerColor.opacity(0.4)
                    : selected ? Theme.primaryColor
                    : Color.gray.opacity(0.25)
                )
                .foregroundColor(booked || selected ? .white : .primary)
                .cornerRadius(8)
        }
        .disabled(booked)
    }

    @ViewBuilder
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 18, height: 18)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
