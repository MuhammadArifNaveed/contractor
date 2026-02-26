//  VendorPaymentsView.swift
import SwiftUI
struct VendorPaymentsView: View {
    @StateObject private var viewModel = VendorPaymentsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.payments.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.payments.isEmpty { EmptyStateView(icon: "dollarsign.circle", title: "No Payments", message: "No payment history") }
            else {
                List(viewModel.payments.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.payments[i].description).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.payments[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                        }
                        Spacer()
                        Text(viewModel.payments[i].amount).font(AppTheme.Fonts.bold(16)).foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .navigationTitle("Payments")
        .onAppear { viewModel.loadPayments() }
    }
}
class VendorPaymentsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var payments: [VendorPayment] = []
    func loadPayments() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_payments", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["payments"].array {
                    self?.payments = arr.map { VendorPayment(id: $0["id"].stringValue, description: $0["description"].stringValue, amount: $0["amount"].stringValue, date: $0["date"].stringValue) }
                }
            }
        }
    }
}
struct VendorPayment: Identifiable { let id, description, amount, date: String }
