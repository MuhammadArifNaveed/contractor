//
//  VendorReviewsView.swift
//  TheContractor
//
//  Port of Android's `VendorRating` (drawer item "Rating") — POST vendor/rating with `vendor_id`,
//  response key `rating_enquiries`, rows bound by `VendorRatingAdapter`.
//

import SwiftUI
import SwiftyJSON

struct VendorReviewsView: View {
    @State private var state: VendorLoadState = .loading
    @State private var ratings: [VendorRatingRow] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Rating")

            ZStack {
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                case .noData:
                    Text("Data Not Found")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(ratings) { rating in
                                VendorRatingRowCard(rating: rating)
                            }
                        }
                        .padding(10)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func load() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorRating(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    ratings = json["rating_enquiries"].arrayValue.map(VendorRatingRow.init)
                    state = ratings.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Model

/// Android `VendorRatingModel`, reduced to what `VendorRatingAdapter` binds.
struct VendorRatingRow: Identifiable {
    let id: String
    let name: String
    let surname: String
    let statusName: String
    let color: String
    let createdAt: String
    let rating: Double

    var reviewerName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.statusName = json["s_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        // Android does Float.parseFloat(getRating()) when the field is present and falls back to 0.
        self.rating = json["rating"].double ?? Double(json["rating"].stringValue) ?? 0
    }
}

// MARK: - Card

/// Android `vendor_rating_custom_row.xml`.
struct VendorRatingRowCard: View {
    let rating: VendorRatingRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rating.reviewerName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)

            VendorStarRow(rating: rating.rating)

            Text(VendorHomeStyle.formatDate(rating.createdAt))
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.4))

            VendorStatusBadge(name: rating.statusName, color: rating.color)
                .padding(.top, 3)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

/// Android's read-only `RatingBar`, five stars with half-star precision.
struct VendorStarRow: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { position in
                Image(systemName: symbol(for: position))
                    .font(.system(size: 13))
                    .foregroundColor(VendorHomeStyle.appColor)
            }
        }
    }

    private func symbol(for position: Int) -> String {
        let value = Double(position)
        if rating >= value { return "star.fill" }
        if rating >= value - 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}
