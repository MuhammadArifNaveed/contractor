//
//  ComplaintsListViewModel.swift
//  TheContractor
//
//  ViewModel for Complaints list with pagination
//

import SwiftUI
import Combine
import SwiftyJSON

class ComplaintsListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var complaints: [ComplaintModel] = []
    
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true
    
    func loadComplaints(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            complaints.removeAll()
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
        
        let params = ["user_id": userId, "page": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/recent_complaints"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    self?.lastPage = json["last_page"].intValue
                    
                    if let complaintsArray = json["complaints"].array {
                        let newComplaints = complaintsArray.map { self?.parseComplaint($0) ?? ComplaintModel() }
                        
                        if refresh {
                            self?.complaints = newComplaints
                        } else {
                            self?.complaints.append(contentsOf: newComplaints)
                        }
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load complaints"
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
        
        let params = ["user_id": userId, "page": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/recent_complaints"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    if let complaintsArray = json["complaints"].array {
                        let newComplaints = complaintsArray.map { self?.parseComplaint($0) ?? ComplaintModel() }
                        self?.complaints.append(contentsOf: newComplaints)
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    private func parseComplaint(_ json: JSON) -> ComplaintModel {
        return ComplaintModel(
            id: json["id"].stringValue,
            companyName: json["company_name"].stringValue,
            description: json["description"].stringValue,
            date: json["date"].stringValue,
            status: json["status"].stringValue,
            response: json["response"].stringValue
        )
    }
    
    func selectComplaint(_ complaint: ComplaintModel) {
        // Navigate to complaint detail
        print("Selected complaint: \(complaint.id)")
    }
}
