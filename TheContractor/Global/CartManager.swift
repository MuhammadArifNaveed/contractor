//
//  CartManager.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import Combine

/// Manages the shopping cart for company enquiries
class CartManager: ObservableObject {
    
    static let shared = CartManager()
    
    // MARK: - Published Properties
    
    @Published var items: [CartItem] = []
    @Published var cartLimit: Int = 0
    @Published var availableCartLimit: Int = 0
    
    // MARK: - Constants
    
    private let cartItemsKey = "CartItems"
    private let cartLimitKey = "CartLimit"
    private let availableCartLimitKey = "AvailableCartLimit"
    
    // MARK: - Computed Properties
    
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var isOverLimit: Bool {
        return count > availableCartLimit
    }
    
    var itemsToRemove: Int {
        return max(0, count - availableCartLimit)
    }
    
    // MARK: - Initialization
    
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Cart Operations
    
    /// Add a company to the cart
    /// - Parameter item: The cart item to add
    /// - Returns: True if added successfully, false if already exists
    @discardableResult
    func addItem(_ item: CartItem) -> Bool {
        // Check if item already exists
        if items.contains(where: { $0.id == item.id }) {
            return false
        }
        
        items.append(item)
        saveToUserDefaults()
        
        // Post notification for cart update
        NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
        
        return true
    }
    
    /// Remove a company from the cart
    /// - Parameter itemId: The ID of the item to remove
    @discardableResult
    func removeItem(withId itemId: String) -> Bool {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            items.remove(at: index)
            saveToUserDefaults()
            
            // Post notification for cart update
            NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
            
            return true
        }
        return false
    }
    
    /// Check if a company is in the cart
    /// - Parameter itemId: The ID of the item to check
    /// - Returns: True if the item is in the cart
    func containsItem(withId itemId: String) -> Bool {
        return items.contains(where: { $0.id == itemId })
    }
    
    /// Clear all items from the cart
    func clearCart() {
        items.removeAll()
        saveToUserDefaults()
        
        // Post notification for cart update
        NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
    }
    
    /// Update cart limits from API response
    /// - Parameters:
    ///   - cartLimit: Total cart limit
    ///   - availableLimit: Available cart limit for current user
    func updateLimits(cartLimit: Int, availableLimit: Int) {
        self.cartLimit = cartLimit
        self.availableCartLimit = availableLimit
        
        // Save limits to UserDefaults
        UserDefaults.standard.set(cartLimit, forKey: cartLimitKey)
        UserDefaults.standard.set(availableLimit, forKey: availableCartLimitKey)
    }
    
    // MARK: - Persistence
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: cartItemsKey)
        }
    }
    
    private func loadFromUserDefaults() {
        // Load cart items
        if let data = UserDefaults.standard.data(forKey: cartItemsKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
        
        // Load cart limits
        cartLimit = UserDefaults.standard.integer(forKey: cartLimitKey)
        availableCartLimit = UserDefaults.standard.integer(forKey: availableCartLimitKey)
    }
    
    /// Get item at specific index
    /// - Parameter index: The index of the item
    /// - Returns: The cart item at the index, or nil if out of bounds
    func item(at index: Int) -> CartItem? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
    
    /// Update location for a cart item
    /// - Parameters:
    ///   - itemId: The ID of the item to update
    ///   - location: Location description
    ///   - lat: Latitude
    ///   - lng: Longitude
    func updateLocation(forItemId itemId: String, location: String, lat: String, lng: String) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = items[index]
            updatedItem.location = location
            updatedItem.lat = lat
            updatedItem.lng = lng
            items[index] = updatedItem
            saveToUserDefaults()
            
            // Post notification for cart update
            NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
        }
    }
    
    /// Update description for a cart item
    /// - Parameters:
    ///   - itemId: The ID of the item to update
    ///   - description: Description text
    func updateDescription(forItemId itemId: String, description: String) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = items[index]
            updatedItem.description = description
            items[index] = updatedItem
            saveToUserDefaults()
            
            // Post notification for cart update
            NotificationCenter.default.post(name: NSNotification.Name("CartUpdated"), object: nil)
        }
    }
}
