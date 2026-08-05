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
    /// Android's `cbFreelancer`, and a live switch rather than a local flag: each tap calls
    /// `freelancing/update_user_freelance_status` and follows the state the response reports back,
    /// reverting on failure exactly as `UpdateProfile` does.
    @Published var isAvailableAsFreelancer = false
    @Published var isUpdatingFreelanceStatus = false
    @Published var freelanceNotice: String?
    @Published var isCheckingFreelancerRecord = false
    /// Set when the freelancer form should open; the value says whether a record already exists.
    @Published var openFreelancerForm = false
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
            isAvailableAsFreelancer = user.isAvailableAsFreelance == "1"
        }
    }

    // MARK: - Freelancing

    func toggleFreelanceAvailability() {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            errorMessage = "User not logged in"
            return
        }

        let wanted = !isAvailableAsFreelancer
        isAvailableAsFreelancer = wanted          // optimistic, reverted below if the call fails
        isUpdatingFreelanceStatus = true

        GCD.async(.Background) {
            LoginService.shared().updateUserFreelanceStatus(userId: user.id,
                                                           userType: user.userType.isEmpty ? "users" : user.userType,
                                                           isAvailable: wanted) { [weak self] message, success, json in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isUpdatingFreelanceStatus = false
                    guard success else {
                        self.isAvailableAsFreelancer = !wanted
                        self.errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    // Follow what the server says rather than what was tapped.
                    if let json = json, json["isAvailable"].exists() {
                        self.isAvailableAsFreelancer = json["isAvailable"].boolValue
                            || json["isAvailable"].stringValue == "1"
                            || json["isAvailable"].stringValue == "true"
                    }
                    var stored = user
                    stored.isAvailableAsFreelance = self.isAvailableAsFreelancer ? "1" : "0"
                    UserDefaultsManager.shared.userInfo = stored
                    Global.shared.user = stored
                    self.freelanceNotice = message.isEmpty
                        ? (self.isAvailableAsFreelancer ? "You are listed as available." : "You are no longer listed.")
                        : message
                }
            }
        }
    }

    /// Android checks for an existing freelancer record before opening the form, so the form knows
    /// whether it is adding or updating. Either way the form opens; only the mode differs.
    func openFreelancerProfile() {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            errorMessage = "User not logged in"
            return
        }

        isCheckingFreelancerRecord = true
        GCD.async(.Background) {
            LoginService.shared().getUserFreelancerRecord(userId: user.id) { [weak self] message, success, hasRecord, _ in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isCheckingFreelancerRecord = false
                    guard success else {
                        self.errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    self.hasFreelancerRecord = hasRecord
                    self.openFreelancerForm = true
                }
            }
        }
    }

    /// True once `freelancing/register_user_freelancer` reports a record; the form opens in update mode.
    @Published var hasFreelancerRecord = false
    
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
