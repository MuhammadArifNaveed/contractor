//
//  CheckoutViewModel.swift
//  TheContractor
//

import SwiftUI
import Combine

class CheckoutViewModel: ObservableObject {
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var address = ""
    @Published var city = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    
    var isFormValid: Bool { !name.isEmpty && !phone.isEmpty && !address.isEmpty && !city.isEmpty }
    
    func loadUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            name = "\(user.name) \(user.surname)"
            phone = user.phone
        }
    }
    
    func submitOrder(completion: @escaping () -> Void) {
        guard isFormValid, let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        isSubmitting = true
        
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/submit_order", params: ["user_id": userId, "name": name, "phone": phone, "email": email, "address": address, "city": city]) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = message ?? "Failed to submit order" }
            }
        }
    }
}
