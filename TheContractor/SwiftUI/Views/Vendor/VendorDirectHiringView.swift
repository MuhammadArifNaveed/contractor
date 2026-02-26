//  VendorDirectHiringView.swift
import SwiftUI
struct VendorDirectHiringView: View {
    @StateObject private var viewModel = VendorDirectHiringViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.hirings.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.hirings.isEmpty { EmptyStateView(icon: "person.2", title: "No Hiring Requests", message: "No direct hiring requests") }
            else {
                List(viewModel.hirings.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.hirings[i].title).font(AppTheme.Fonts.semibold(16))
                        Text(viewModel.hirings[i].user).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        HStack { Text(viewModel.hirings[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray); Spacer(); Text(viewModel.hirings[i].status).font(AppTheme.Fonts.medium(12)).foregroundColor(.blue) }
                    }
                }
            }
        }
        .navigationTitle("Direct Hiring")
        .onAppear { viewModel.loadHirings() }
    }
}
class VendorDirectHiringViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var hirings: [DirectHiring] = []
    func loadHirings() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_direct_hiring", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["hirings"].array {
                    self?.hirings = arr.map { DirectHiring(id: $0["id"].stringValue, title: $0["title"].stringValue, user: $0["user"].stringValue, date: $0["date"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
struct DirectHiring: Identifiable { let id, title, user, date, status: String }
