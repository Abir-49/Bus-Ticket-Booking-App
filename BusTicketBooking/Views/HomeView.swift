//
//  HomeView.swift
//  BusTicketBooking
//
//  Created by macos on 26/2/26.
//

import SwiftUI

struct HomeView: View {

    @State private var fromCity = ""
    @State private var toCity = ""
    @State private var selectedDate = Date()
    @State private var navigateToResults = false

    @StateObject private var routeViewModel = RouteViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    BannerView()

                    // MARK: Search Card
                    VStack(spacing: 15) {

                        TextField("From (e.g. Dhaka)", text: $fromCity)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                            .autocorrectionDisabled()

                        TextField("To (e.g. Chattagram)", text: $toCity)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                            .autocorrectionDisabled()

                        DatePicker("Travel Date",
                                   selection: $selectedDate,
                                   in: Date()...,
                                   displayedComponents: .date)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(12)

                        Button(action: {
                            navigateToResults = true
                        }) {
                            Text("Search Buses")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primaryMaroon)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .navigationDestination(isPresented: $navigateToResults) {
                            BusListView(
                                fromCity: fromCity,
                                toCity: toCity,
                                travelDate: selectedDate
                            )
                        }

                    }
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.2), radius: 10)

                    // MARK: Popular Routes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Popular Routes")
                            .font(.title3)
                            .bold()
                            .padding(.bottom, 2)

                        if routeViewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if let err = routeViewModel.errorMessage {
                            Text(err)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 4)
                        } else if routeViewModel.popularRoutes.isEmpty {
                            Text("No popular routes available.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.horizontal, 4)
                        } else {
                            ForEach(routeViewModel.popularRoutes) { route in
                                RouteCardView(route: route) {
                                    fromCity = route.from
                                    toCity = route.to
                                    navigateToResults = true
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Bus Booking")
            .onAppear {
                if routeViewModel.popularRoutes.isEmpty {
                    routeViewModel.fetchPopularRoutes()
                }
            }
        }
    }
}
