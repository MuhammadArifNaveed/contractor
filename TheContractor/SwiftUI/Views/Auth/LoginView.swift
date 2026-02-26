//  LoginView.swift
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.Colors.primary)
                
                Text("Welcome Back")
                    .font(AppTheme.Fonts.bold(28))
                
                CustomTextField(placeholder: "Phone Number", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                CustomTextField(placeholder: "Password", text: $viewModel.password, icon: "lock", isSecure: true)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage).foregroundColor(.red).font(AppTheme.Fonts.regular(14))
                }
                
                PrimaryButton(title: "Login") { viewModel.login() }
                    .disabled(viewModel.isLoading)
                
                HStack {
                    Button("Forgot Password?") { viewModel.showForgotPassword() }
                    Spacer()
                    Button("Sign Up") { viewModel.showRegistration() }
                }
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(24)
        }
    }
}
