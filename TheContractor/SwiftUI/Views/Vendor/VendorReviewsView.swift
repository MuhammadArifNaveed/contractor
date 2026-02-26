//  VendorReviewsView.swift
import SwiftUI
struct VendorReviewsView: View {
    @StateObject private var viewModel = VendorReviewsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.reviews.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.reviews.isEmpty { EmptyStateView(icon: "star", title: "No Reviews", message: "No reviews yet") }
            else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            VStack {
                                Text(viewModel.averageRating).font(AppTheme.Fonts.bold(40))
                                RatingView(rating: Double(viewModel.averageRating) ?? 0, size: 16)
                                Text("\(viewModel.totalReviews) reviews").font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                            }
                        }
                        .padding(20).background(AppTheme.Colors.secondaryBackground).cornerRadius(12)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.reviews.indices, id: \.self) { i in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(viewModel.reviews[i].userName).font(AppTheme.Fonts.semibold(16))
                                        Spacer()
                                        RatingView(rating: Double(viewModel.reviews[i].rating) ?? 0, size: 14)
                                    }
                                    Text(viewModel.reviews[i].comment).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                                    Text(viewModel.reviews[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                                }
                                .padding(12).background(Color.white).cornerRadius(8)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Reviews")
        .onAppear { viewModel.loadReviews() }
    }
}
class VendorReviewsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var reviews: [VendorReview] = []
    @Published var averageRating = "0.0"
    @Published var totalReviews = "0"
    func loadReviews() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_reviews", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    self?.averageRating = json?["average_rating"].stringValue ?? "0.0"
                    self?.totalReviews = json?["total_reviews"].stringValue ?? "0"
                    if let arr = json?["reviews"].array {
                        self?.reviews = arr.map { VendorReview(id: $0["id"].stringValue, userName: $0["user_name"].stringValue, rating: $0["rating"].stringValue, comment: $0["comment"].stringValue, date: $0["date"].stringValue) }
                    }
                }
            }
        }
    }
}
struct VendorReview: Identifiable { let id, userName, rating, comment, date: String }
