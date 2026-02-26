//  VendorCategoriesView.swift
import SwiftUI
struct VendorCategoriesView: View {
    @StateObject private var viewModel = VendorCategoriesViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.categories.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.categories.isEmpty { EmptyStateView(icon: "square.grid.2x2", title: "No Categories", message: "No categories available") }
            else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.categories.indices, id: \.self) { i in
                            Button(action: { viewModel.selectCategory(viewModel.categories[i]) }) {
                                VStack(spacing: 8) {
                                    Circle().fill(AppTheme.Colors.primary.opacity(0.2)).frame(height: 80).overlay(Image(systemName: "tag").font(.system(size: 32)).foregroundColor(AppTheme.Colors.primary))
                                    Text(viewModel.categories[i].name).font(AppTheme.Fonts.semibold(14)).lineLimit(2).multilineTextAlignment(.center)
                                }
                                .padding(12).background(Color.white).cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Manage Categories")
        .onAppear { viewModel.loadCategories() }
    }
}
class VendorCategoriesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var categories: [VendorCategory] = []
    func loadCategories() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_categories", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["categories"].array {
                    self?.categories = arr.map { VendorCategory(id: $0["id"].stringValue, name: $0["name"].stringValue) }
                }
            }
        }
    }
    func selectCategory(_ category: VendorCategory) { print("Selected: \(category.name)") }
}
struct VendorCategory: Identifiable { let id, name: String }
