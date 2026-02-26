//  RegistrationViewModel.swift
import SwiftUI

class RegistrationViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    var isFormValid: Bool { !firstName.isEmpty && !lastName.isEmpty && !phone.isEmpty && !password.isEmpty && password == confirmPassword }
    
    func register() {
        guard isFormValid else { errorMessage = "Fill all fields correctly"; return }
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/register", params: ["name": firstName, "surname": lastName, "phone": phone, "password": password]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if !success { self?.errorMessage = msg ?? "Registration failed" }
            }
        }
    }
}
