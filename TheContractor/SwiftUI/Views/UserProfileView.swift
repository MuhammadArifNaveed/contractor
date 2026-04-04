//
//  UserProfileView.swift
//  TheContractor
//
//  User profile screen matching Android ProfileFragment
//

import SwiftUI
import SafariServices

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showLogoutAlert = false
    @State private var safariURL: URL? = nil
    @State private var isLoggedIn = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isLoggedIn {
                    loggedInHeader
                }

                VStack(spacing: 0) {
                    if !isLoggedIn {
                        loginCreateAccountRow
                    }

                    if isLoggedIn {
                        loggedInMenuSection
                    }

                    commonMenuSection
                }
                .background(Color.white)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Yes", role: .destructive) { viewModel.logout() }
            Button("No", role: .cancel) {}
        } message: {
            Text("Are you sure you want to logout?")
        }
        .sheet(item: $safariURL) { url in
            SFSafariViewWrapper(url: url)
        }
        .onAppear {
            isLoggedIn = Global.shared.isLogedIn
            viewModel.loadUserInfo()
        }
    }

    // MARK: - Logged-In Header
    private var loggedInHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 90, height: 90)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color(UIColor.systemGray2))
                )

            Text(viewModel.userName.isEmpty ? "User" : viewModel.userName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            if !viewModel.userPhone.isEmpty {
                Text(viewModel.userPhone)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .padding(.bottom, 12)
    }

    // MARK: - Guest: Login/Create Account
    private var loginCreateAccountRow: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.goToLogin()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(width: 28)

                    Text("Login / Create Account")
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.white)

            Divider().padding(.leading, 58)
        }
    }

    // MARK: - Logged-In Menu Section
    private var loggedInMenuSection: some View {
        VStack(spacing: 0) {
            ProfileRow(icon: "person.crop.circle", title: "Edit Profile") {
                viewModel.navigateToEditProfile()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "lock", title: "Change Password") {
                viewModel.navigateToChangePassword()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "doc.text", title: "My Enquiries") {
                viewModel.navigateToEnquiries()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "doc.text.fill", title: "My Quotations") {
                viewModel.navigateToQuotations()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "briefcase", title: "My Job Applications") {
                viewModel.navigateToJobApplications()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "exclamationmark.bubble", title: "My Complaints") {
                viewModel.navigateToComplaints()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "cart", title: "My Cart") {
                viewModel.navigateToCart()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "phone", title: "Contact Us") {
                openWeb(AppLinks.AboutUS, title: "Contact Us")
            }
            Divider().padding(.leading, 58)
        }
    }

    // MARK: - Common Menu Section (shown for all users)
    private var commonMenuSection: some View {
        VStack(spacing: 0) {
            ProfileRow(icon: "info.circle", title: "About Us") {
                openWeb(AppLinks.AboutUS, title: "About Us")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "megaphone", title: "Advertisement") {
                openWeb(AppLinks.Advertisment, title: "Advertisement")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "building.2", title: "Register Company") {
                openWeb(AppLinks.Vendor, title: "Register Company")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "lock.shield", title: "Privacy Policy") {
                openWeb(AppLinks.Privacy, title: "Privacy Policy")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "doc.plaintext", title: "Terms and Conditions") {
                openWeb(AppLinks.Terms, title: "Terms and Conditions")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "book", title: "Guide") {
                openWeb(AppLinks.Guide, title: "Guide")
            }

            if isLoggedIn {
                Divider().padding(.leading, 58)
                Button {
                    showLogoutAlert = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.right.square")
                            .font(.system(size: 22))
                            .foregroundColor(.red)
                            .frame(width: 28)

                        Text("Logout")
                            .font(.system(size: 16))
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func openWeb(_ urlString: String, title: String) {
        if let url = URL(string: urlString) {
            safariURL = url
        }
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - SFSafariViewController wrapper
struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1)
        return vc
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Allow URL to be used as sheet item
extension URL: Identifiable {
    public var id: String { absoluteString }
}

// MARK: - Profile Option Row (kept for backward compat)
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let showDivider: Bool
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? .red : AppTheme.Colors.primary)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .black)
                Spacer()
                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        if showDivider { Divider().padding(.leading, 58) }
    }
}

// MARK: - Preview
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
