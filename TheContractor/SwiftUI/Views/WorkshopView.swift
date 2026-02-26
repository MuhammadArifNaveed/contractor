//  WorkshopView.swift
import SwiftUI

struct WorkshopView: View {
    @StateObject private var viewModel = WorkshopViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.items.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.items.isEmpty { EmptyStateView(icon: "wrench.and.screwdriver", title: "No Workshop Items", message: "No items available") }
            else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.items.indices, id: \.self) { i in
                            WorkshopItemCard(item: viewModel.items[i]) { viewModel.selectItem(viewModel.items[i]) }
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("Workshop")
        .onAppear { viewModel.loadItems() }
    }
}

struct WorkshopItemCard: View {
    let item: WorkshopItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: item.image)) { img in img.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title).font(AppTheme.Fonts.semibold(16)).lineLimit(2)
                    Text(item.price).font(AppTheme.Fonts.bold(14)).foregroundColor(AppTheme.Colors.primary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkshopItem: Identifiable {
    let id, title, price, image: String
    init(id: String = "", title: String = "", price: String = "", image: String = "") {
        self.id = id; self.title = title; self.price = price; self.image = image
    }
}
