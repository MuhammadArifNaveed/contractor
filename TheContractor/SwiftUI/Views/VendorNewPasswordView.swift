//
//  VendorNewPasswordView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct VendorNewPasswordView: View {
    let email: String
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showSuccessAlert: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.large) {
                        logoSection
                        
                        Text("Create your new password")
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.medium)
                        
                        passwordFields
                        
                        updateButton
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
        }
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                // Navigate back to login
                navigateToLogin()
            }
        } message: {
            Text("Password updated successfully")
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - UI Components
    
    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            
            Text("New Password")
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
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var passwordFields: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text("New Password (4 digits minimum)")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                SecureField("Enter new password", text: $password)
                    .keyboardType(.default)
                    .outlinedTextField()
            }
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text("Confirm Password")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                SecureField("Re-enter password", text: $confirmPassword)
                    .keyboardType(.default)
                    .outlinedTextField()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
    }
    
    private var updateButton: some View {
        Button(action: { updatePassword() }) {
            Text("Update Password")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isFormValid))
        .disabled(!isFormValid)
    }
    
    // MARK: - Logic
    
    private var isFormValid: Bool {
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespaces)
        
        return !trimmedPassword.isEmpty &&
               trimmedPassword.count >= 4 &&
               !trimmedConfirm.isEmpty &&
               trimmedPassword == trimmedConfirm
    }
    
    private func updatePassword() {
        guard isFormValid, !isLoading else { return }
        
        // Validate fields explicitly
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespaces)
        
        if trimmedPassword.isEmpty {
            errorMessage = "Enter new 4 digit pin"
            return
        }
        
        if trimmedPassword.count < 4 {
            errorMessage = "Enter at least 4 digit pin"
            return
        }
        
        if trimmedConfirm.isEmpty {
            errorMessage = "Enter confirm 4 digit pin"
            return
        }
        
        if trimmedPassword != trimmedConfirm {
            errorMessage = "Pin not matched"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        GCD.async(.Background) {
            LoginService.shared().vendorUpdatePassword(email: email, password: trimmedPassword) { message, success in
                GCD.async(.Main) {
                    isLoading = false
                    if success {
                        showSuccessAlert = true
                    } else {
                        errorMessage = message
                    }
                }
            }
        }
    }
    
    private func navigateToLogin() {
        // Pop to root (login screen)
        presentationMode.wrappedValue.dismiss()
        // Dismiss all the way back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct VendorNewPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        VendorNewPasswordView(email: "test@example.com")
    }
}
