//
//  ForgotPasswordView.swift
//  TheContractor
//
//  Resetting a forgotten password — Android's `ForgotPassword` → `NewPassword` pair.
//
//  Three steps, the middle one being the point: the number, the SMS code, then the new password.
//  `Account/update_password` takes a phone number and a new password and asks for nothing else, so
//  without the code step anyone who knows a number can take that account over. Android's gate is Firebase
//  phone verification and nothing more; this is the same gate.
//
//  What replaces `ForgetPasswordViewController`, which collected the number and the new password on one
//  screen and posted them straight to `Account/update_password` with no verification at all.
//
//  One inversion to keep in mind: `Account/phone_check` is shared with sign-up but read the opposite way
//  round. Signing up needs the number to be **free**; resetting needs it to be **taken**. Android reads
//  `error == "false"` as "phone number not registered" here and stops.
//

import SwiftUI

struct ForgotPasswordView: View {
    /// Called once the password has been changed. The caller pops back to the login screen.
    let onFinished: () -> Void
    let onCancel: () -> Void

    private enum Step {
        case phone
        case code
        case password
    }

    @State private var step: Step = .phone

    @State private var phone = ""
    @State private var code = ""
    @State private var secondsUntilResend = 0
    @State private var password = ""
    @State private var confirmPassword = ""

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
                        case .password:
                            passwordStep
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
        case .phone: return "Reset password"
        case .code: return "Verify your number"
        case .password: return "New password"
        }
    }

    /// Stepping back off the code screen throws the verification away, so a different number entered
    /// afterwards is not checked against the previous number's code.
    private func goBack() {
        switch step {
        case .phone:
            onCancel()
        case .code:
            PhoneAuthService.shared.reset()
            code = ""
            secondsUntilResend = 0
            withAnimation { step = .phone }
        case .password:
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

                Text("We'll send a code to confirm the number is yours before letting you change the password.")
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

    // MARK: - Step 3, the new password

    private var passwordStep: some View {
        VStack(spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                VendorField(label: "Mobile number", value: PhoneNumber.e164(phone))
                secureField("NEW PASSWORD", text: $password)
                secureField("CONFIRM PASSWORD", text: $confirmPassword)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            primaryButton("Change password", action: submit)
        }
    }

    // MARK: - Pieces

    private func secureField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text(title)
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)
            SecureField("••••", text: text)
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

    /// `Account/phone_check` read the other way round: a number that is *free* has no account to reset,
    /// which is Android's "phone number not registered".
    private func checkPhone() {
        let digits = PhoneNumber.localDigits(phone)
        guard digits.count >= 8 else {
            notice = digits.isEmpty ? "Enter phone number" : "Enter a complete mobile number"
            return
        }

        isBusy = true
        GCD.async(.Background) {
            LoginService.shared().checkPhoneAvailability(phone: PhoneNumber.e164(phone)) { _, available in
                GCD.async(.Main) {
                    guard !available else {
                        isBusy = false
                        notice = "That number is not registered."
                        return
                    }
                    sendCode()
                }
            }
        }
    }

    private func sendCode() {
        isBusy = true
        PhoneAuthService.shared.sendCode(to: PhoneNumber.e164(phone)) { error in
            GCD.async(.Main) {
                isBusy = false
                if let error = error {
                    notice = error
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
                withAnimation { step = .password }
            }
        }
    }

    private func submit() {
        // Android's `NewPassword` checks only that the two fields match and are non-empty.
        guard !password.isEmpty else {
            notice = "Enter a new password"
            return
        }
        guard password == confirmPassword else {
            notice = "Passwords do not match"
            return
        }

        isBusy = true
        GCD.async(.Background) {
            LoginService.shared().resetPassword(phone: PhoneNumber.e164(phone),
                                                newPassword: password) { message, success in
                GCD.async(.Main) {
                    isBusy = false
                    guard success else {
                        notice = message.isEmpty ? "Could not change the password" : message
                        return
                    }
                    PhoneAuthService.shared.reset()
                    onFinished()
                }
            }
        }
    }
}
