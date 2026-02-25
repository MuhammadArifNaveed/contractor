//
//  EnquiryModels.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation

/// Model for submitting enquiry with selected companies
struct SelectedCompanyForEnquiry: Codable {
    let id: String
    let dateTime: String
    let location: String
    let lat: String
    let lng: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateTime = "date_time"
        case location
        case lat
        case lng
        case description
    }
}

/// Contact information for enquiry submission
struct EnquiryContactInfo {
    let firstName: String
    let lastName: String
    let phone: String
    let email: String
    
    var isValid: Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !phone.isEmpty &&
               !email.isEmpty &&
               isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
