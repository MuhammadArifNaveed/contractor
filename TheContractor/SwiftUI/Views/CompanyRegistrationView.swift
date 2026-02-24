//
//  CompanyRegistrationView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct CompanyRegistrationView: View {
    @StateObject private var viewModel = CompanyRegistrationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showTermsSheet = false
    @State private var showCompanyAgreementSheet = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        logoSection
                        
                        VStack(spacing: AppTheme.Spacing.medium) {
                            companyInfoSection
                            ownerInfoSection
                            loginCredentialsSection
                            termsSection
                        }
                        .padding(.horizontal, AppTheme.Spacing.medium)
                        
                        registerButton
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            .padding(.top, AppTheme.Spacing.large)
                        
                        Spacer(minLength: AppTheme.Spacing.large)
                    }
                    .padding(.top, AppTheme.Spacing.medium)
                }
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
            }
        }
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Registration Submitted", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(viewModel.successMessage)
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsWebView(url: "\(EndPoints.BASE_URL.replacingOccurrences(of: "rest/", with: ""))terms-and-conditions-app", title: "Terms & Conditions")
        }
        .sheet(isPresented: $showCompanyAgreementSheet) {
            TermsWebView(url: "\(EndPoints.BASE_URL.replacingOccurrences(of: "rest/", with: ""))company-agreement-app", title: "Company Agreement")
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
            
            Text("Vendor Registration")
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
        .padding(.bottom, AppTheme.Spacing.small)
    }
    
    private var companyInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Company Information")
            
            FormField(
                label: "Company Name (English)",
                placeholder: "Enter company name",
                text: $viewModel.companyName
            )
            
            FormField(
                label: "Company Name (Arabic)",
                placeholder: "أدخل اسم الشركة",
                text: $viewModel.companyNameArabic
            )
            
            FormField(
                label: "Company Email",
                placeholder: "company@example.com",
                text: $viewModel.companyEmail,
                keyboardType: .emailAddress
            )
            
            FormField(
                label: "Company Phone",
                placeholder: "Enter phone number",
                text: $viewModel.companyPhone,
                keyboardType: .phonePad
            )
            
            FormField(
                label: "Company Address",
                placeholder: "Enter company address",
                text: $viewModel.companyAddress
            )
        }
    }
    
    private var ownerInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Owner Information")
            
            FormField(
                label: "Owner Name",
                placeholder: "Enter owner name",
                text: $viewModel.ownerName
            )
            
            FormField(
                label: "Owner Phone",
                placeholder: "Enter owner phone",
                text: $viewModel.ownerPhone,
                keyboardType: .phonePad
            )
            
            FormField(
                label: "Agent Referral Code (Optional)",
                placeholder: "Enter referral code",
                text: $viewModel.agentReferralCode
            )
        }
    }
    
    private var loginCredentialsSection: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            SectionHeader(title: "Login Credentials")
            
            FormField(
                label: "Login Email",
                placeholder: "login@example.com",
                text: $viewModel.loginEmail,
                keyboardType: .emailAddress
            )
            
            FormField(
                label: "Password (4 digits minimum)",
                placeholder: "Enter password",
                text: $viewModel.password,
                isSecure: true
            )
            
            FormField(
                label: "Confirm Password",
                placeholder: "Re-enter password",
                text: $viewModel.confirmPassword,
                isSecure: true
            )
        }
    }
    
    private var termsSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                viewModel.acceptedTerms.toggle()
            }) {
                Image(systemName: viewModel.acceptedTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(viewModel.acceptedTerms ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("I agree with ")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                +
                Text("Terms & Condition")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                    .underline()
                +
                Text(" and ")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                +
                Text("Company Agreement")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.primary)
                    .underline()
            }
            .onTapGesture {
                showTermsSheet = true
            }
        }
        .padding(.top, AppTheme.Spacing.small)
    }
    
    private var registerButton: some View {
        Button(action: {
            viewModel.register {
                // Success callback - dismiss handled by alert
            }
        }) {
            Text("Register")
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.isFormValid))
        .disabled(!viewModel.isFormValid)
    }
}

// MARK: - Helper Views

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Spacer()
        }
        .padding(.top, AppTheme.Spacing.small)
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(label)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .outlinedTextField()
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress)
                    .outlinedTextField()
            }
        }
    }
}

struct TermsWebView: View {
    let url: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            WebViewRepresentable(url: URL(string: url))
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

import WebKit

struct CompanyRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyRegistrationView()
    }
}
