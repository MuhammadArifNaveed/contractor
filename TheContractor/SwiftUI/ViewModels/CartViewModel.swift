//
//  CartViewModel.swift
//  TheContractor
//

import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var cartItems: [CartItemModel] = []
    
    var totalItems: Int { cartItems.reduce(0) { $0 + $1.quantity } }
    var totalPrice: String {
        let total = cartItems.reduce(0.0) { sum, item in
            let price = Double(item.price.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)) ?? 0
            return sum + (price * Double(item.quantity))
        }
        return String(format: "$%.2f", total)
    }
    
    func loadCart() {
        isLoading = true
        guard let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_cart", params: ["user_id": userId]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let items = json?["items"].array {
                    self?.cartItems = items.map { CartItemModel(id: $0["id"].stringValue, name: $0["name"].stringValue, price: $0["price"].stringValue, image: $0["image"].stringValue, quantity: $0["quantity"].intValue) }
                }
            }
        }
    }
    
    func removeItem(at index: Int) {
        cartItems.remove(at: index)
    }
    
    func updateQuantity(at index: Int, quantity: Int) {
        cartItems[index].quantity = quantity
    }
}
