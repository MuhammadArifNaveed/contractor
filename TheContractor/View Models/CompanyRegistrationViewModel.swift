//
//  CompanyRegistrationViewModel.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import SwiftUI

class CompanyRegistrationViewModel: ObservableObject {
    @Published var companyName: String = ""
    @Published var companyNameArabic: String = ""
    @Published var companyEmail: String = ""
    @Published var companyPhone: String = ""
    @Published var companyAddress: String = ""
    @Published var ownerName: String = ""
    @Published var ownerPhone: String = ""
    @Published var agentReferralCode: String = ""
    @Published var loginEmail: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var acceptedTerms: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !companyName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !companyNameArabic.trimmingCharacters(in: .whitespaces).isEmpty &&
        !companyEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(companyEmail) &&
        !companyPhone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !companyAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        !ownerName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !ownerPhone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !loginEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidEmail(loginEmail) &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 4 &&
        !confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
        password == confirmPassword &&
        acceptedTerms
    }
    
    // MARK: - Validation Helpers
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateField(_ field: RegistrationField) -> String? {
        switch field {
        case .companyName:
            return companyName.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company name in English" : nil
        case .companyNameArabic:
            return companyNameArabic.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company name in Arabic" : nil
        case .companyEmail:
            if companyEmail.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Enter company email address"
            }
            if !isValidEmail(companyEmail) {
                return "Enter valid company email address"
            }
            return nil
        case .companyPhone:
            return companyPhone.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company phone number" : nil
        case .companyAddress:
            return companyAddress.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company address" : nil
        case .ownerName:
            return ownerName.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company owner name" : nil
        case .ownerPhone:
            return ownerPhone.trimmingCharacters(in: .whitespaces).isEmpty ? "Enter company owner phone number" : nil
        case .loginEmail:
            if loginEmail.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Enter login email address"
            }
            if !isValidEmail(loginEmail) {
                return "Enter valid login email address"
            }
            return nil
        case .password:
            if password.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Password is required"
            }
            if password.count < 4 {
                return "Enter at least 4 digit pin"
            }
            return nil
        case .confirmPassword:
            if confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty {
                return "Confirm password is required"
            }
            if password != confirmPassword {
                return "Pin not matched"
            }
            return nil
        }
    }
    
    // MARK: - Registration
    
    func register(completion: @escaping () -> Void) {
        // Validate all fields
        if !isFormValid {
            if !acceptedTerms {
                errorMessage = "Please accept Terms & Conditions and Company Agreement"
                return
            }
            
            // Find first invalid field
            for field in RegistrationField.allCases {
                if let error = validateField(field) {
                    errorMessage = error
                    return
                }
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let firebaseToken = Global.shared.firebaseTokenForRequest
        
        let params: [String: String] = [
            "company_english": companyName.trimmingCharacters(in: .whitespaces),
            "company_arabic": companyNameArabic.trimmingCharacters(in: .whitespaces),
            "company_email": companyEmail.trimmingCharacters(in: .whitespaces),
            "company_phone": companyPhone.trimmingCharacters(in: .whitespaces),
            "company_address": companyAddress.trimmingCharacters(in: .whitespaces),
            "owner_name": ownerName.trimmingCharacters(in: .whitespaces),
            "owner_phone": ownerPhone.trimmingCharacters(in: .whitespaces),
            "agent_code": agentReferralCode.trimmingCharacters(in: .whitespaces),
            "login_email": loginEmail.trimmingCharacters(in: .whitespaces),
            "login_password": password.trimmingCharacters(in: .whitespaces),
            "device_type": "ios",
            "firebase_token": firebaseToken
        ]
        
        GCD.async(.Background) {
            LoginService.shared().registerCompany(params: params) { [weak self] message, success in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    if success {
                        self.successMessage = message
                        self.showSuccessAlert = true
                        completion()
                    } else {
                        self.errorMessage = message
                    }
                }
            }
        }
    }
    
    enum RegistrationField: CaseIterable {
        case companyName
        case companyNameArabic
        case companyEmail
        case companyPhone
        case companyAddress
        case ownerName
        case ownerPhone
        case loginEmail
        case password
        case confirmPassword
    }
}
