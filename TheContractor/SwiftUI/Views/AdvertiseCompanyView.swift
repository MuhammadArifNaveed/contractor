//  AdvertiseCompanyView.swift
import SwiftUI
struct AdvertiseCompanyView: View {
    @StateObject private var viewModel = AdvertiseCompanyViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company Details")) {
                    CustomTextField(placeholder: "Company Name", text: $viewModel.companyName, icon: "building.2")
                    CustomTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
                    CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                }
                Section(header: Text("Advertisement Details")) {
                    TextEditor(text: $viewModel.message).frame(height: 100)
                }
                if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            }
            .navigationTitle("Advertise Company")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.submit { presentationMode.wrappedValue.dismiss() } }) {
                        if viewModel.isSubmitting { ProgressView() } else { Text("Submit").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
        }
    }
}
class AdvertiseCompanyViewModel: ObservableObject {
    @Published var companyName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !companyName.isEmpty && !email.isEmpty && !phone.isEmpty }
    func submit(completion: @escaping () -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/advertise_company", params: ["company_name": companyName, "email": email, "phone": phone, "message": message]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
