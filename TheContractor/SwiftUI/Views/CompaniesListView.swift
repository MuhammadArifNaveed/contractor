//
//  CompaniesListView.swift
//  TheContractor
//
//  Companies list screen matching Android Companies activity
//

import SwiftUI

struct CompaniesListView: View {
    @StateObject private var viewModel: CompaniesListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let categoryId: String?
    let subCategoryId: String?
    let title: String
    
    init(categoryId: String? = nil, subCategoryId: String? = nil, title: String = "Companies") {
        self.categoryId = categoryId
        self.subCategoryId = subCategoryId
        self.title = title
        _viewModel = StateObject(wrappedValue: CompaniesListViewModel(
            categoryId: categoryId,
            subCategoryId: subCategoryId
        ))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.companies.isEmpty {
                LoadingView(message: "Loading companies...")
            } else if let error = viewModel.errorMessage, viewModel.companies.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadCompanies()
                }
            } else if viewModel.companies.isEmpty {
                EmptyStateView(
                    icon: "building.2",
                    title: "No Companies",
                    message: "No companies found for this category."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.companies.indices, id: \.self) { index in
                            CompanyCard(company: viewModel.companies[index]) {
                                viewModel.selectCompany(viewModel.companies[index])
                            }
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            
                            // Pagination trigger
                            if index == viewModel.companies.count - 2 {
                                Color.clear
                                    .frame(height: 1)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded()
                                    }
                            }
                        }
                        
                        // Loading more indicator
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top, AppTheme.Spacing.medium)
                }
                .background(AppTheme.Colors.background)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.companies.isEmpty {
                viewModel.loadCompanies()
            }
        }
    }
}

// MARK: - Preview
struct CompaniesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompaniesListView(categoryId: "1", title: "Construction Companies")
        }
    }
}
