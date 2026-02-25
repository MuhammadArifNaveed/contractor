//
//  SubscriptionModels.swift
//  TheContractor
//

import Foundation

struct SubscriptionPlan: Codable, Identifiable {
    let id: String
    let name: String
    let nameArabic: String
    let description: String
    let descriptionArabic: String
    let planType: String
    let price: String
    let billingCycle: String
    let features: [String]
    let maxEnquiries: String
    let maxQuotations: String
    let priority: String
    let isPopular: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, features, priority
        case nameArabic = "name_arabic"
        case descriptionArabic = "description_arabic"
        case planType = "plan_type"
        case billingCycle = "billing_cycle"
        case maxEnquiries = "max_enquiries"
        case maxQuotations = "max_quotations"
        case isPopular = "is_popular"
    }
}

struct UserSubscription: Codable, Identifiable {
    let id: String
    let userId: String
    let planId: String
    let planName: String
    let status: String
    let startDate: String
    let endDate: String
    let autoRenew: Bool
    let paymentMethod: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case id, status, amount
        case userId = "user_id"
        case planId = "plan_id"
        case planName = "plan_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case autoRenew = "auto_renew"
        case paymentMethod = "payment_method"
    }
}

struct SubscriptionUsage: Codable {
    let enquiriesUsed: Int
    let enquiriesLimit: Int
    let quotationsUsed: Int
    let quotationsLimit: Int
    let resetDate: String
    
    enum CodingKeys: String, CodingKey {
        case resetDate = "reset_date"
        case enquiriesUsed = "enquiries_used"
        case enquiriesLimit = "enquiries_limit"
        case quotationsUsed = "quotations_used"
        case quotationsLimit = "quotations_limit"
    }
}
