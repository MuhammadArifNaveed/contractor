//
//  LoadingView.swift
//  TheContractor
//
//  Reusable loading indicator matching Android design
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                .scaleEffect(1.5)
            
            Text(message)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.opacity(0.9))
    }
}

struct EmptyStateView: View {
    var icon: String = "tray"
    var title: String = "No Data"
    var message: String = "There's nothing to show here yet."
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.gray)
            
            VStack(spacing: AppTheme.Spacing.small) {
                Text(title)
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(message)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.Spacing.xxLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    var message: String
    var onRetry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.7))
            
            VStack(spacing: AppTheme.Spacing.small) {
                Text("Oops!")
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(message)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Text("Retry")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.large)
                }
            }
        }
        .padding(AppTheme.Spacing.xxLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView()
                .previewDisplayName("Loading")
            
            EmptyStateView()
                .previewDisplayName("Empty State")
            
            ErrorView(message: "Failed to load data. Please try again.") {
                print("Retry tapped")
            }
            .previewDisplayName("Error State")
        }
    }
}
