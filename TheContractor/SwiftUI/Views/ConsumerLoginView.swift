//
//  ConsumerLoginView.swift
//  TheContractor
//
//  The consumer sign-in screen.
//
//  What it replaces: a storyboard scene holding the logo, the two fields and the Login button, with
//  "Create an account", "Forgot Password?" and "Login as a Company" added programmatically and pinned to
//  the bottom safe area. That split is why the screen had a large dead gap through its middle — the
//  storyboard content stopped a third of the way down and the buttons started at the very bottom — and
//  why it looked nothing like `SignUpView` and `ForgotPasswordView`, the two screens it navigates to.
//
//  This owns only layout and the two fields. Every action is handed back to `LoginViewController`, which
//  keeps the validation, `userLogin(params:)` and all the navigation it already had.
//

import SwiftUI

struct ConsumerLoginView: View {
    let onLogin: (_ phone: String, _ pin: String) -> Void
    let onSkip: () -> Void
    let onCreateAccount: () -> Void
    let onForgotPassword: () -> Void
    let onCompanyLogin: () -> Void

    @State private var phone = ""
    @State private var pin = ""
    @FocusState private var focus: Field?

    private enum Field { case phone, pin }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: VendorTheme.Space.l) {
                    // `.scaledToFit` matters: the storyboard stretched this lockup to fill its image
                    // view, which is why the wordmark looked wrong.
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260, maxHeight: 84)
                        .padding(.top, VendorTheme.Space.l)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        Text("Welcome back")
                            .font(VendorTheme.Text.screenTitle)
                            .foregroundColor(VendorTheme.textPrimary)

                        Text("Sign in with your mobile number and PIN.")
                            .font(VendorTheme.Text.meta)
                            .foregroundColor(VendorTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    credentialsCard

                    primaryButton("Login") { onLogin(phone, pin) }

                    separator

                    secondaryButton("Create an account", action: onCreateAccount)
                    secondaryButton("Login as a Company", action: onCompanyLogin)
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas)
        }
        .background(VendorTheme.canvas.ignoresSafeArea())
        // Tapping the background dismisses the keypad — neither field has a return key to do it.
        .contentShape(Rectangle())
        .onTapGesture { focus = nil }
    }

    // MARK: - Header

    /// Not `VendorTopBar`: that always draws a leading chevron or hamburger, and there is nothing to go
    /// back to from the login screen. The colours and height match it.
    private var header: some View {
        HStack {
            Text("Login")
                .font(VendorTheme.Text.screenTitle)
                .foregroundColor(VendorTheme.onAccent)

            Spacer(minLength: VendorTheme.Space.s)

            Button(action: onSkip) {
                Text("Skip")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.onAccent)
                    .frame(minHeight: VendorTheme.minTapTarget)
            }
        }
        .padding(.horizontal, VendorTheme.Space.l)
        .frame(height: VendorTheme.minTapTarget + VendorTheme.Space.s)
        // The bar's colour continues up behind the status bar, while its content stays below it. The
        // storyboard scene this replaces was full-bleed yellow at the top and would otherwise regress
        // to a grey strip.
        .background(VendorTheme.accent.ignoresSafeArea(edges: .top))
    }

    // MARK: - Fields

    private var credentialsCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                label("MOBILE NUMBER")

                HStack(spacing: VendorTheme.Space.s) {
                    Text("+971")
                        .font(VendorTheme.Text.body)
                        .foregroundColor(VendorTheme.textSecondary)
                        .padding(.horizontal, VendorTheme.Space.m)
                        .frame(minHeight: VendorTheme.minTapTarget)
                        .background(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                .fill(VendorTheme.surfaceRaised)
                        )

                    TextField("50 123 4567", text: $phone)
                        .keyboardType(.numberPad)
                        .focused($focus, equals: .phone)
                        .font(VendorTheme.Text.body)
                        .padding(.horizontal, VendorTheme.Space.s)
                        .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                        .background(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                .fill(VendorTheme.surfaceRaised)
                        )
                }
            }

            VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                label("PIN")

                SecureField("••••", text: $pin)
                    .keyboardType(.numberPad)
                    .focused($focus, equals: .pin)
                    .font(VendorTheme.Text.body)
                    .padding(.horizontal, VendorTheme.Space.m)
                    .frame(minHeight: VendorTheme.minTapTarget)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.surfaceRaised)
                    )
            }

            Button(action: onForgotPassword) {
                Text("Forgot your PIN?")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Pieces

    private func label(_ text: String) -> some View {
        Text(text)
            .font(VendorTheme.Text.label)
            .foregroundColor(VendorTheme.textTertiary)
            .tracking(0.4)
    }

    private var separator: some View {
        HStack(spacing: VendorTheme.Space.m) {
            Rectangle().fill(VendorTheme.separator).frame(height: 1)
            Text("OR")
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
            Rectangle().fill(VendorTheme.separator).frame(height: 1)
        }
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.onAccent)
                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.textPrimary)
                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .stroke(VendorTheme.separator, lineWidth: 1)
                )
        }
        .buttonStyle(VendorPressStyle())
    }
}
