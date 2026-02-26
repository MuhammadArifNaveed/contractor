//  VendorPromotionsView.swift
import SwiftUI
struct VendorPromotionsView: View {
    @StateObject private var viewModel = VendorPromotionsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.promotions.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.promotions.isEmpty { EmptyStateView(icon: "megaphone", title: "No Promotions", message: "No active promotions") }
            else {
                List(viewModel.promotions.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack { Text(viewModel.promotions[i].title).font(AppTheme.Fonts.semibold(16)); Spacer(); Text(viewModel.promotions[i].discount).font(AppTheme.Fonts.bold(14)).foregroundColor(.green) }
                        Text(viewModel.promotions[i].description).font(AppTheme.Fonts.regular(13)).foregroundColor(.gray).lineLimit(2)
                        Text("Valid until: \(viewModel.promotions[i].expiryDate)").font(AppTheme.Fonts.regular(12)).foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Promotions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.createPromotion() }) { Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary) }
            }
        }
        .onAppear { viewModel.loadPromotions() }
    }
}
class VendorPromotionsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var promotions: [VendorPromotion] = []
    func loadPromotions() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_promotions", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["promotions"].array {
                    self?.promotions = arr.map { VendorPromotion(id: $0["id"].stringValue, title: $0["title"].stringValue, description: $0["description"].stringValue, discount: $0["discount"].stringValue, expiryDate: $0["expiry_date"].stringValue) }
                }
            }
        }
    }
    func createPromotion() { print("Create promotion") }
}
struct VendorPromotion: Identifiable { let id, title, description, discount, expiryDate: String }
