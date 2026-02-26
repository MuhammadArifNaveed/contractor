//  LoginViewModel.swift
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var phone = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func login() {
        guard !phone.isEmpty && !password.isEmpty else { errorMessage = "Fill all fields"; return }
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/login", params: ["phone": phone, "password": password]) { [weak self] msg, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let user = json?["user"] {
                    UserDefaultsManager.shared.userInfo = UserViewModel(user)
                    UserDefaultsManager.shared.isUserLoggedIn = true
                } else { self?.errorMessage = msg ?? "Login failed" }
            }
        }
    }
    
    func showForgotPassword() { print("Show forgot password") }
    func showRegistration() { print("Show registration") }
}
