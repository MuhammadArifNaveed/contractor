//
//  BarcodeScannerModels.swift
//  TheContractor
//

import Foundation

struct BarcodeProduct: Codable, Identifiable {
    let id: String
    let barcode: String
    let productName: String
    let productNameArabic: String
    let categoryId: String
    let manufacturer: String
    let price: String
    let description: String
    let descriptionArabic: String
    let imageUrl: String?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, barcode, manufacturer, price, description
        case productName = "product_name"
        case productNameArabic = "product_name_arabic"
        case categoryId = "category_id"
        case descriptionArabic = "description_arabic"
        case imageUrl = "image_url"
        case isActive = "is_active"
    }
}

struct BarcodeScanResult: Codable {
    let barcode: String
    let barcodeType: String
    let product: BarcodeProduct?
    let alternativeProducts: [BarcodeProduct]?
    let found: Bool
    
    enum CodingKeys: String, CodingKey {
        case barcode, product, found
        case barcodeType = "barcode_type"
        case alternativeProducts = "alternative_products"
    }
}

struct MaterialOrder: Codable, Identifiable {
    let id: String
    let userId: String
    let companyId: String
    let barcode: String
    let productName: String
    let quantity: String
    let price: String
    let totalAmount: String
    let deliveryAddress: String
    let status: String
    let orderedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, barcode, quantity, price, status
        case userId = "user_id"
        case companyId = "company_id"
        case productName = "product_name"
        case totalAmount = "total_amount"
        case deliveryAddress = "delivery_address"
        case orderedAt = "ordered_at"
    }
}
