//
//  SearchJobsView.swift
//  TheContractor
//
//  Job search screen with filters
//

import SwiftUI

struct SearchJobsView: View {
    @StateObject private var viewModel = SearchJobsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: AppTheme.Spacing.small) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.gray)
                    
                    TextField("Search jobs...", text: $viewModel.searchQuery)
                        .font(AppTheme.Fonts.regular(16))
                }
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
                .padding(AppTheme.Spacing.medium)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        FilterChip(title: "Location", isSelected: viewModel.selectedFilter == "location") {
                            viewModel.selectedFilter = "location"
                        }
                        
                        FilterChip(title: "Job Type", isSelected: viewModel.selectedFilter == "type") {
                            viewModel.selectedFilter = "type"
                        }
                        
                        FilterChip(title: "Category", isSelected: viewModel.selectedFilter == "category") {
                            viewModel.selectedFilter = "category"
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.medium)
                }
                
                Divider()
                
                // Results
                if viewModel.isSearching {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No jobs found matching your search."
                    )
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
                    Spacer()
                    Text("Start typing to search for jobs")
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.small) {
                            ForEach(viewModel.searchResults.indices, id: \.self) { index in
                                JobCard(job: viewModel.searchResults[index]) {
                                    viewModel.selectJob(viewModel.searchResults[index])
                                    presentationMode.wrappedValue.dismiss()
                                }
                                .padding(.horizontal, AppTheme.Spacing.medium)
                            }
                        }
                        .padding(.top, AppTheme.Spacing.medium)
                    }
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Search Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: viewModel.searchQuery) { _ in
                viewModel.performSearch()
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.Colors.primary : Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.Colors.primary, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview
struct SearchJobsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchJobsView()
    }
}
