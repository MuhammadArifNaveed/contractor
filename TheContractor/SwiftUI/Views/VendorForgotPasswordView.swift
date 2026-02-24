//
//  VendorForgotPasswordView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct VendorForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToPin: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        logoSection
                        
                        Text("Enter your registered email address to receive a reset PIN code")
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.medium)
                        
                        emailField
                        
                        sendButton
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            .padding(.top, AppTheme.Spacing.large)
                        
                        Spacer(minLength: AppTheme.Spacing.large)
                    }
                    .padding(.top, AppTheme.Spacing.large)
                }
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
            }
            
            NavigationLink(destination: VendorForgotPasswordPinView(email: email), isActive: $navigateToPin) {
                EmptyView()
            }
            .hidden()
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - UI Components
    
    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            
            Text("Forgot Password")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }
    
    private var logoSection: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image("splash_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("Email Address")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField("Enter email address", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .outlinedTextField()
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
    }
    
    private var sendButton: some View {
        Button(action: { sendResetPin() }) {
            Text("Send PIN")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEmailValid))
        .disabled(!isEmailValid)
    }
    
    // MARK: - Logic
    
    private var isEmailValid: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else { return false }
        
        let emailRegex = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: trimmedEmail)
    }
    
    private func sendResetPin() {
        guard isEmailValid, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        
        GCD.async(.Background) {
            LoginService.shared().vendorForgotPasswordSendPin(email: trimmedEmail) { message, success in
                GCD.async(.Main) {
                    isLoading = false
                    if success {
                        navigateToPin = true
                    } else {
                        errorMessage = message
                    }
                }
            }
        }
    }
}

struct VendorForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        VendorForgotPasswordView()
    }
}
