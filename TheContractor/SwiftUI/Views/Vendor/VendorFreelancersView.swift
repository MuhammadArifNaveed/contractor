//  VendorFreelancersView.swift
import SwiftUI
struct VendorFreelancersView: View {
    @StateObject private var viewModel = VendorFreelancersViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.freelancers.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.freelancers.isEmpty { EmptyStateView(icon: "person.2", title: "No Freelancers", message: "No freelancers available") }
            else {
                List(viewModel.freelancers.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Circle().fill(Color.blue.opacity(0.2)).frame(width: 50, height: 50).overlay(Image(systemName: "person.fill").foregroundColor(.blue))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.freelancers[i].name).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.freelancers[i].category).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        }
                        Spacer()
                        RatingView(rating: Double(viewModel.freelancers[i].rating) ?? 0, size: 14)
                    }
                }
            }
        }
        .navigationTitle("Freelancers")
        .onAppear { viewModel.loadFreelancers() }
    }
}
class VendorFreelancersViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var freelancers: [VendorFreelancer] = []
    func loadFreelancers() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_freelancers", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["freelancers"].array {
                    self?.freelancers = arr.map { VendorFreelancer(id: $0["id"].stringValue, name: $0["name"].stringValue, category: $0["category"].stringValue, rating: $0["rating"].stringValue) }
                }
            }
        }
    }
}
struct VendorFreelancer: Identifiable { let id, name, category, rating: String }
