//
//  UserProfileView.swift
//  TheContractor
//
//  User profile screen matching Android ProfileFragment
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                // Profile Header
                profileHeader
                
                // Profile Options
                VStack(spacing: 0) {
                    ProfileOptionRow(icon: "person.crop.circle", title: "Edit Profile", showDivider: true) {
                        showEditProfile = true
                    }
                    
                    ProfileOptionRow(icon: "doc.text", title: "My Enquiries", showDivider: true) {
                        viewModel.navigateToEnquiries()
                    }
                    
                    ProfileOptionRow(icon: "doc.text.fill", title: "My Quotations", showDivider: true) {
                        viewModel.navigateToQuotations()
                    }
                    
                    ProfileOptionRow(icon: "briefcase", title: "My Job Applications", showDivider: true) {
                        viewModel.navigateToJobApplications()
                    }
                    
                    ProfileOptionRow(icon: "exclamationmark.bubble", title: "My Complaints", showDivider: true) {
                        viewModel.navigateToComplaints()
                    }
                    
                    ProfileOptionRow(icon: "cart", title: "My Cart", showDivider: true) {
                        viewModel.navigateToCart()
                    }
                    
                    ProfileOptionRow(icon: "gearshape", title: "Settings", showDivider: true) {
                        viewModel.navigateToSettings()
                    }
                    
                    ProfileOptionRow(icon: "arrow.right.square", title: "Logout", showDivider: false, isDestructive: true) {
                        viewModel.logout()
                    }
                }
                .background(Color.white)
                .cornerRadius(AppTheme.CornerRadius.medium)
                .padding(.horizontal, AppTheme.Spacing.medium)
                
                Spacer(minLength: 20)
            }
            .padding(.top, AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            // Profile Image
            Circle()
                .fill(AppTheme.Colors.primary.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.Colors.primary)
                )
            
            // User Info
            VStack(spacing: 4) {
                Text(viewModel.userName)
                    .font(AppTheme.Fonts.bold(20))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if !viewModel.userEmail.isEmpty {
                    Text(viewModel.userEmail)
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                if !viewModel.userPhone.isEmpty {
                    Text(viewModel.userPhone)
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
        }
        .padding(AppTheme.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.primary.opacity(0.1),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(AppTheme.CornerRadius.medium)
        .padding(.horizontal, AppTheme.Spacing.medium)
    }
}

// MARK: - Profile Option Row
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let showDivider: Bool
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? .red : AppTheme.Colors.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(AppTheme.Fonts.regular(16))
                    .foregroundColor(isDestructive ? .red : AppTheme.Colors.textPrimary)
                
                Spacer()
                
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.gray)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        
        if showDivider {
            Divider()
                .padding(.leading, 60)
        }
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileView()
        }
    }
}
