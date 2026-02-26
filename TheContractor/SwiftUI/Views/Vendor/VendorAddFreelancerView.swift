//  VendorAddFreelancerView.swift
import SwiftUI
struct VendorAddFreelancerView: View {
    @StateObject private var viewModel = VendorAddFreelancerViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Freelancer Info")) {
                    CustomTextField(placeholder: "Name", text: $viewModel.name, icon: "person")
                    CustomTextField(placeholder: "Category", text: $viewModel.category, icon: "briefcase")
                    CustomTextField(placeholder: "Rate", text: $viewModel.rate, icon: "dollarsign.circle")
                }
                if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            }
            .navigationTitle("Add Freelancer")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.addFreelancer { presentationMode.wrappedValue.dismiss() } }) {
                        if viewModel.isSubmitting { ProgressView() } else { Text("Add").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
        }
    }
}
class VendorAddFreelancerViewModel: ObservableObject {
    @Published var name = ""
    @Published var category = ""
    @Published var rate = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !name.isEmpty && !category.isEmpty }
    func addFreelancer(completion: @escaping () -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/add_freelancer", params: ["name": name, "category": category, "rate": rate]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
