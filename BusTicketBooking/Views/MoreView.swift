//
//  MoreView.swift
//  BusTicketBooking
//
//  Created by macos on 26/2/26.
//

import SwiftUI

struct MoreView: View {

    @ObservedObject private var seedService = SeedService.shared

    var body: some View {
        NavigationView {
            List {
                // ── Admin / Developer Section ────────────────────────────
                Section(header: Text("Developer Tools")) {
                    seedRow
                }

                // ── App Info ──────────────────────────────────────────────
                Section(header: Text("About")) {
                    LabeledContent("App Version", value: "1.0.0")
                    LabeledContent("Build",       value: "1")
                }
            }
            .navigationTitle("More")
        }
    }

    // MARK: - Seed Row

    @ViewBuilder
    private var seedRow: some View {
        switch seedService.status {
        case .idle:
            Button {
                seedService.forceSeed()
            } label: {
                Label("Seed Firestore Database", systemImage: "arrow.up.circle")
            }

        case .running:
            HStack {
                ProgressView()
                    .padding(.trailing, 8)
                Text("Seeding data…")
                    .foregroundColor(.secondary)
            }

        case .done(let message):
            VStack(alignment: .leading, spacing: 4) {
                Label("Seeding complete", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Button("Seed Again") {
                seedService.forceSeed()
            }
            .font(.caption)
            .foregroundColor(.orange)

        case .failed(let message):
            VStack(alignment: .leading, spacing: 4) {
                Label("Seeding failed", systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Button("Retry") {
                seedService.forceSeed()
            }
            .font(.caption)
        }
    }
}
