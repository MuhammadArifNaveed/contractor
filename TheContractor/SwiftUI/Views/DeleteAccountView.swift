//
//  DeleteAccountView.swift
//  TheContractor
//
//  App Store Review Guideline 5.1.1(v): an app that supports account creation must let the user
//  initiate account deletion from within the app. A "contact support to delete" link does not satisfy
//  it, and neither does a settings page that only signs you out. Without this the build is rejected.
//
//  One screen serves both sides — the only differences are which endpoint is called and what the
//  account is called on screen — because the consequences and the confirmation are identical.
//
//  Deliberately more friction than a single tap: the button stays disabled until the word DELETE is
//  typed. Apple asks that deletion be unambiguous rather than easy to hit by accident, and this is
//  irreversible on the backend with no undo and no grace period.
//

import SwiftUI

struct DeleteAccountView: View {
    enum Account {
        case consumer(userId: String)
        case company(serialNumber: String)

        var title: String {
            switch self {
            case .consumer: return "Delete your account"
            case .company:  return "Delete your company account"
            }
        }

        /// Named concretely so the user knows exactly what is being destroyed.
        var losing: [String] {
            switch self {
            case .consumer:
                return ["Your profile, contact details and saved addresses",
                        "Your enquiries, quotations, complaints and estimate requests",
                        "Your job applications and freelancer profile",
                        "Your conversations with companies"]
            case .company:
                return ["Your company profile, logo and contact details",
                        "Your workshop ads, job posts and the applications to them",
                        "Your enquiries, quotations and reviews",
                        "Your membership and any remaining leads on it",
                        "Your conversations with customers"]
            }
        }
    }

    let account: Account

    @State private var confirmation = ""
    @State private var isDeleting = false
    @State private var errorMessage: String?
    @State private var didDelete = false

    @Environment(\.dismiss) private var dismiss

    /// The exact word the user has to type. Uppercase so it cannot be produced by autocorrect.
    private let requiredWord = "DELETE"

    private var canDelete: Bool {
        confirmation.trimmingCharacters(in: .whitespaces).uppercased() == requiredWord && !isDeleting
    }

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Delete account", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                        warningCard
                        confirmField
                        deleteButton
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isDeleting {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        // Nothing to return to once the account is gone, so this drops the user at the login screen
        // rather than back into a signed-in hierarchy reading a deleted account.
        .alert("Account deleted", isPresented: $didDelete) {
            Button("OK") { finishSignOut() }
        } message: {
            Text("Your account and its data have been removed.")
        }
    }

    private var warningCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            HStack(spacing: VendorTheme.Space.s) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(VendorTheme.negative)
                Text(account.title)
                    .font(VendorTheme.Text.sectionTitle)
                    .foregroundColor(VendorTheme.textPrimary)
            }

            Text("This cannot be undone. Deleting your account permanently removes:")
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textSecondary)

            VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
                ForEach(account.losing, id: \.self) { item in
                    HStack(alignment: .top, spacing: VendorTheme.Space.s) {
                        Text("•").foregroundColor(VendorTheme.textSecondary)
                        Text(item)
                            .font(VendorTheme.Text.body)
                            .foregroundColor(VendorTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Text("You will not be able to sign in again with these details, and this data cannot be recovered by support.")
                .font(VendorTheme.Text.meta)
                .foregroundColor(VendorTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var confirmField: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text("TYPE \(requiredWord) TO CONFIRM")
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)

            TextField(requiredWord, text: $confirmation)
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textPrimary)
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
                .padding(VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
        }
    }

    private var deleteButton: some View {
        Button(action: performDelete) {
            Text("Delete my account permanently")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.negative)
                )
        }
        .disabled(!canDelete)
        .opacity(canDelete ? 1 : 0.45)
    }

    private func performDelete() {
        guard canDelete else { return }
        isDeleting = true

        let finish: (String, Bool) -> Void = { message, success in
            GCD.async(.Main) {
                isDeleting = false
                if success {
                    didDelete = true
                } else {
                    errorMessage = message.isEmpty ? "Your account could not be deleted. Please try again." : message
                }
            }
        }

        GCD.async(.Background) {
            switch account {
            case .consumer(let userId):
                LoginService.shared().deleteUserAccount(userId: userId, completion: finish)
            case .company(let serialNumber):
                LoginService.shared().deleteCompanyAccount(serialNumber: serialNumber, completion: finish)
            }
        }
    }

    /// The stored session has to go with the account, or the next launch restores a session pointing at
    /// a record the backend no longer has. `logoutUser()` on the container clears both sides and routes
    /// to the login screen; this reaches it the same way the drawer's Logout does.
    private func finishSignOut() {
        NotificationCenter.default.post(name: .init("AccountDeleted"), object: nil)
        dismiss()
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(account: .consumer(userId: "45"))
    }
}
