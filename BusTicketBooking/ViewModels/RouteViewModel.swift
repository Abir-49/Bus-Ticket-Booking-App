//
//  RouteViewModel.swift
//  BusTicketBooking
//
//  Created by macos on 4/3/26.
//

import Foundation
import FirebaseFirestore

@MainActor
class RouteViewModel: ObservableObject {
    @Published var popularRoutes: [Route] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // Fetches popular routes from the "popularRoutes" collection.
    // Ordered by minPrice ascending; limited to 6 cards on the home screen.
    func fetchPopularRoutes() {
        isLoading = true
        errorMessage = nil

        db.collection("popularRoutes")
            .order(by: "minPrice")
            .limit(to: 6)
            .getDocuments { [weak self] snapshot, error in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = "Unable to load routes: \(error.localizedDescription)"
                        return
                    }

                    self.popularRoutes = snapshot?.documents.compactMap { doc in
                        Route(documentID: doc.documentID, data: doc.data())
                    } ?? []
                }
            }
    }
}
