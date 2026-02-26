//  ForgotPasswordView.swift
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("Forgot Password?")
                    .font(AppTheme.Fonts.bold(24))
                
                Text("Enter your phone number to receive a verification code")
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                CustomTextField(placeholder: "Phone Number", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red).font(AppTheme.Fonts.regular(14))
                }
                
                PrimaryButton(title: "Send Code") { viewModel.sendCode() }
                    .disabled(viewModel.isLoading)
                
                Spacer()
            }
            .padding(24)
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
