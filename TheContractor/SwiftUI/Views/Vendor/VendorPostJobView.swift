//  VendorPostJobView.swift
import SwiftUI
struct VendorPostJobView: View {
    @StateObject private var viewModel = VendorPostJobViewModel()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Job Details")) {
                    CustomTextField(placeholder: "Job Title", text: $viewModel.title, icon: "briefcase")
                    CustomTextField(placeholder: "Location", text: $viewModel.location, icon: "location")
                    CustomTextField(placeholder: "Salary", text: $viewModel.salary, icon: "dollarsign.circle")
                }
                Section(header: Text("Description")) { TextEditor(text: $viewModel.description).frame(height: 100) }
                if !viewModel.errorMessage.isEmpty { Section { Text(viewModel.errorMessage).foregroundColor(.red) } }
            }
            .navigationTitle("Post Job")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { presentationMode.wrappedValue.dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.postJob { presentationMode.wrappedValue.dismiss() } }) {
                        if viewModel.isSubmitting { ProgressView() } else { Text("Post").fontWeight(.semibold) }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
        }
    }
}
class VendorPostJobViewModel: ObservableObject {
    @Published var title = ""
    @Published var location = ""
    @Published var salary = ""
    @Published var description = ""
    @Published var errorMessage = ""
    @Published var isSubmitting = false
    var isFormValid: Bool { !title.isEmpty && !location.isEmpty }
    func postJob(completion: @escaping () -> Void) {
        guard isFormValid else { return }
        isSubmitting = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/post_job", params: ["title": title, "location": location, "salary": salary, "description": description]) { [weak self] msg, success, _, _ in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success { completion() } else { self?.errorMessage = msg ?? "Failed" }
            }
        }
    }
}
