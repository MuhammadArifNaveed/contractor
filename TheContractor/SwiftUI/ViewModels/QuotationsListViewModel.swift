//
//  QuotationsListViewModel.swift
//  TheContractor
//
//  ViewModel for Quotations list
//

import SwiftUI
import Combine
import SwiftyJSON

class QuotationsListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var quotations: [QuotationModel] = []
    
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true
    
    func loadQuotations(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            quotations.removeAll()
            canLoadMore = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }
        
        let params = ["user_id": userId, "page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_quotations"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    self?.lastPage = json["last_page"].intValue
                    
                    if let quotationsArray = json["quotations"].array {
                        let newQuotations = quotationsArray.map { self?.parseQuotation($0) ?? QuotationModel() }
                        
                        if refresh {
                            self?.quotations = newQuotations
                        } else {
                            self?.quotations.append(contentsOf: newQuotations)
                        }
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load quotations"
                }
            }
        }
    }
    
    func loadMoreIfNeeded() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            isLoadingMore = false
            return
        }
        
        let params = ["user_id": userId, "page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_quotations"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    if let quotationsArray = json["quotations"].array {
                        let newQuotations = quotationsArray.map { self?.parseQuotation($0) ?? QuotationModel() }
                        self?.quotations.append(contentsOf: newQuotations)
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    private func parseQuotation(_ json: JSON) -> QuotationModel {
        return QuotationModel(
            id: json["id"].stringValue,
            status: json["status"].stringValue,
            date: json["date"].stringValue,
            companyName: json["company_name"].stringValue,
            description: json["description"].stringValue,
            location: json["location"].stringValue,
            dateTime: json["date_time"].stringValue
        )
    }
    
    func selectQuotation(_ quotation: QuotationModel) {
        // Navigate to quotation detail
        print("Selected quotation: \(quotation.id)")
    }
}
