//
//  ProfileModels.swift
//  TheContractor
//

import Foundation

struct ChangePasswordRequest {
    let oldPassword: String
    let newPassword: String
    let confirmPassword: String
    
    var isValid: Bool {
        return !oldPassword.isEmpty &&
               !newPassword.isEmpty &&
               newPassword.count >= 6 &&
               newPassword == confirmPassword
    }
}

struct ProfileUpdateRequest {
    let userId: String
    let name: String
    let surname: String
    let phone: String
    let email: String
    let address: String?
    let profileImage: Data?
    
    var isValid: Bool {
        return !name.isEmpty &&
               !surname.isEmpty &&
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
