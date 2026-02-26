//  VendorQuotationsView.swift
import SwiftUI
struct VendorQuotationsView: View {
    @StateObject private var viewModel = VendorQuotationsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.quotations.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.quotations.isEmpty { EmptyStateView(icon: "doc.text", title: "No Quotations", message: "No quotation requests yet") }
            else {
                List(viewModel.quotations.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text("Request #\(viewModel.quotations[i].id)").font(AppTheme.Fonts.semibold(16)); Spacer(); Text(viewModel.quotations[i].status).font(AppTheme.Fonts.medium(12)).foregroundColor(.green) }
                        Text(viewModel.quotations[i].userName).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        Text(viewModel.quotations[i].description).font(AppTheme.Fonts.regular(13)).foregroundColor(.gray).lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Quotations")
        .onAppear { viewModel.loadQuotations() }
    }
}
class VendorQuotationsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var quotations: [VendorQuotation] = []
    func loadQuotations() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_quotations", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["quotations"].array {
                    self?.quotations = arr.map { VendorQuotation(id: $0["id"].stringValue, userName: $0["user_name"].stringValue, description: $0["description"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
struct VendorQuotation: Identifiable { let id, userName, description, status: String }
