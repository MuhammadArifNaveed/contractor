//
//  CheckoutView.swift
//  TheContractor
//

import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    CustomTextField(placeholder: "Full Name", text: $viewModel.name, icon: "person")
                    CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                    CustomTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
                }
                
                Section(header: Text("Delivery Address")) {
                    CustomTextField(placeholder: "Address", text: $viewModel.address, icon: "location")
                    CustomTextField(placeholder: "City", text: $viewModel.city, icon: "building.2")
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section { Text(viewModel.errorMessage).foregroundColor(.red) }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.submitOrder { presentationMode.wrappedValue.dismiss() } }) {
                        if viewModel.isSubmitting { ProgressView() } else { Text("Submit").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .onAppear { viewModel.loadUserInfo() }
        }
    }
}
