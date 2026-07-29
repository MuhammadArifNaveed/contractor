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
    @State private var refreshTrigger = UUID()

    private var isLoggedIn: Bool {
        let _ = refreshTrigger
        return Global.shared.isLogedIn
    }
    
    private var isVendor: Bool {
        return Global.shared.isVendor
    }
    
    private var vendorName: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["company_name"] as? String ?? ""
        }
        return ""
    }
    
    private var vendorPhone: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["company_phone"] as? String ?? ""
        }
        return ""
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header section
                if isLoggedIn {
                    loggedInHeaderHorizontal
                } else {
                    guestLoginCard
                }

                // 6-card grid (only for logged-in users)
                if isLoggedIn {
                    actionCardsGrid
                        .padding(.vertical, 16)
                }

                // Menu sections
                VStack(spacing: 0) {
                    if isLoggedIn {
                        loggedInMenuSection
                    }
                    commonMenuSection
                }
                .background(Color.white)
            }
            .padding(.top, 150)
            .padding(.bottom, 100)
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
            refreshTrigger = UUID()
            viewModel.loadUserInfo()
        }
    }

    // MARK: - Logged-In Header (Horizontal Layout matching Android)
    private var loggedInHeaderHorizontal: some View {
        HStack(spacing: 12) {
            // Left: Name and Phone
            VStack(alignment: .leading, spacing: 4) {
                if isVendor {
                    Text(vendorName.isEmpty ? "Company" : vendorName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    if !vendorPhone.isEmpty {
                        Text(vendorPhone)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(viewModel.userName.isEmpty ? "User" : viewModel.userName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    if !viewModel.userPhone.isEmpty {
                        Text(viewModel.userPhone)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Right: Avatar
            Circle()
                .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: isVendor ? "building.2.fill" : "person.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - 6-Card Action Grid (matching Android)
    private var actionCardsGrid: some View {
        VStack(spacing: 12) {
            // Row 1: Enquiries, Submit Enquiry, Quotations
            HStack(spacing: 12) {
                ActionCard(icon: "doc.text", title: "Enquiries") {
                    viewModel.navigateToEnquiries()
                }
                ActionCard(icon: "paperplane.fill", title: "Submit Enquiry") {
                    viewModel.navigateToCart()
                }
                ActionCard(icon: "doc.text.fill", title: "Quotations") {
                    viewModel.navigateToQuotations()
                }
            }
            
            // Row 2: Complaints, Estimations, Job Applications
            HStack(spacing: 12) {
                ActionCard(icon: "exclamationmark.bubble.fill", title: "Complaints") {
                    viewModel.navigateToComplaints()
                }
                ActionCard(icon: "calculator.fill", title: "Estimations") {
                    viewModel.navigateToEstimations()
                }
                ActionCard(icon: "briefcase.fill", title: "Job Applications") {
                    viewModel.navigateToJobApplications()
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }

    // MARK: - Guest: Login/Create Account Card (matches Android layout)
    private var guestLoginCard: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.goToLogin() }) {
                HStack {
                    Text("Login or Create Account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())

            Circle()
                .fill(Color(red: 242/255, green: 190/255, blue: 54/255))
                .frame(width: 58, height: 58)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }

    // MARK: - Logged-In Menu Section (matching Android order)
    private var loggedInMenuSection: some View {
        VStack(spacing: 0) {
            Divider()
            ProfileRow(icon: "globe", title: "Select Language") {
                // TODO: Implement language selection
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "person.crop.circle", title: "Profile Settings") {
                viewModel.navigateToEditProfile()
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "lock", title: "Change Password") {
                viewModel.navigateToChangePassword()
            }
            Divider().padding(.leading, 58)
        }
    }

    // MARK: - Common Menu Section (shown for all users, matching Android)
    private var commonMenuSection: some View {
        VStack(spacing: 0) {
            if !isLoggedIn {
                Divider()
                ProfileRow(icon: "globe", title: "Select Language") {
                    // TODO: Implement language selection
                }
                Divider().padding(.leading, 58)
            }
            
            ProfileRow(icon: "info.circle", title: "About Us") {
                openWeb(AppLinks.AboutUS, title: "About Us")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "megaphone", title: "Advertisement") {
                openWeb(AppLinks.Advertisment, title: "Advertisement")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "building.2", title: "Register your Company") {
                openWeb(AppLinks.Vendor, title: "Register Company")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "lock.shield", title: "Privacy Polices") {
                openWeb(AppLinks.Privacy, title: "Privacy Policy")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "doc.plaintext", title: "Terms & Conditions") {
                openWeb(AppLinks.Terms, title: "Terms and Conditions")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "book", title: "Guide") {
                openWeb(AppLinks.Guide, title: "Guide")
            }
            Divider().padding(.leading, 58)
            ProfileRow(icon: "phone", title: "Contact Us") {
                openWeb(AppLinks.AboutUS, title: "Contact Us")
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

// MARK: - Action Card (for 6-card grid)
struct ActionCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.Colors.primary)
                    .frame(height: 40)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
