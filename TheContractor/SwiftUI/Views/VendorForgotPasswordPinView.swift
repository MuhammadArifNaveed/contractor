//
//  VendorForgotPasswordPinView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct VendorForgotPasswordPinView: View {
    let email: String
    
    @State private var pin: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToNewPassword: Bool = false
    
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
                        
                        Text("Enter the PIN code sent to your email")
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.medium)
                        
                        Text(email)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.horizontal, AppTheme.Spacing.medium)
                        
                        pinField
                        
                        verifyButton
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
            
            NavigationLink(destination: VendorNewPasswordView(email: email), isActive: $navigateToNewPassword) {
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
            
            Text("Pin Code")
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
    
    private var pinField: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("PIN Code")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField("Enter PIN code", text: $pin)
                .keyboardType(.numberPad)
                .outlinedTextField()
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
    }
    
    private var verifyButton: some View {
        Button(action: { verifyPin() }) {
            Text("Verify PIN")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isPinValid))
        .disabled(!isPinValid)
    }
    
    // MARK: - Logic
    
    private var isPinValid: Bool {
        !pin.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func verifyPin() {
        guard isPinValid, !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let trimmedPin = pin.trimmingCharacters(in: .whitespaces)
        
        GCD.async(.Background) {
            LoginService.shared().vendorForgotPasswordVerifyPin(email: email, pin: trimmedPin) { message, success in
                GCD.async(.Main) {
                    isLoading = false
                    if success {
                        navigateToNewPassword = true
                    } else {
                        errorMessage = message
                    }
                }
            }
        }
    }
}

struct VendorForgotPasswordPinView_Previews: PreviewProvider {
    static var previews: some View {
        VendorForgotPasswordPinView(email: "test@example.com")
    }
}
