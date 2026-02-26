//  VerifyNumberView.swift
import SwiftUI
struct VerifyNumberView: View {
    @StateObject private var viewModel = VerifyNumberViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.shield").font(.system(size: 60)).foregroundColor(AppTheme.Colors.primary)
            Text("Verify Your Number").font(AppTheme.Fonts.bold(24))
            Text("Enter the verification code sent to your phone").font(AppTheme.Fonts.regular(14)).foregroundColor(.gray).multilineTextAlignment(.center)
            CustomTextField(placeholder: "Verification Code", text: $viewModel.code, icon: "number", keyboardType: .numberPad)
            if !viewModel.errorMessage.isEmpty { Text(viewModel.errorMessage).foregroundColor(.red).font(AppTheme.Fonts.regular(14)) }
            PrimaryButton(title: "Verify") { viewModel.verify { presentationMode.wrappedValue.dismiss() } }
                .disabled(viewModel.isVerifying)
            Button("Resend Code") { viewModel.resendCode() }.font(AppTheme.Fonts.medium(14)).foregroundColor(AppTheme.Colors.primary)
            Spacer()
        }
        .padding(24)
        .navigationTitle("Verification")
    }
}
class VerifyNumberViewModel: ObservableObject {
    @Published var code = ""
    @Published var errorMessage = ""
    @Published var isVerifying = false
    func verify(completion: @escaping () -> Void) {
        guard !code.isEmpty else { errorMessage = "Enter code"; return }
        isVerifying = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/verify_number", params: ["code": code]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isVerifying = false
                if success { completion() } else { self?.errorMessage = msg ?? "Invalid code" }
            }
        }
    }
    func resendCode() { print("Resend code") }
}
