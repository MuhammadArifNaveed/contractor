//  VendorEnquiryDetailView.swift
import SwiftUI
struct VendorEnquiryDetailView: View {
    let enquiry: VendorEnquiry
    @StateObject private var viewModel = VendorEnquiryDetailViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enquiry #\(enquiry.id)").font(AppTheme.Fonts.bold(20))
                Divider()
                DetailRow(label: "User", value: enquiry.userName)
                DetailRow(label: "Date", value: enquiry.date)
                DetailRow(label: "Status", value: enquiry.status)
                if !viewModel.responseText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Response").font(AppTheme.Fonts.semibold(16))
                        Text(viewModel.responseText).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response").font(AppTheme.Fonts.semibold(16))
                        TextEditor(text: $viewModel.responseText).frame(height: 100).border(Color.gray.opacity(0.2))
                        PrimaryButton(title: "Submit Response") { viewModel.submitResponse(enquiryId: enquiry.id) }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Enquiry Details")
    }
}
class VendorEnquiryDetailViewModel: ObservableObject {
    @Published var responseText = ""
    func submitResponse(enquiryId: String) {
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/respond_enquiry", params: ["enquiry_id": enquiryId, "response": responseText]) { _, _, _, _ in }
    }
}
