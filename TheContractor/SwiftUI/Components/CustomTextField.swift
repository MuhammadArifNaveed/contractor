//
//  CustomTextField.swift
//  TheContractor
//
//  Reusable text field component matching Android EditText design
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    @State private var isSecureVisible: Bool = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.gray)
                    .frame(width: 20)
            }
            
            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .font(AppTheme.Fonts.regular(15))
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppTheme.Fonts.regular(15))
                    .keyboardType(keyboardType)
            }
            
            if isSecure {
                Button(action: { isSecureVisible.toggle() }) {
                    Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                        .foregroundColor(AppTheme.Colors.gray)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSearch: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.Colors.gray)
            
            TextField(placeholder, text: $text, onCommit: {
                onSearch?()
            })
            .font(AppTheme.Fonts.regular(15))
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.gray)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

// MARK: - Preview
struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            CustomTextField(placeholder: "Enter your name", text: .constant(""), icon: "person")
            CustomTextField(placeholder: "Enter email", text: .constant(""), icon: "envelope", keyboardType: .emailAddress)
            CustomTextField(placeholder: "Password", text: .constant(""), icon: "lock", isSecure: true)
            SearchBar(text: .constant(""), placeholder: "Search companies...")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
