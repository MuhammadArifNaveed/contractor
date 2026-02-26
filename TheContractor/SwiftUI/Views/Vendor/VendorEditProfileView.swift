//  VendorEditProfileView.swift
import SwiftUI
struct VendorEditProfileView: View {
    @StateObject private var viewModel = VendorEditProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Form {
            Section(header: Text("Company Info")) {
                CustomTextField(placeholder: "Company Name", text: $viewModel.companyName, icon: "building.2")
                CustomTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
                CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
            }
            Section(header: Text("Address")) {
                CustomTextField(placeholder: "Address", text: $viewModel.address, icon: "location")
                CustomTextField(placeholder: "City", text: $viewModel.city, icon: "building.2")
            }
            if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.updateProfile { presentationMode.wrappedValue.dismiss() } }) {
                    if viewModel.isSubmitting { ProgressView() } else { Text("Save").fontWeight(.semibold) }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
            }
        }
        .onAppear { viewModel.loadProfile() }
    }
}
class VendorEditProfileViewModel: ObservableObject {
    @Published var companyName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var address = ""
    @Published var city = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !companyName.isEmpty && !email.isEmpty && !phone.isEmpty }
    func loadProfile() { companyName = "My Company"; email = ""; phone = ""; address = ""; city = "" }
    func updateProfile(completion: @escaping () -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/update_vendor_profile", params: ["company_name": companyName, "email": email, "phone": phone, "address": address, "city": city]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
