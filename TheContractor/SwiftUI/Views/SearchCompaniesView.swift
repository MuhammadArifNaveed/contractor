//
//  SearchCompaniesView.swift
//  TheContractor
//
//  Search companies screen matching Android Search activity
//

import SwiftUI

struct SearchCompaniesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var selectedCity: String = ""
    @State private var selectedArea: String = ""
    @State private var selectedCategory: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(spacing: AppTheme.Spacing.medium) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search companies...")
                    
                    // Filter Buttons Row
                    HStack(spacing: AppTheme.Spacing.small) {
                        FilterButton(title: "City", value: selectedCity) {
                            // Show city picker
                        }
                        
                        FilterButton(title: "Area", value: selectedArea) {
                            // Show area picker
                        }
                        
                        FilterButton(title: "Category", value: selectedCategory) {
                            // Show category picker
                        }
                    }
                }
                .padding(AppTheme.Spacing.medium)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                
                // Search Results
                ScrollView {
                    if searchText.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "Search Companies",
                            message: "Enter keywords to find companies"
                        )
                        .padding(.top, 60)
                    } else {
                        // TODO: Display search results
                        Text("Searching for: \(searchText)")
                            .padding()
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(value.isEmpty ? title : value)
                    .font(AppTheme.Fonts.regular(13))
                    .foregroundColor(value.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.primary)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(value.isEmpty ? Color.clear : AppTheme.Colors.primary, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
struct SearchCompaniesView_Previews: PreviewProvider {
    static var previews: some View {
        SearchCompaniesView()
    }
}
