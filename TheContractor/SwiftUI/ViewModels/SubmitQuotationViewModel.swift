//
//  SubmitQuotationViewModel.swift
//  TheContractor
//
//  ViewModel for submitting quotation requests
//

import SwiftUI
import Combine

class SubmitQuotationViewModel: ObservableObject {
    @Published var selectedCompany: CompanyViewModel?
    @Published var description = ""
    @Published var location = ""
    @Published var dateTime = ""
    @Published var selectedDate = Date()
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    
    var isFormValid: Bool {
        selectedCompany != nil &&
        !description.isEmpty &&
        !location.isEmpty &&
        !dateTime.isEmpty
    }
    
    func showCompanyPicker() {
        // TODO: Show company picker
        print("Show company picker")
    }
    
    func submitQuotation(completion: @escaping () -> Void) {
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
        
        let params = [
            "user_id": userId,
            "company_id": company.id,
            "description": description,
            "location": location,
            "date_time": dateTime
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/send_quotation_request"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                if success {
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to submit quotation request"
                }
            }
        }
    }
}
