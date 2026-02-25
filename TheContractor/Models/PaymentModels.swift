//
//  PaymentModels.swift
//  TheContractor
//

import Foundation

struct PaymentMethod: Codable, Identifiable {
    let id: String
    let name: String
    let nameArabic: String
    let type: String
    let isEnabled: Bool
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, icon
        case nameArabic = "name_arabic"
        case isEnabled = "is_enabled"
    }
}

struct PaymentTransaction: Codable, Identifiable {
    let id: String
    let userId: String
    let amount: String
    let currency: String
    let paymentMethod: String
    let transactionType: String
    let status: String
    let referenceNumber: String
    let description: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, description
        case userId = "user_id"
        case paymentMethod = "payment_method"
        case transactionType = "transaction_type"
        case referenceNumber = "reference_number"
        case createdAt = "created_at"
    }
}

struct PaymentRequest {
    let userId: String
    let amount: String
    let paymentMethodId: String
    let purpose: String
    let relatedId: String?
}
