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
    
    // MARK: - Top Section
    private var topSection: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            // Top Categories Horizontal Scroll
            if !viewModel.topCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.topCategories.indices, id: \.self) { index in
                            TopCategoryCard(category: viewModel.topCategories[index]) {
                                viewModel.selectCategory(viewModel.topCategories[index])
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.medium)
                }
            }
            
            // Search Bar
            Button(action: { showSearch = true }) {
                HStack(spacing: AppTheme.Spacing.small) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                    
                    Text("Search for companies")
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                }
                .padding(AppTheme.Spacing.medium)
                .background(Color.white)
                .cornerRadius(AppTheme.CornerRadius.small)
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.bottom, AppTheme.Spacing.medium)
        }
        .padding(.top, AppTheme.Spacing.large)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.primary.opacity(0.15),
                    AppTheme.Colors.primary.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Browse Categories Card
    private var browseCategoriesCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Browse Categories")
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Rectangle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 50, height: 3)
            }
            
            // Categories Grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.medium),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.medium),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.medium)
                ],
                spacing: AppTheme.Spacing.medium
            ) {
                ForEach(viewModel.categories.indices, id: \.self) { index in
                    CategoryCard(category: viewModel.categories[index]) {
                        viewModel.selectCategory(viewModel.categories[index])
                    }
                }
            }
            
            // Divider
            if viewModel.selectedCategory != nil {
                Divider()
                    .padding(.vertical, AppTheme.Spacing.small)
            }
            
            // Subcategories Grid (if category selected)
            if let selectedCategory = viewModel.selectedCategory,
               !selectedCategory.sub_categories.subCategoryList.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppTheme.Spacing.small),
                        GridItem(.flexible(), spacing: AppTheme.Spacing.small)
                    ],
                    spacing: AppTheme.Spacing.small
                ) {
                    ForEach(selectedCategory.sub_categories.subCategoryList.indices, id: \.self) { index in
                        SubCategoryCard(
                            subCategory: selectedCategory.sub_categories.subCategoryList[index]
                        ) {
                            viewModel.selectSubCategory(selectedCategory.sub_categories.subCategoryList[index])
                        }
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.small)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.top, AppTheme.Spacing.large)
    }
    
    // MARK: - Companies Section
    private func companiesSection(title: String, companies: [CompanyViewModel]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Rectangle()
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 50, height: 3)
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            
            // Companies List
            VStack(spacing: AppTheme.Spacing.small) {
                ForEach(companies.indices, id: \.self) { index in
                    CompanyCard(company: companies[index]) {
                        viewModel.selectCompany(companies[index])
                    }
                    .padding(.horizontal, AppTheme.Spacing.medium)
                }
            }
        }
        .padding(.top, AppTheme.Spacing.medium)
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
