//
//  EditProfileViewModel.swift
//  TheContractor
//
//  ViewModel for editing user profile
//

import SwiftUI
import Combine

class EditProfileViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isUpdating = false
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !phone.isEmpty
    }
    
    func loadCurrentUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            firstName = user.name
            lastName = user.surname
            phone = user.phone
        }
    }
    
    func updateProfile(completion: @escaping () -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            return
        }
        
        isUpdating = true
        errorMessage = ""
        successMessage = ""
        
        let params = [
            "user_id": userId,
            "name": firstName,
            "surname": lastName,
            "phone": phone
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/update_user_profile"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isUpdating = false
                
                if success {
                    // Update local user info
                    if var user = UserDefaultsManager.shared.userInfo {
                        user.name = self?.firstName ?? ""
                        user.surname = self?.lastName ?? ""
                        user.phone = self?.phone ?? ""
                        UserDefaultsManager.shared.userInfo = user
                    }
                    
                    self?.successMessage = "Profile updated successfully"
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to update profile"
                }
            }
        }
    }
}
