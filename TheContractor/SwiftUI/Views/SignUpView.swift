//
//  SignUpView.swift
//  TheContractor
//
//  Consumer sign-up — Android's `VerifyNumber` → `Register` pair.
//
//  What it replaces: `RegistrationViewController` was twenty lines with an empty `viewDidLoad` and
//  `VerifyNumberViewController` had a back button and nothing else, so a new user could not create an
//  account at all. Everything else on the consumer side assumes an account already exists.
//
//  **The one step that is not replicated: the SMS code.** Android sends it through Firebase Phone Auth
//  and opens the details form only once the code is confirmed. There is no server-side OTP endpoint —
//  the SMS gate lives entirely in the client — and this app has no Firebase, the same blocker that
//  keeps both inboxes switched off. `Account/user_register` accepts a number with no proof of
//  ownership, so the number is checked for availability and taken on trust. When Firebase is added,
//  the code step slots in between the two steps below and nothing else has to change.
//

import SwiftUI

struct SignUpView: View {
    /// Called once the account exists and the session is stored. The caller pushes the drawer, exactly
    /// as it does after a normal sign-in.
    let onRegistered: () -> Void
    let onCancel: () -> Void

    private enum Step {
        case phone
        case details
    }

    @State private var step: Step = .phone

    @State private var phone = ""
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var pin = ""
    @State private var confirmPin = ""

    @State private var isBusy = false
    @State private var notice: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: step == .phone ? "Create account" : "Your details",
                         onBack: { step == .phone ? onCancel() : withAnimation { step = .phone } })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.m) {
                        switch step {
                        case .phone:
                            phoneStep
                        case .details:
                            detailsStep
                        }
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isBusy {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { notice != nil }, set: { _ in notice = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notice ?? "")
        }
    }

    // MARK: - Step 1, the number

    private var phoneStep: some View {
        VStack(spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                Text("What's your mobile number?")
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                Text("You'll sign in with this number and a 4-digit PIN.")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

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
                        .font(VendorTheme.Text.body)
                        .padding(.horizontal, VendorTheme.Space.s)
                        .frame(minHeight: VendorTheme.minTapTarget)
                        .background(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                .fill(VendorTheme.surfaceRaised)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            primaryButton("Continue", action: checkPhone)
        }
    }

    // MARK: - Step 2, the account

    private var detailsStep: some View {
        VStack(spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                VendorField(label: "Mobile number", value: PhoneNumber.e164(phone))

                field("USERNAME", text: $username, placeholder: "How you'll be known",
                      capitalization: .none)
                Text("Letters and numbers, 5–20 characters. Dots, dashes and underscores are allowed in the middle.")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                field("FIRST NAME", text: $firstName, placeholder: "First name")
                field("LAST NAME", text: $lastName, placeholder: "Last name")
                field("EMAIL", text: $email, placeholder: "you@example.com", keyboard: .emailAddress,
                      capitalization: .none)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                VendorSectionHeader(title: "Choose a PIN")
                secureField("4-DIGIT PIN", text: $pin)
                secureField("CONFIRM PIN", text: $confirmPin)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            primaryButton("Create account", action: register)
        }
    }

    // MARK: - Pieces

    private func label(_ text: String) -> some View {
        Text(text)
            .font(VendorTheme.Text.label)
            .foregroundColor(VendorTheme.textTertiary)
            .tracking(0.4)
    }

    private func field(_ title: String, text: Binding<String>, placeholder: String,
                       keyboard: UIKeyboardType = .default,
                       capitalization: UITextAutocapitalizationType = .words) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            label(title)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocapitalization(capitalization)
                .disableAutocorrection(true)
                .font(VendorTheme.Text.body)
                .padding(VendorTheme.Space.s)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
        }
    }

    private func secureField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            label(title)
            SecureField("••••", text: text)
                .keyboardType(.numberPad)
                .font(VendorTheme.Text.body)
                .padding(VendorTheme.Space.s)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
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
        .disabled(isBusy)
    }

    // MARK: - Actions

    private func checkPhone() {
        let digits = PhoneNumber.localDigits(phone)
        guard !digits.isEmpty else {
            notice = "Enter phone number"
            return
        }
        guard digits.count >= 8 else {
            notice = "Enter a complete mobile number"
            return
        }

        isBusy = true
        GCD.async(.Background) {
            LoginService.shared().checkPhoneAvailability(phone: PhoneNumber.e164(phone)) { message, available in
                GCD.async(.Main) {
                    isBusy = false
                    if available {
                        withAnimation { step = .details }
                    } else {
                        // The backend's own wording covers "already registered".
                        notice = message.isEmpty ? "This number cannot be used" : message
                    }
                }
            }
        }
    }

    /// Android's `Register` validation, in its order and with its rules.
    private func register() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedUsername.isEmpty else {
            notice = "Enter user name"
            return
        }
        guard SignUpView.isValidUsername(trimmedUsername) else {
            notice = "Enter a valid user name"
            return
        }
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            notice = "Enter name"
            return
        }
        guard !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
            notice = "Enter sur name"
            return
        }
        guard !PhoneNumber.localDigits(phone).isEmpty else {
            notice = "Enter phone number"
            return
        }
        guard !trimmedEmail.isEmpty else {
            notice = "Enter email address"
            return
        }
        guard SignUpView.isValidEmail(trimmedEmail) else {
            notice = "Enter a valid email address"
            return
        }
        guard !pin.isEmpty else {
            notice = "Enter pin code"
            return
        }
        guard pin.count >= 4 else {
            notice = "Enter at least 4 digit pin"
            return
        }
        guard !confirmPin.isEmpty else {
            notice = "Confirm your 4 digit pin"
            return
        }
        guard pin == confirmPin else {
            notice = "Pin does not match"
            return
        }

        isBusy = true
        GCD.async(.Background) {
            LoginService.shared().registerUser(username: trimmedUsername,
                                               firstName: firstName.trimmingCharacters(in: .whitespaces),
                                               lastName: lastName.trimmingCharacters(in: .whitespaces),
                                               phone: PhoneNumber.e164(phone),
                                               email: trimmedEmail,
                                               password: pin) { message, success in
                GCD.async(.Main) {
                    isBusy = false
                    if success {
                        onRegistered()
                    } else {
                        notice = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }

    // MARK: - Validation, ported from Android

    /// `Register.isValidUsername` — alphanumeric at both ends, 5–20 characters, and a dot, dash or
    /// underscore only singly and only in the middle.
    static func isValidUsername(_ username: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){3,18}[a-zA-Z0-9]$"
        return username.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidEmail(_ address: String) -> Bool {
        let pattern = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        return address.range(of: pattern, options: .regularExpression) != nil
    }
}
