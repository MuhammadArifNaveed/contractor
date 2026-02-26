//  VendorWorkshopView.swift
import SwiftUI
struct VendorWorkshopView: View {
    @StateObject private var viewModel = VendorWorkshopViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.items.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.items.isEmpty { EmptyStateView(icon: "wrench", title: "No Items", message: "No workshop items") }
            else {
                List(viewModel.items.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: viewModel.items[i].image)) { img in img.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                            .frame(width: 60, height: 60).cornerRadius(8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.items[i].title).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.items[i].price).font(AppTheme.Fonts.bold(14)).foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Workshop Items")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.addItem() }) { Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary) }
            }
        }
        .onAppear { viewModel.loadItems() }
    }
}
class VendorWorkshopViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var items: [WorkshopItem] = []
    func loadItems() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_workshop_items", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["items"].array {
                    self?.items = arr.map { WorkshopItem(id: $0["id"].stringValue, title: $0["title"].stringValue, price: $0["price"].stringValue, image: $0["image"].stringValue) }
                }
            }
        }
    }
    func addItem() { print("Add item") }
}
