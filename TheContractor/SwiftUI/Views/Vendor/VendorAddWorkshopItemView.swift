//  VendorAddWorkshopItemView.swift
import SwiftUI
struct VendorAddWorkshopItemView: View {
    @StateObject private var viewModel = VendorAddWorkshopItemViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    CustomTextField(placeholder: "Title", text: $viewModel.title, icon: "wrench")
                    CustomTextField(placeholder: "Price", text: $viewModel.price, icon: "dollarsign.circle")
                }
                Section(header: Text("Description")) { TextEditor(text: $viewModel.description).frame(height: 100) }
                if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            }
            .navigationTitle("Add Workshop Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.addItem { presentationMode.wrappedValue.dismiss() } }) {
                        if viewModel.isSubmitting { ProgressView() } else { Text("Add").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
        }
    }
}
class VendorAddWorkshopItemViewModel: ObservableObject {
    @Published var title = ""
    @Published var price = ""
    @Published var description = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !title.isEmpty && !price.isEmpty }
    func addItem(completion: @escaping () -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/add_workshop_item", params: ["title": title, "price": price, "description": description]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
