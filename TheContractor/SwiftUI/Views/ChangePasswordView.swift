//  ChangePasswordView.swift
import SwiftUI
struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom yellow top bar
            HStack(spacing: 0) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Change Password")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4)
            .frame(height: 56)
            .background(yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Current Password Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            if viewModel.showCurrentPassword {
                                TextField("Current Password", text: $viewModel.currentPassword)
                            } else {
                                SecureField("Current Password", text: $viewModel.currentPassword)
                            }
                            
                            Button(action: { viewModel.showCurrentPassword.toggle() }) {
                                Image(systemName: viewModel.showCurrentPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // New Password Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            if viewModel.showNewPassword {
                                TextField("New Password", text: $viewModel.newPassword)
                            } else {
                                SecureField("New Password", text: $viewModel.newPassword)
                            }
                            
                            Button(action: { viewModel.showNewPassword.toggle() }) {
                                Image(systemName: viewModel.showNewPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            
                            if viewModel.showConfirmPassword {
                                TextField("Confirm Password", text: $viewModel.confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            }
                            
                            Button(action: { viewModel.showConfirmPassword.toggle() }) {
                                Image(systemName: viewModel.showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                    }
                    
                    // Save Button
                    Button(action: {
                        viewModel.changePassword {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? yellow : Color.gray)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
}
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    @Published var showCurrentPassword = false
    @Published var showNewPassword = false
    @Published var showConfirmPassword = false
    var isFormValid: Bool { !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword }
    func changePassword(completion: @escaping () -> Void) {
        // Android keys this on the email, not the id.
        guard isFormValid,
              let userEmail = UserDefaultsManager.shared.userInfo?.email, !userEmail.isEmpty else {
            errorMessage = "Sign in again to change your password"
            return
        }
        isSubmitting = true
        // Android: Account/change_password, keyed on user_email with parts old_password /
        // new_password. Home/change_password does not exist, and user_id / current_password were
        // never read.
        LoginService.shared().changePassword(userEmail: userEmail,
                                            oldPassword: currentPassword,
                                            newPassword: newPassword) { [weak self] msg, success in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg.isEmpty ? "Failed" : msg }
            }
        }
    }
}
