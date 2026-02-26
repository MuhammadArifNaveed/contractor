//  RegistrationView.swift
import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Info")) {
                    CustomTextField(placeholder: "First Name", text: $viewModel.firstName, icon: "person")
                    CustomTextField(placeholder: "Last Name", text: $viewModel.lastName, icon: "person")
                    CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                }
                Section(header: Text("Security")) {
                    CustomTextField(placeholder: "Password", text: $viewModel.password, icon: "lock", isSecure: true)
                    CustomTextField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, icon: "lock", isSecure: true)
                }
                if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.register() }) {
                        if viewModel.isLoading { ProgressView() } else { Text("Register").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
        }
    }
}
