//  ChangePasswordView.swift
import SwiftUI
struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Form {
            Section(header: Text("Current Password")) { CustomTextField(placeholder: "Current Password", text: $viewModel.currentPassword, icon: "lock", isSecure: true) }
            Section(header: Text("New Password")) {
                CustomTextField(placeholder: "New Password", text: $viewModel.newPassword, icon: "lock", isSecure: true)
                CustomTextField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, icon: "lock", isSecure: true)
            }
            if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
        }
        .navigationTitle("Change Password")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.changePassword { presentationMode.wrappedValue.dismiss() } }) {
                    if viewModel.isSubmitting { ProgressView() } else { Text("Save").fontWeight(.semibold) }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
            }
        }
    }
}
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword }
    func changePassword(completion: @escaping () -> Void) {
        guard isFormValid, let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/change_password", params: ["user_id": userId, "current_password": currentPassword, "new_password": newPassword]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
