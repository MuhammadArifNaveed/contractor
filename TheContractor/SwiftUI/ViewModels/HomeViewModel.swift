//
//  HomeViewModel.swift
//  TheContractor
//
//  ViewModel for Home screen with API integration
//

import SwiftUI
import Combine
import SwiftyJSON

class HomeViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var topCategories: [CategoryViewModel] = []
    @Published var categories: [CategoryViewModel] = []
    @Published var selectedCategory: CategoryViewModel?
    @Published var titaniumCompanies: [CompanyViewModel] = []
    @Published var topCompanies: [CompanyViewModel] = []
    
    func loadHomeData() {
        isLoading = true
        errorMessage = nil
        
        // Use the correct endpoint matching Android app
        let completeURL = EndPoints.BASE_URL + EndPoints.home
        LoginService.shared().makeGetAPICall(with: completeURL, params: [:]) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    // Parse categories using CategoryListViewModel
                    let categoryList = CategoryListViewModel(list: json["categories"])
                    self?.categories = categoryList.categoryList
                    self?.topCategories = Array(categoryList.categoryList.prefix(6))
                    
                    // Set "Consultants" as default selected category (matching Android)
                    if let consultantsCategory = categoryList.categoryList.first(where: { $0.name.lowercased().contains("consultant") }) {
                        self?.selectedCategory = consultantsCategory
                    } else if !categoryList.categoryList.isEmpty {
                        self?.selectedCategory = categoryList.categoryList.first
                    }
                    
                    // Parse companies using CompanyListViewModel
                    let companyList = CompanyListViewModel(list: json["companies_list"])
                    self?.topCompanies = companyList.companyList
                    
                    // Parse titanium companies
                    let titaniumList = CompanyListViewModel(list: json["titanium_companies"])
                    self?.titaniumCompanies = titaniumList.companyList
                } else {
                    self?.errorMessage = message ?? "Failed to load home data"
                }
            }
        }
    }
    
    func selectCategory(_ category: CategoryViewModel) {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
    
    func selectSubCategory(_ subCategory: SubCategoryViewModel) {
        // Navigate to companies by subcategory
        // TODO: Implement navigation
        print("Selected subcategory: \(subCategory.name)")
    }
    
    func selectCompany(_ company: CompanyViewModel) {
        // Navigate to company details
        // TODO: Implement navigation
        print("Selected company: \(company.company_name)")
    }
}
