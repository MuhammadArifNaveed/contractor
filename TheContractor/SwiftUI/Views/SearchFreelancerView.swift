//
//  SearchFreelancerView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct SearchFreelancerView: View {
    @StateObject private var searchFilter = FreelancerSearchFilter()
    @Environment(\.dismiss) private var dismiss
    @State private var showCategoryPicker = false
    @State private var showCityPicker = false
    
    var onSearch: (FreelancerSearchFilter) -> Void
    
    // Sample data for dropdowns
    private let categories = ["Consultants", "Construction", "Decor", "Maintenance"]
    private let cities = ["Dubai", "Sharjah", "Ajman", "Ras Al Khaimah", "Al Ain", "Fujairah", "Umm Al Quwain", "Abu Dhabi"]
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                navigationBar
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        // Search Skills TextField
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                            TextField("", text: $searchFilter.skills)
                                .placeholder(when: searchFilter.skills.isEmpty) {
                                    Text("Search Skills")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                .font(AppTheme.Fonts.body)
                                .outlinedTextField()
                        }
                        
                        // Enter Rate TextField
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                            TextField("", text: $searchFilter.rate)
                                .placeholder(when: searchFilter.rate.isEmpty) {
                                    Text("Enter Rate")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                .keyboardType(.decimalPad)
                                .font(AppTheme.Fonts.body)
                                .outlinedTextField()
                        }
                        
                        // Select Category Dropdown
                        Button(action: {
                            showCategoryPicker = true
                        }) {
                            HStack {
                                Text(searchFilter.selectedCategory.isEmpty ? "Select Category" : searchFilter.selectedCategory)
                                    .foregroundColor(searchFilter.selectedCategory.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                                    .font(AppTheme.Fonts.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppTheme.CornerRadius.small)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                    .stroke(AppTheme.Colors.border, lineWidth: 1.5)
                            )
                        }
                        
                        // Select City Dropdown
                        Button(action: {
                            showCityPicker = true
                        }) {
                            HStack {
                                Text(searchFilter.selectedCity.isEmpty ? "Select City" : searchFilter.selectedCity)
                                    .foregroundColor(searchFilter.selectedCity.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                                    .font(AppTheme.Fonts.body)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppTheme.CornerRadius.small)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                    .stroke(AppTheme.Colors.border, lineWidth: 1.5)
                            )
                        }
                        
                        // Search Button
                        Button(action: {
                            onSearch(searchFilter)
                            dismiss()
                        }) {
                            Text("Search")
                        }
                        .buttonStyle(PrimaryButtonStyle(isEnabled: true))
                        .padding(.top, AppTheme.Spacing.medium)
                    }
                    .padding(AppTheme.Spacing.large)
                }
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Select Category", isPresented: $showCategoryPicker, titleVisibility: .visible) {
            ForEach(categories, id: \.self) { category in
                Button(category) {
                    searchFilter.selectedCategory = category
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Select City", isPresented: $showCityPicker, titleVisibility: .visible) {
            ForEach(cities, id: \.self) { city in
                Button(city) {
                    searchFilter.selectedCity = city
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Text("Search Freelancer")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchFreelancerView_Previews: PreviewProvider {
    static var previews: some View {
        SearchFreelancerView { _ in }
    }
}
