//
//  UserProfileViewModel.swift
//  TheContractor
//
//  ViewModel for User Profile
//

import SwiftUI
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userPhone = ""
    
    init() {
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            userName = "\(user.name) \(user.surname)"
            userPhone = user.phone
            // Email not in UserViewModel, using placeholder
            userEmail = ""
        }
    }
    
    func navigateToEnquiries() {
        print("Navigate to Enquiries")
    }
    
    func navigateToQuotations() {
        print("Navigate to Quotations")
    }
    
    func navigateToJobApplications() {
        print("Navigate to Job Applications")
    }
    
    func navigateToComplaints() {
        print("Navigate to Complaints")
    }
    
    func navigateToCart() {
        print("Navigate to Cart")
    }
    
    func navigateToSettings() {
        print("Navigate to Settings")
    }
    
    func logout() {
        UserDefaultsManager.shared.clearAllLoginData()
        // TODO: Navigate to login screen
        print("Logout")
    }
}
