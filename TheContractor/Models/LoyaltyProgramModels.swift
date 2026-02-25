//
//  LoyaltyProgramModels.swift
//  TheContractor
//

import Foundation

struct LoyaltyProgram: Codable {
    let programName: String
    let programNameArabic: String
    let pointsPerEnquiry: Int
    let pointsPerQuotation: Int
    let pointsPerReview: Int
    let pointsPerReferral: Int
    let pointsValue: String
    let termsConditions: String
    
    enum CodingKeys: String, CodingKey {
        case termsConditions = "terms_conditions"
        case programName = "program_name"
        case programNameArabic = "program_name_arabic"
        case pointsPerEnquiry = "points_per_enquiry"
        case pointsPerQuotation = "points_per_quotation"
        case pointsPerReview = "points_per_review"
        case pointsPerReferral = "points_per_referral"
        case pointsValue = "points_value"
    }
}

struct UserLoyaltyAccount: Codable {
    let userId: String
    let totalPoints: Int
    let availablePoints: Int
    let usedPoints: Int
    let tier: String
    let nextTier: String?
    let pointsToNextTier: Int?
    let memberSince: String
    
    enum CodingKeys: String, CodingKey {
        case tier
        case userId = "user_id"
        case totalPoints = "total_points"
        case availablePoints = "available_points"
        case usedPoints = "used_points"
        case nextTier = "next_tier"
        case pointsToNextTier = "points_to_next_tier"
        case memberSince = "member_since"
    }
}

struct LoyaltyTransaction: Codable, Identifiable {
    let id: String
    let userId: String
    let transactionType: String
    let points: Int
    let description: String
    let relatedId: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, points, description
        case userId = "user_id"
        case transactionType = "transaction_type"
        case relatedId = "related_id"
        case createdAt = "created_at"
    }
}

struct LoyaltyReward: Codable, Identifiable {
    let id: String
    let rewardName: String
    let rewardNameArabic: String
    let description: String
    let pointsCost: Int
    let imageUrl: String?
    let isAvailable: Bool
    let validUntil: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case rewardName = "reward_name"
        case rewardNameArabic = "reward_name_arabic"
        case pointsCost = "points_cost"
        case imageUrl = "image_url"
        case isAvailable = "is_available"
        case validUntil = "valid_until"
    }
}
