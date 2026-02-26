//  VendorCustomersView.swift
import SwiftUI
struct VendorCustomersView: View {
    @StateObject private var viewModel = VendorCustomersViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.customers.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.customers.isEmpty { EmptyStateView(icon: "person.3", title: "No Customers", message: "No customer records") }
            else {
                List(viewModel.customers.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Circle().fill(Color.blue.opacity(0.2)).frame(width: 50, height: 50).overlay(Image(systemName: "person.fill").foregroundColor(.blue))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.customers[i].name).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.customers[i].phone).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                            Text("\(viewModel.customers[i].totalOrders) orders").font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { viewModel.viewCustomer(viewModel.customers[i]) }) {
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Customers")
        .onAppear { viewModel.loadCustomers() }
    }
}
class VendorCustomersViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var customers: [VendorCustomer] = []
    func loadCustomers() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_customers", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["customers"].array {
                    self?.customers = arr.map { VendorCustomer(id: $0["id"].stringValue, name: $0["name"].stringValue, phone: $0["phone"].stringValue, totalOrders: $0["total_orders"].stringValue) }
                }
            }
        }
    }
    func viewCustomer(_ customer: VendorCustomer) { print("View: \(customer.name)") }
}
struct VendorCustomer: Identifiable { let id, name, phone, totalOrders: String }
