//
//  SubmitEnquiryViewModel.swift
//  TheContractor
//
//  ViewModel for submitting enquiries
//

import SwiftUI
import Combine
import SwiftyJSON

class SubmitEnquiryViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var selectedCompanies: [CompanyViewModel] = []
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phone.isEmpty &&
        !email.isEmpty &&
        !selectedCompanies.isEmpty
    }
    
    func showCompanyPicker() {
        // TODO: Show company picker
        print("Show company picker")
    }
    
    func removeCompany(_ company: CompanyViewModel) {
        selectedCompanies.removeAll { $0.id == company.id }
    }
    
    func submitEnquiry(completion: @escaping () -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        
        // Create companies JSON array
        let companiesJSON = selectedCompanies.map { ["id": $0.id] }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: companiesJSON),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            errorMessage = "Failed to prepare data"
            isSubmitting = false
            return
        }
        
        let params = [
            "user_id": userId,
            "first_name": firstName,
            "last_name": lastName,
            "phone": phone,
            "email": email,
            "companies": jsonString
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/send_enquiries"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                if success {
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to submit enquiry"
                }
            }
        }
    }
}
