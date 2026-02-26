//
//  ReviewsListViewModel.swift
//  TheContractor
//
//  ViewModel for Reviews list
//

import SwiftUI
import Combine
import SwiftyJSON

class ReviewsListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var reviews: [ReviewModel] = []
    @Published var averageRating = "0.0"
    @Published var totalReviews = 0
    
    let companyId: String
    let companyName: String
    
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true
    
    init(companyId: String, companyName: String) {
        self.companyId = companyId
        self.companyName = companyName
    }
    
    func loadReviews(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            reviews.removeAll()
            canLoadMore = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let params = ["company_id": companyId, "page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_company_reviews"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    self?.lastPage = json["last_page"].intValue
                    self?.averageRating = json["average_rating"].stringValue
                    self?.totalReviews = json["total_reviews"].intValue
                    
                    if let reviewsArray = json["reviews"].array {
                        let newReviews = reviewsArray.map { self?.parseReview($0) ?? ReviewModel() }
                        
                        if refresh {
                            self?.reviews = newReviews
                        } else {
                            self?.reviews.append(contentsOf: newReviews)
                        }
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load reviews"
                }
            }
        }
    }
    
    func loadMoreIfNeeded() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        let params = ["company_id": companyId, "page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_company_reviews"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    if let reviewsArray = json["reviews"].array {
                        let newReviews = reviewsArray.map { self?.parseReview($0) ?? ReviewModel() }
                        self?.reviews.append(contentsOf: newReviews)
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    private func parseReview(_ json: JSON) -> ReviewModel {
        return ReviewModel(
            id: json["id"].stringValue,
            userName: json["user_name"].stringValue,
            rating: json["rating"].stringValue,
            comment: json["comment"].stringValue,
            date: json["date"].stringValue
        )
    }
}
