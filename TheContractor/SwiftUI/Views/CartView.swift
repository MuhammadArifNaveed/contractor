//
//  CartView.swift
//  TheContractor
//
//  Shopping cart screen
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var showCheckout = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView(message: "Loading cart...")
            } else if viewModel.cartItems.isEmpty {
                EmptyStateView(icon: "cart", title: "Empty Cart", message: "Your cart is empty. Add items to get started.")
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.small) {
                            ForEach(viewModel.cartItems.indices, id: \.self) { index in
                                CartItemCard(item: viewModel.cartItems[index], onRemove: {
                                    viewModel.removeItem(at: index)
                                }, onQuantityChange: { newQty in
                                    viewModel.updateQuantity(at: index, quantity: newQty)
                                })
                                .padding(.horizontal, AppTheme.Spacing.medium)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.medium)
                    }
                    
                    // Cart Summary
                    VStack(spacing: AppTheme.Spacing.small) {
                        Divider()
                        
                        HStack {
                            Text("Total Items:")
                                .font(AppTheme.Fonts.regular(14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Spacer()
                            Text("\(viewModel.totalItems)")
                                .font(AppTheme.Fonts.semibold(16))
                        }
                        
                        HStack {
                            Text("Total Price:")
                                .font(AppTheme.Fonts.semibold(16))
                            Spacer()
                            Text(viewModel.totalPrice)
                                .font(AppTheme.Fonts.bold(20))
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        
                        PrimaryButton(title: "Proceed to Checkout") {
                            showCheckout = true
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                    .background(Color.white)
                }
            }
        }
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCheckout) {
            CheckoutView()
        }
        .onAppear {
            viewModel.loadCart()
        }
    }
}

struct CartItemCard: View {
    let item: CartItemModel
    let onRemove: () -> Void
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            AsyncImage(url: URL(string: item.image)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(AppTheme.CornerRadius.small)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(AppTheme.Fonts.semibold(16))
                    .lineLimit(2)
                
                Text(item.price)
                    .font(AppTheme.Fonts.bold(16))
                    .foregroundColor(AppTheme.Colors.primary)
                
                HStack(spacing: 12) {
                    Button(action: { onQuantityChange(max(1, item.quantity - 1)) }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(AppTheme.Colors.gray)
                    }
                    
                    Text("\(item.quantity)")
                        .font(AppTheme.Fonts.semibold(14))
                        .frame(width: 30)
                    
                    Button(action: { onQuantityChange(item.quantity + 1) }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

struct CartItemModel: Identifiable {
    let id: String
    let name: String
    let price: String
    let image: String
    var quantity: Int
    
    init(id: String = "", name: String = "", price: String = "", image: String = "", quantity: Int = 1) {
        self.id = id; self.name = name; self.price = price; self.image = image; self.quantity = quantity
    }
}
