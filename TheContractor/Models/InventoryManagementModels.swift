//
//  InventoryManagementModels.swift
//  TheContractor
//

import Foundation

struct InventoryItem: Codable, Identifiable {
    let id: String
    let companyId: String
    let itemName: String
    let itemNameArabic: String
    let sku: String
    let category: String
    let quantity: Int
    let unit: String
    let reorderLevel: Int
    let unitPrice: String
    let totalValue: String
    let location: String
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, sku, category, quantity, unit, location
        case companyId = "company_id"
        case itemName = "item_name"
        case itemNameArabic = "item_name_arabic"
        case reorderLevel = "reorder_level"
        case unitPrice = "unit_price"
        case totalValue = "total_value"
        case lastUpdated = "last_updated"
    }
}

struct InventoryTransaction: Codable, Identifiable {
    let id: String
    let itemId: String
    let companyId: String
    let transactionType: String
    let quantity: Int
    let unitPrice: String
    let totalAmount: String
    let reference: String?
    let notes: String?
    let performedBy: String
    let transactionDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, reference, notes
        case itemId = "item_id"
        case companyId = "company_id"
        case transactionType = "transaction_type"
        case unitPrice = "unit_price"
        case totalAmount = "total_amount"
        case performedBy = "performed_by"
        case transactionDate = "transaction_date"
    }
}

struct StockAlert: Codable, Identifiable {
    let id: String
    let itemId: String
    let itemName: String
    let currentQuantity: Int
    let reorderLevel: Int
    let alertType: String
    let severity: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case itemName = "item_name"
        case currentQuantity = "current_quantity"
        case reorderLevel = "reorder_level"
        case alertType = "alert_type"
        case severity
        case createdAt = "created_at"
    }
}

struct PurchaseOrder: Codable, Identifiable {
    let id: String
    let companyId: String
    let supplierId: String
    let supplierName: String
    let orderNumber: String
    let orderDate: String
    let expectedDelivery: String
    let totalAmount: String
    let status: String
    let items: [OrderItem]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, items
        case companyId = "company_id"
        case supplierId = "supplier_id"
        case supplierName = "supplier_name"
        case orderNumber = "order_number"
        case orderDate = "order_date"
        case expectedDelivery = "expected_delivery"
        case totalAmount = "total_amount"
    }
}

struct OrderItem: Codable, Identifiable {
    let id: String
    let itemName: String
    let quantity: Int
    let unitPrice: String
    let totalPrice: String
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case itemName = "item_name"
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
    }
}
