//  VendorEnquiriesView.swift
import SwiftUI
struct VendorEnquiriesView: View {
    @StateObject private var viewModel = VendorEnquiriesViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.enquiries.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.enquiries.isEmpty { EmptyStateView(icon: "envelope", title: "No Enquiries", message: "No enquiries received yet") }
            else {
                List(viewModel.enquiries.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text("Enquiry #\(viewModel.enquiries[i].id)").font(AppTheme.Fonts.semibold(16)); Spacer(); Text(viewModel.enquiries[i].status).font(AppTheme.Fonts.medium(12)).foregroundColor(.blue) }
                        Text(viewModel.enquiries[i].userName).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        Text(viewModel.enquiries[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Enquiries")
        .onAppear { viewModel.loadEnquiries() }
    }
}
class VendorEnquiriesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var enquiries: [VendorEnquiry] = []
    func loadEnquiries() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_enquiries", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["enquiries"].array {
                    self?.enquiries = arr.map { VendorEnquiry(id: $0["id"].stringValue, userName: $0["user_name"].stringValue, status: $0["status"].stringValue, date: $0["date"].stringValue) }
                }
            }
        }
    }
}
struct VendorEnquiry: Identifiable { let id, userName, status, date: String }
