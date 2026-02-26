//
//  SubmitComplaintViewModel.swift
//  TheContractor
//
//  ViewModel for submitting complaints
//

import SwiftUI
import Combine

class SubmitComplaintViewModel: ObservableObject {
    @Published var selectedCompany: CompanyViewModel?
    @Published var description = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isSubmitting = false
    
    var isFormValid: Bool {
        selectedCompany != nil && !description.isEmpty
    }
    
    func showCompanyPicker() {
        // TODO: Show company picker
        print("Show company picker")
    }
    
    func submitComplaint(completion: @escaping () -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            return
        }
        
        guard let company = selectedCompany else {
            errorMessage = "Please select a company"
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        successMessage = ""
        
        let params = [
            "user_id": userId,
            "company_id": company.id,
            "description": description
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/submit_complaint"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                if success {
                    self?.successMessage = "Complaint submitted successfully"
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to submit complaint"
                }
            }
        }
    }
}
