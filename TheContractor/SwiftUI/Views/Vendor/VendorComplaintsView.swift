//  VendorComplaintsView.swift
import SwiftUI
struct VendorComplaintsView: View {
    @StateObject private var viewModel = VendorComplaintsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.complaints.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.complaints.isEmpty { EmptyStateView(icon: "exclamationmark.triangle", title: "No Complaints", message: "No complaints received") }
            else {
                List(viewModel.complaints.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text("Complaint #\(viewModel.complaints[i].id)").font(AppTheme.Fonts.semibold(16)); Spacer(); Text(viewModel.complaints[i].status).font(AppTheme.Fonts.medium(12)).foregroundColor(.orange) }
                        Text(viewModel.complaints[i].userName).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        Text(viewModel.complaints[i].description).font(AppTheme.Fonts.regular(13)).foregroundColor(.gray).lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Complaints")
        .onAppear { viewModel.loadComplaints() }
    }
}
class VendorComplaintsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var complaints: [VendorComplaint] = []
    func loadComplaints() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_complaints", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["complaints"].array {
                    self?.complaints = arr.map { VendorComplaint(id: $0["id"].stringValue, userName: $0["user_name"].stringValue, description: $0["description"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
struct VendorComplaint: Identifiable { let id, userName, description, status: String }
