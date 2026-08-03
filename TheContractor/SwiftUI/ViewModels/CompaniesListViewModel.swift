//
//  CompaniesListViewModel.swift
//  TheContractor
//
//  ViewModel for Companies list with pagination
//

import SwiftUI
import Combine
import SwiftyJSON

class CompaniesListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var companies: [CompanyViewModel] = []
    
    private let categoryId: String?
    private let subCategoryId: String?
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true
    
    init(categoryId: String? = nil, subCategoryId: String? = nil) {
        self.categoryId = categoryId
        self.subCategoryId = subCategoryId
    }
    
    func loadCompanies(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            companies.removeAll()
            canLoadMore = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Android's part is `page`.
        var params: [String: String] = ["page": "\(currentPage)"]
        if let categoryId = categoryId {
            params["category_id"] = categoryId
        }
        if let subCategoryId = subCategoryId {
            params["sub_category"] = subCategoryId
        }
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/find_companies"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    // Parse pagination info
                    self?.lastPage = json["last_page"].intValue
                    
                    // Parse companies
                    let companyList = CompanyListViewModel(list: json["companies"])
                    
                    if refresh {
                        self?.companies = companyList.companyList
                    } else {
                        self?.companies.append(contentsOf: companyList.companyList)
                    }
                    
                    // Check if we can load more
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load companies"
                }
            }
        }
    }
    
    func loadMoreIfNeeded() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        // Android's part is `page`.
        var params: [String: String] = ["page": "\(currentPage)"]
        if let categoryId = categoryId {
            params["category_id"] = categoryId
        }
        if let subCategoryId = subCategoryId {
            params["sub_category"] = subCategoryId
        }
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/find_companies"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    let companyList = CompanyListViewModel(list: json["companies"])
                    self?.companies.append(contentsOf: companyList.companyList)
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    func selectCompany(_ company: CompanyViewModel) {
        // Navigate to company details
        // TODO: Implement navigation
        print("Selected company: \(company.company_name)")
    }
}
