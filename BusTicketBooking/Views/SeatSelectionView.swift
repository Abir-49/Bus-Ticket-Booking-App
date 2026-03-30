//
//  SeatSelectionView.swift
//  BusTicketBooking
//
//  Created by macos on 5/3/26.
//

import SwiftUI
import FirebaseAuth

struct SeatSelectionView: View {

    let trip: BusTrip

    private let columns = 4          // seats per row (2 + aisle + 2)
    private let totalRows = 10
    private let rowLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]

    @State private var selectedSeats: Set<Int> = [] // Store indices (0-39)
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var bookingSuccess = false
    @State private var showSuccessAlert = false

    @StateObject private var bookingViewModel = BookingViewModel()
    @Environment(\.presentationMode) var presentationMode

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
                                // Left side (2 seats)
                                seatButton(seatIndex: row * columns + 0)
                                seatButton(seatIndex: row * columns + 1)

                                // Aisle
                                Spacer()
                                    .frame(width: 28)

                                // Right side (2 seats)
                                seatButton(seatIndex: row * columns + 2)
                                seatButton(seatIndex: row * columns + 3)
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
                                Text(selectedSeats.sorted().map { SeatHelper.indexToLabel($0) }.joined(separator: ", "))
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
                    
                    if let errorMessage = errorMessage {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }

            // Confirm button
            Button(action: confirmBooking) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(selectedSeats.isEmpty
                         ? "Select a Seat"
                         : "Confirm  •  ৳\(selectedSeats.count * trip.ticketPrice)")
                        .bold()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedSeats.isEmpty ? Color.gray : Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(14)
            .disabled(selectedSeats.isEmpty || isLoading)
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Select Seat")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Booking Successful", isPresented: $showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your seats have been booked successfully!")
        }
    }

    // MARK: - Helpers

    private func isSeatBooked(_ index: Int) -> Bool {
        return SeatHelper.isSeatBooked(index, in: trip.seatMatrix)
    }

    private func confirmBooking() {
        guard !selectedSeats.isEmpty else { return }
        
        // Get current user
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let selectedIndices = Array(selectedSeats).sorted()
        let totalPrice = selectedIndices.count * trip.ticketPrice
        
        Task {
            let success = await bookingViewModel.bookSeats(
                selectedIndices,
                for: trip,
                userId: userId,
                totalPrice: totalPrice
            )
            
            if success {
                bookingSuccess = true
                showSuccessAlert = true
            } else {
                errorMessage = bookingViewModel.errorMessage ?? "Failed to book seats"
            }
            isLoading = false
        }
    }

    @ViewBuilder
    private func seatButton(seatIndex: Int) -> some View {
        let booked = isSeatBooked(seatIndex)
        let selected = selectedSeats.contains(seatIndex)
        let seatLabel = SeatHelper.indexToLabel(seatIndex)

        Button {
            if !booked {
                if selected {
                    selectedSeats.remove(seatIndex)
                } else {
                    selectedSeats.insert(seatIndex)
                }
            }
        } label: {
            Text(seatLabel)
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

