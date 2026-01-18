//
//  CompanyLoginView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct CompanyLoginView: View {
    @State private var email: String = ""
    @State private var pinCode: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

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
                        inputFields
                        loginButton
                        forgotPassword
                        Spacer(minLength: AppTheme.Spacing.large)
                        switchToUserButton
                    }
                    .padding(.horizontal, AppTheme.Spacing.medium)
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
        .navigationBarHidden(true)
    }

    // MARK: - UI Sections

    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text("Login as a Company")
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
                .frame(height: 120)

            Text("Online Contracting Portal")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var inputFields: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text("Email Address")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)

                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .outlinedTextField()
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text("4 Digits Pin Code")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)

                SecureField("4 Digits Pin Code", text: $pinCode)
                    .keyboardType(.numberPad)
                    .outlinedTextField()
            }
        }
    }

    private var loginButton: some View {
        Button(action: { performLogin() }) {
            Text("Login")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isLoginEnabled))
        .padding(.top, AppTheme.Spacing.large)
    }

    private var forgotPassword: some View {
        HStack {
            Spacer()
            Button(action: { /* TODO: Forgot password flow */ }) {
                Text("Forgot password")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, AppTheme.Spacing.small)
    }

    private var switchToUserButton: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text("Not a Member? Create Account")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Button(action: { dismiss() }) {
                Text("Login as a User")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                            .stroke(AppTheme.Colors.primary, lineWidth: 1)
                    )
            }
        }
        .padding(.bottom, AppTheme.Spacing.large)
    }

    // MARK: - Logic

    private var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !pinCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        pinCode.count == 4
    }

    private func performLogin() {
        guard isLoginEnabled, !isLoading else { return }

        isLoading = true
        errorMessage = nil

        let firebase = Global.shared.fcmToken.isEmpty ? "testtoken123" : Global.shared.fcmToken

        GCD.async(.Background) {
            LoginService.shared().loginCompany(email: email, pinCode: pinCode, firebaseToken: firebase) { message, success, _ in
                GCD.async(.Main) {
                    isLoading = false
                    if success {
                        // On success the session and vendor are already saved. Just
                        // navigate to the dashboard (drawer controller).
                        openDashboard()
                    } else {
                        errorMessage = message
                    }
                }
            }
        }
    }

    private func openDashboard() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            dismiss()
            return
        }

        let storyboard = UIStoryboard(name: "Drawer", bundle: nil)
        if let root = storyboard.instantiateViewController(withIdentifier: "KYDrawerController") as? KYDrawerController {
            window.rootViewController = root
            window.makeKeyAndVisible()
        } else {
            dismiss()
        }
    }
}

struct CompanyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyLoginView()
    }
}
