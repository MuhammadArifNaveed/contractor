//
//  CompanyLoginView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct CompanyLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showForgotPassword = false
    @State private var showEmailVerification = false
    @State private var emailVerificationMessage: String = ""
    @State private var noticeMessage: String? = nil
    @State private var showCompanyRegistration = false

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
        // Port of Android's verify_email_dialog: the server's own message, the "send it again"
        // hint, a Send Email action, and dismissable by cancelling.
        .alert(emailVerificationMessage.isEmpty ? "Please verify email." : emailVerificationMessage,
               isPresented: $showEmailVerification) {
            Button("Send Email", role: .none) {
                resendVerificationEmail()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("If you haven't received the email yet, send it again.")
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .sheet(isPresented: $showForgotPassword) {
            NavigationView {
                VendorForgotPasswordView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .sheet(isPresented: $showCompanyRegistration) {
            NavigationView {
                CompanyRegistrationView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
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
            Image("logo")
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

                SecureField("4 Digits Pin Code", text: $password)
                    .keyboardType(.numberPad)
                    .outlinedTextField()
                    .onChange(of: password) { newValue in
                        if newValue.count > 4 {
                            password = String(newValue.prefix(4))
                        }
                    }
            }
        }
    }

    private var loginButton: some View {
        Button(action: { performLogin() }) {
            Text("Login")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: true))
        .padding(.top, AppTheme.Spacing.large)
    }

    private var forgotPassword: some View {
        HStack {
            Spacer()
            Button(action: { showForgotPassword = true }) {
                Text("Forgot password")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
        .padding(.top, AppTheme.Spacing.small)
    }

    private var switchToUserButton: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Button(action: { showCompanyRegistration = true }) {
                Text("Not a Member? Create Account")
                    .font(AppTheme.Fonts.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

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

    private func isValidEmail(_ emailAddress: String) -> Bool {
        let emailPattern = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        let regex = try? NSRegularExpression(pattern: emailPattern, options: [])
        let range = NSRange(location: 0, length: emailAddress.utf16.count)
        return regex?.firstMatch(in: emailAddress, options: [], range: range) != nil
    }

    private func performLogin() {
        guard !isLoading else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedPassword = password.trimmingCharacters(in: .whitespaces)

        // Validation matching Android's VendorLogin.java exactly
        if trimmedEmail.isEmpty {
            errorMessage = "Enter email address"
            return
        } else if !isValidEmail(trimmedEmail) {
            errorMessage = "Enter valid email address"
            return
        } else if trimmedPassword.isEmpty {
            errorMessage = "Enter 4 digits pin code"
            return
        }

        isLoading = true
        errorMessage = nil

        let firebase = Global.shared.fcmToken.isEmpty ? "testtoken123" : Global.shared.fcmToken

        GCD.async(.Background) {
            LoginService.shared().loginCompany(email: email, pinCode: password, firebaseToken: firebase) { message, success, json in
                GCD.async(.Main) {
                    isLoading = false
                    if success {
                        // The session and vendor record are already saved. Just show the dashboard.
                        openDashboard()
                    } else if json?["is_email_verified"].stringValue == "No" {
                        // Android only offers the resend option on a *failed* login
                        // (VendorLogin.java:287-296); the flag is absent on success.
                        emailVerificationMessage = message
                        showEmailVerification = true
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }

    /// Android finishes the login activity with `FLAG_ACTIVITY_CLEAR_TASK`, so there is no way back
    /// to this screen except logging out. The equivalent here is to make the drawer the only entry
    /// in the navigation stack the login screen was pushed onto — keeping the drawer inside a
    /// navigation controller, which `logoutUser()` relies on to get back to the login screen.
    ///
    /// `MainContainerViewController` shows `VendorHomeView` on its own once it sees
    /// `Global.shared.isVendor`, which the login response has already set.
    private func openDashboard() {
        let storyboard = UIStoryboard(name: "Drawer", bundle: nil)
        guard let drawer = storyboard.instantiateViewController(withIdentifier: "KYDrawerController") as? KYDrawerController else {
            dismiss()
            return
        }

        guard let window = CompanyLoginView.activeWindow() else {
            dismiss()
            return
        }

        if let navigation = CompanyLoginView.findNavigationController(from: window.rootViewController) {
            navigation.setViewControllers([drawer], animated: true)
        } else {
            window.rootViewController = drawer
            window.makeKeyAndVisible()
        }
    }

    private static func activeWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.flatMap { $0.windows }.first { $0.isKeyWindow } ?? scenes.first?.windows.first
    }

    private static func findNavigationController(from controller: UIViewController?) -> UINavigationController? {
        guard let controller = controller else { return nil }
        if let navigation = controller as? UINavigationController { return navigation }
        for child in controller.children {
            if let found = findNavigationController(from: child) { return found }
        }
        return nil
    }

    /// Android's `resendEmail()` simply toasts whatever the server says, success or not.
    private func resendVerificationEmail() {
        isLoading = true
        GCD.async(.Background) {
            LoginService.shared().resendVendorVerificationEmail(email: email) { message, success in
                GCD.async(.Main) {
                    isLoading = false
                    showEmailVerification = false
                    noticeMessage = message.isEmpty
                        ? (success ? "Verification email sent." : "Please try again")
                        : message
                }
            }
        }
    }
}

struct CompanyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyLoginView()
    }
}
