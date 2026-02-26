//  VendorServicesView.swift
import SwiftUI
struct VendorServicesView: View {
    @StateObject private var viewModel = VendorServicesViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.services.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.services.isEmpty { EmptyStateView(icon: "wrench.and.screwdriver", title: "No Services", message: "No services added yet") }
            else {
                List(viewModel.services.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text(viewModel.services[i].name).font(AppTheme.Fonts.semibold(16)); Spacer(); Text(viewModel.services[i].price).font(AppTheme.Fonts.bold(14)).foregroundColor(AppTheme.Colors.primary) }
                        Text(viewModel.services[i].description).font(AppTheme.Fonts.regular(13)).foregroundColor(.gray).lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Services")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.addService() }) { Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary) }
            }
        }
        .onAppear { viewModel.loadServices() }
    }
}
class VendorServicesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var services: [VendorService] = []
    func loadServices() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_services", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["services"].array {
                    self?.services = arr.map { VendorService(id: $0["id"].stringValue, name: $0["name"].stringValue, description: $0["description"].stringValue, price: $0["price"].stringValue) }
                }
            }
        }
    }
    func addService() { print("Add service") }
}
struct VendorService: Identifiable { let id, name, description, price: String }
