//
//  EnquiriesListViewModel.swift
//  TheContractor
//
//  ViewModel for Enquiries list with pagination
//

import SwiftUI
import Combine
import SwiftyJSON

class EnquiriesListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var enquiries: [EnquiryModel] = []
    
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true
    
    func loadEnquiries(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            enquiries.removeAll()
            canLoadMore = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Get userId from UserDefaults
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }
        
        let params = ["user_id": userId, "page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_enquiries"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    self?.lastPage = json["last_page"].intValue
                    
                    // Parse enquiries
                    if let enquiriesArray = json["enquiries"].array {
                        let newEnquiries = enquiriesArray.map { self?.parseEnquiry($0) ?? EnquiryModel() }
                        
                        if refresh {
                            self?.enquiries = newEnquiries
                        } else {
                            self?.enquiries.append(contentsOf: newEnquiries)
                        }
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load enquiries"
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
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_enquiries"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    if let enquiriesArray = json["enquiries"].array {
                        let newEnquiries = enquiriesArray.map { self?.parseEnquiry($0) ?? EnquiryModel() }
                        self?.enquiries.append(contentsOf: newEnquiries)
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    private func parseEnquiry(_ json: JSON) -> EnquiryModel {
        return EnquiryModel(
            id: json["id"].stringValue,
            companyNames: json["company_names"].stringValue,
            date: json["date"].stringValue,
            status: json["status"].stringValue,
            firstName: json["first_name"].stringValue,
            lastName: json["last_name"].stringValue,
            phone: json["phone"].stringValue,
            email: json["email"].stringValue
        )
    }
    
    func selectEnquiry(_ enquiry: EnquiryModel) {
        // Navigate to enquiry detail
        // TODO: Implement navigation
        print("Selected enquiry: \(enquiry.id)")
    }
}

// MARK: - EnquiryModel Extension
extension EnquiryModel {
    init(id: String, companyNames: String, date: String, status: String, firstName: String, lastName: String, phone: String, email: String) {
        self.id = id
        self.companyNames = companyNames
        self.date = date
        self.status = status
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
}
