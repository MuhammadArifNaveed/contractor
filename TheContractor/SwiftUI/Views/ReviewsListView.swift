//
//  ReviewsListView.swift
//  TheContractor
//
//  Reviews list screen for company
//

import SwiftUI

struct ReviewsListView: View {
    @StateObject private var viewModel: ReviewsListViewModel
    @State private var showAddReview = false
    
    init(companyId: String, companyName: String) {
        _viewModel = StateObject(wrappedValue: ReviewsListViewModel(companyId: companyId, companyName: companyName))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.reviews.isEmpty {
                LoadingView(message: "Loading reviews...")
            } else if let error = viewModel.errorMessage, viewModel.reviews.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadReviews()
                }
            } else if viewModel.reviews.isEmpty {
                EmptyStateView(
                    icon: "star",
                    title: "No Reviews",
                    message: "No reviews for this company yet."
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        // Rating Summary
                        ratingsSummary
                        
                        // Reviews List
                        LazyVStack(spacing: AppTheme.Spacing.small) {
                            ForEach(viewModel.reviews.indices, id: \.self) { index in
                                ReviewCard(review: viewModel.reviews[index])
                                    .padding(.horizontal, AppTheme.Spacing.medium)
                                
                                if index == viewModel.reviews.count - 2 {
                                    Color.clear
                                        .frame(height: 1)
                                        .onAppear {
                                            viewModel.loadMoreIfNeeded()
                                        }
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
                .background(AppTheme.Colors.background)
            }
        }
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddReview = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(companyId: viewModel.companyId, companyName: viewModel.companyName)
        }
        .onAppear {
            if viewModel.reviews.isEmpty {
                viewModel.loadReviews()
            }
        }
    }
    
    // MARK: - Ratings Summary
    private var ratingsSummary: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack(spacing: AppTheme.Spacing.large) {
                VStack {
                    Text(viewModel.averageRating)
                        .font(AppTheme.Fonts.bold(40))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    RatingView(rating: Double(viewModel.averageRating) ?? 0.0, size: 20)
                    
                    Text("\(viewModel.totalReviews) reviews")
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.top, AppTheme.Spacing.medium)
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: ReviewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review.userName)
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    RatingView(rating: Double(review.rating) ?? 0.0, size: 14)
                }
                
                Spacer()
                
                Text(review.date)
                    .font(AppTheme.Fonts.regular(12))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Review Model
struct ReviewModel: Identifiable {
    let id: String
    let userName: String
    let rating: String
    let comment: String
    let date: String
    
    init() {
        self.id = ""
        self.userName = ""
        self.rating = "0"
        self.comment = ""
        self.date = ""
    }
    
    init(id: String, userName: String, rating: String, comment: String, date: String) {
        self.id = id
        self.userName = userName
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}

// MARK: - Preview
struct ReviewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReviewsListView(companyId: "1", companyName: "Test Company")
        }
    }
}
