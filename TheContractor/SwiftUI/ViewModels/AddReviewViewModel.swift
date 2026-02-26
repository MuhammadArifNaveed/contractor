//
//  AddReviewViewModel.swift
//  TheContractor
//
//  ViewModel for adding reviews
//

import SwiftUI
import Combine

class AddReviewViewModel: ObservableObject {
    @Published var rating = 0
    @Published var comment = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isSubmitting = false
    
    let companyId: String
    let companyName: String
    
    var isFormValid: Bool {
        rating > 0
    }
    
    init(companyId: String, companyName: String) {
        self.companyId = companyId
        self.companyName = companyName
    }
    
    func submitReview(completion: @escaping () -> Void) {
        guard isFormValid else {
            errorMessage = "Please select a rating"
            return
        }
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        successMessage = ""
        
        let params = [
            "user_id": userId,
            "company_id": companyId,
            "rating": "\(rating)",
            "comment": comment
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/submit_review"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                if success {
                    self?.successMessage = "Review submitted successfully"
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to submit review"
                }
            }
        }
    }
}
