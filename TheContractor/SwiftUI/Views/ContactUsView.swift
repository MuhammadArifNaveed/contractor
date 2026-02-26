//  ContactUsView.swift
import SwiftUI
struct ContactUsView: View {
    @StateObject private var viewModel = ContactUsViewModel()
    var body: some View {
        Form {
            Section(header: Text("Your Info")) {
                CustomTextField(placeholder: "Name", text: $viewModel.name, icon: "person")
                CustomTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
            }
            Section(header: Text("Message")) { TextEditor(text: $viewModel.message).frame(height: 120) }
            if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            if !viewModel.successMessage.isEmpty { Section { Text(viewModel.successMessage).foregroundColor(.green) } }
            Section {
                Button(action: { viewModel.sendMessage() }) {
                    if viewModel.isSubmitting { ProgressView() } else { Text("Send Message").frame(maxWidth: .infinity).foregroundColor(.white) }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                .listRowBackground(AppTheme.Colors.primary)
            }
        }
        .navigationTitle("Contact Us")
    }
}
class ContactUsViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !name.isEmpty && !email.isEmpty && !message.isEmpty }
    func sendMessage() {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/contact_us", params: ["name": name, "email": email, "message": message]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { self?.successMessage = "Message sent successfully!"; self?.name = ""; self?.email = ""; self?.message = "" } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
