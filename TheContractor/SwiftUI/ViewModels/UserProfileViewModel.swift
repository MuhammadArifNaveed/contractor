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
        print("🔐 goToLogin called - posting GoToLogin notification")
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
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToQuotations"), object: nil)
    }
    
    func navigateToJobApplications() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToJobApplications"), object: nil)
    }
    
    func navigateToComplaints() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToComplaints"), object: nil)
    }
    
    func navigateToCart() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToCart"), object: nil)
    }
    
    func navigateToQuotationByPhoto() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToSubmitQuotation"), object: nil)
    }
    
    func navigateTo24x7Maintenance() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateTo24x7Maintenance"), object: nil)
    }
    
    func navigateToEstimations() {
        NotificationCenter.default.post(name: NSNotification.Name("NavigateToEstimations"), object: nil)
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
