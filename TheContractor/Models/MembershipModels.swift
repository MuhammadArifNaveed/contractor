//
//  MembershipModels.swift
//  TheContractor
//

import Foundation

struct MembershipPlan: Codable, Identifiable {
    let id: String
    let name: String
    let nameArabic: String
    let description: String
    let price: String
    let duration: String
    let features: [String]
    let isPopular: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, duration, features
        case nameArabic = "name_arabic"
        case isPopular = "is_popular"
    }
}

struct UserMembership: Codable, Identifiable {
    let id: String
    let planId: String
    let planName: String
    let startDate: String
    let endDate: String
    let status: String
    let autoRenew: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case planId = "plan_id"
        case planName = "plan_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case autoRenew = "auto_renew"
    }
}

struct MembershipPurchase {
    let userId: String
    let planId: String
    let paymentMethod: String
}
