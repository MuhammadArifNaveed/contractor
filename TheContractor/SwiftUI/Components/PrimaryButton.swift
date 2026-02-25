//
//  PrimaryButton.swift
//  TheContractor
//
//  Reusable button components matching Android design
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var backgroundColor: Color = AppTheme.Colors.primary
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isEnabled ? backgroundColor : AppTheme.Colors.gray)
            .cornerRadius(AppTheme.CornerRadius.large)
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

struct OutlineButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var borderColor: Color = AppTheme.Colors.primary
    var textColor: Color = AppTheme.Colors.primary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(AppTheme.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

struct SmallButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = AppTheme.Colors.primary
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Fonts.semibold(14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

// MARK: - Preview
struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PrimaryButton(title: "Submit", action: {})
            PrimaryButton(title: "Loading...", action: {}, isLoading: true)
            OutlineButton(title: "Cancel", action: {})
            SmallButton(title: "Apply", action: {})
            PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
