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
    
    func loadUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            userName = "\(user.name) \(user.surname)"
            userPhone = user.phone
            userEmail = ""
        }
    }
    
    func goToLogin() {
        NotificationCenter.default.post(name: NSNotification.Name("GoToLogin"), object: nil)
    }
    
    func navigateToEditProfile() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToEditProfile"), object: nil)
    }
    
    func navigateToChangePassword() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToChangePassword"), object: nil)
    }
    
    func navigateToLanguage() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToLanguage"), object: nil)
    }
    
    func navigateToEnquiries() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToEnquiries"), object: nil)
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
        Global.shared.user = nil
        Global.shared.isLogedIn = false
        Global.shared.user = UserViewModel()
        UserDefaultsManager.shared.clearAllLoginData()
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
    }
}
