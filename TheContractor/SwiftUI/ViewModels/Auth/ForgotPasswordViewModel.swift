//  ForgotPasswordViewModel.swift
import SwiftUI

class ForgotPasswordViewModel: ObservableObject {
    @Published var phone = "", errorMessage = ""
    @Published var isLoading = false
    
    func sendCode() {
        guard !phone.isEmpty else { errorMessage = "Enter phone number"; return }
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/forgot_password", params: ["phone": phone]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if !success { self?.errorMessage = msg ?? "Failed to send code" }
            }
        }
    }
}
