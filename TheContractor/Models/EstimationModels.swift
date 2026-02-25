//
//  EstimationModels.swift
//  TheContractor
//

import Foundation

struct EstimationCategory: Codable, Identifiable {
    let id: String
    let name: String
    let nameArabic: String
    let icon: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameArabic = "name_arabic"
        case icon
        case description
    }
}

struct EstimationItem: Codable, Identifiable {
    let id: String
    let categoryId: String
    let name: String
    let nameArabic: String
    let unit: String
    let pricePerUnit: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case name
        case nameArabic = "name_arabic"
        case unit
        case pricePerUnit = "price_per_unit"
        case description
    }
}

struct EstimationCalculation {
    let itemId: String
    let itemName: String
    let quantity: Double
    let pricePerUnit: Double
    let totalPrice: Double
}

struct EstimationSummary {
    let items: [EstimationCalculation]
    let subtotal: Double
    let tax: Double?
    let totalAmount: Double
}
