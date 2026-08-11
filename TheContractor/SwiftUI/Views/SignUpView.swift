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
//  Three steps, matching Android: the number, the SMS code, then the account.
//
//  The code step is the only thing standing between a stranger and an account on someone else's number.
//  There is no server-side OTP on either platform — `Account/phone_check` only reports whether a number
//  is free, and `Account/user_register` accepts whatever it is handed — so the gate is entirely
//  client-side, in `PhoneAuthService`. `Account/phone_check` still runs first, so a number that is
//  already registered is rejected before an SMS is spent on it.
//

import SwiftUI

struct SignUpView: View {
    /// Called once the account exists and the session is stored. The caller pushes the drawer, exactly
    /// as it does after a normal sign-in.
    let onRegistered: () -> Void
    let onCancel: () -> Void

    private enum Step {
        case phone
        case code
        case details
    }

    @State private var step: Step = .phone

    @State private var phone = ""
    @State private var code = ""
    /// Android hides its resend button behind a 60-second countdown and shows the remaining time.
    @State private var secondsUntilResend = 0
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
            VendorTopBar(title: title, onBack: goBack)

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.m) {
                        switch step {
                        case .phone:
                            phoneStep
                        case .code:
                            codeStep
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
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if secondsUntilResend > 0 { secondsUntilResend -= 1 }
        }
    }

    private var title: String {
        switch step {
        case .phone: return "Create account"
        case .code: return "Verify your number"
        case .details: return "Your details"
        }
    }

    /// Stepping back off the code screen throws the verification away, so re-entering a number always
    /// starts a fresh one rather than checking the new number against the old number's code.
    private func goBack() {
        switch step {
        case .phone:
            onCancel()
        case .code:
            PhoneAuthService.shared.reset()
            code = ""
            secondsUntilResend = 0
            withAnimation { step = .phone }
        case .details:
            withAnimation { step = .code }
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

    // MARK: - Step 2, the code

    private var codeStep: some View {
        VStack(spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                Text("Enter the code we sent you")
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                Text("We sent a code to \(PhoneNumber.e164(phone)).")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                TextField("123456", text: $code)
                    .keyboardType(.numberPad)
                    .font(VendorTheme.Text.metric)
                    .multilineTextAlignment(.center)
                    .padding(VendorTheme.Space.m)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.surfaceRaised)
                    )

                // Android shows a live countdown and swaps in the resend button only once it reaches zero.
                if secondsUntilResend > 0 {
                    Text("Resend in \(secondsUntilResend / 60):\(String(format: "%02d", secondsUntilResend % 60))")
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textTertiary)
                } else {
                    Button(action: sendCode) {
                        Text("Resend code")
                            .font(VendorTheme.Text.label)
                            .foregroundColor(VendorTheme.textPrimary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isBusy)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            primaryButton("Verify", action: verifyCode)
        }
    }

    // MARK: - Step 3, the account

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
                    guard available else {
                        isBusy = false
                        // The backend's own wording covers "already registered".
                        notice = message.isEmpty ? "This number cannot be used" : message
                        return
                    }
                    // Free to register — now prove the number belongs to whoever is asking. `isBusy`
                    // stays on through the send, which is Android showing its progress dialog across
                    // both calls.
                    sendCode()
                }
            }
        }
    }

    /// Sends the SMS, and doubles as the resend action — Android's `ResendCode()` is the same call with
    /// the same options.
    private func sendCode() {
        isBusy = true
        PhoneAuthService.shared.sendCode(to: PhoneNumber.e164(phone)) { error in
            GCD.async(.Main) {
                isBusy = false
                if let error = error {
                    notice = error
                    // Android drops back to the number field when verification cannot start.
                    withAnimation { step = .phone }
                    return
                }
                code = ""
                secondsUntilResend = PhoneAuthService.resendInterval
                withAnimation { step = .code }
            }
        }
    }

    private func verifyCode() {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            notice = "Enter the code"
            return
        }

        isBusy = true
        PhoneAuthService.shared.verify(code: trimmed) { error in
            GCD.async(.Main) {
                isBusy = false
                if let error = error {
                    notice = error
                    return
                }
                withAnimation { step = .details }
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
