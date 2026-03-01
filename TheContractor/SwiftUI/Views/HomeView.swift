//
//  HomeView.swift
//  TheContractor
//
//  Complete Home screen matching Android HomeFragment
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView(message: "Loading home data...")
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    viewModel.loadHomeData()
                }
            } else if viewModel.categories.isEmpty {
                EmptyStateView(
                    icon: "house.fill",
                    title: "No Data",
                    message: "No content available at the moment."
                )
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Top Section with gradient background
                        topSection
                        
                        // Browse Categories Card
                        browseCategoriesCard
                        
                        // Titanium Companies Section
                        if !viewModel.titaniumCompanies.isEmpty {
                            companiesSection(
                                title: "Titanium Companies",
                                companies: viewModel.titaniumCompanies
                            )
                        }
                        
                        // Top Companies Section
                        if !viewModel.topCompanies.isEmpty {
                            companiesSection(
                                title: "Top Companies",
                                companies: viewModel.topCompanies
                            )
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
                .background(AppTheme.Colors.background)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadHomeData()
        }
        .sheet(isPresented: $showSearch) {
            SearchCompaniesView()
        }
    }
    
    // MARK: - Top Section (Android style)
    private var topSection: some View {
        VStack(spacing: 16) {
            // Top Categories - Horizontal Text-Only Pills (Android style)
            if !viewModel.topCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.topCategories.indices, id: \.self) { index in
                            Text(viewModel.topCategories[index].name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(20)
                                .onTapGesture {
                                    viewModel.selectCategory(viewModel.topCategories[index])
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
            }
            
            // Search Bar
            Button(action: { showSearch = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                    
                    Text("Search for companies")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                }
                .padding(15)
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(red: 242/255, green: 190/255, blue: 54/255))
    }
    
    // MARK: - Browse Categories Card (Android style)
    private var browseCategoriesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Browse Categories")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Rectangle()
                    .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                    .frame(width: 50, height: 3)
            }
            .padding(.horizontal, 10)
            
            // Categories - Horizontal Scrolling Tabs (Android style, text-only)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.categories.indices, id: \.self) { index in
                        let category = viewModel.categories[index]
                        let isSelected = viewModel.selectedCategory?.id == category.id
                        
                        VStack(spacing: 4) {
                            Text(category.name)
                                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                .foregroundColor(.black)
                            
                            if isSelected {
                                Rectangle()
                                    .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                                    .frame(height: 3)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                        .onTapGesture {
                            viewModel.selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .padding(.top, 10)
            
            // Divider
            if viewModel.selectedCategory != nil {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
                    .padding(.vertical, 10)
            }
            
            // Subcategories - 2 Column Grid (Android style, text-only)
            if let selectedCategory = viewModel.selectedCategory,
               !selectedCategory.sub_categories.subCategoryList.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(selectedCategory.sub_categories.subCategoryList.indices, id: \.self) { index in
                        Text(selectedCategory.sub_categories.subCategoryList[index].name)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .onTapGesture {
                                viewModel.selectSubCategory(selectedCategory.sub_categories.subCategoryList[index])
                            }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 10)
        .padding(.top, 20)
    }
    
    // MARK: - Companies Section (Android style)
    private func companiesSection(title: String, companies: [CompanyViewModel]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                
                Rectangle()
                    .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                    .frame(width: 50, height: 3)
            }
            .padding(.horizontal, 10)
            
            // Companies - Horizontal Scroll for Titanium, Vertical for Top
            if title == "Titanium Companies" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(companies.indices, id: \.self) { index in
                            CompanyCard(company: companies[index]) {
                                viewModel.selectCompany(companies[index])
                            }
                            .frame(width: 150)
                        }
                    }
                    .padding(.horizontal, 10)
                }
            } else {
                // Vertical list for Top Companies
                VStack(spacing: 10) {
                    ForEach(companies.indices, id: \.self) { index in
                        CompanyCard(company: companies[index]) {
                            viewModel.selectCompany(companies[index])
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Top Category Card
struct TopCategoryCard: View {
    let category: CategoryViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                AsyncImage(url: URL(string: category.icon)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "square.grid.2x2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(AppTheme.Colors.gray)
                }
                .frame(width: 50, height: 50)
                
                Text(category.name)
                    .font(AppTheme.Fonts.medium(12))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - SubCategory Card
struct SubCategoryCard: View {
    let subCategory: SubCategoryViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(subCategory.name)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.gray)
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
