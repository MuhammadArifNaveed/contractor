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
    @Published var email = ""
    @Published var selectedCity = ""
    @Published var address = ""
    @Published var selectedCategory = ""
    @Published var availableForJob = false
    @Published var notAvailableAsFreelancer = false
    @Published var videoName = ""
    @Published var cvName = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isUpdating = false
    @Published var showImagePicker = false
    
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
        
        // Android: Account/update_user_profile. Home/update_user_profile does not exist, and the
        // `name` / `phone` parts were never read — they are user_name / user_phone.
        let params = [
            "user_id": userId,
            "user_name": firstName,
            "surname": lastName,
            "user_phone": phone,
            "user_email": UserDefaultsManager.shared.userInfo?.email ?? "",
            "address": "",
            "city": "",
            "country": "",
            "job_category": ""
        ]

        let completeURL = "https://contractor.bidcont.com/rest/Account/update_user_profile"
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
