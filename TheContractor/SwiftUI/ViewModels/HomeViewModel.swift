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
        
        // Call the API endpoint directly to get JSON
        let completeURL = "https://contractor.bidcont.com/rest/Home/home_page"
        LoginService.shared().makeGetAPICall(with: completeURL, params: [:]) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    // Parse categories using CategoryListViewModel
                    let categoryList = CategoryListViewModel(list: json["categories"])
                    self?.categories = categoryList.categoryList
                    self?.topCategories = Array(categoryList.categoryList.prefix(6))
                    
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
