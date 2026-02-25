//
//  ReferralModels.swift
//  TheContractor
//

import Foundation

struct ReferralProgram: Codable {
    let referrerReward: String
    let refereeReward: String
    let rewardType: String
    let minPurchaseAmount: String?
    let expiryDays: String
    let termsConditions: String
    
    enum CodingKeys: String, CodingKey {
        case termsConditions = "terms_conditions"
        case referrerReward = "referrer_reward"
        case refereeReward = "referee_reward"
        case rewardType = "reward_type"
        case minPurchaseAmount = "min_purchase_amount"
        case expiryDays = "expiry_days"
    }
}

struct UserReferralCode: Codable {
    let userId: String
    let referralCode: String
    let totalReferrals: Int
    let successfulReferrals: Int
    let totalEarnings: String
    let shareUrl: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case referralCode = "referral_code"
        case totalReferrals = "total_referrals"
        case successfulReferrals = "successful_referrals"
        case totalEarnings = "total_earnings"
        case shareUrl = "share_url"
    }
}

struct ReferralTransaction: Codable, Identifiable {
    let id: String
    let referrerId: String
    let referredUserId: String
    let referredUserName: String
    let rewardAmount: String
    let rewardType: String
    let status: String
    let createdAt: String
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case referrerId = "referrer_id"
        case referredUserId = "referred_user_id"
        case referredUserName = "referred_user_name"
        case rewardAmount = "reward_amount"
        case rewardType = "reward_type"
        case createdAt = "created_at"
        case completedAt = "completed_at"
    }
}

struct ReferralLeaderboard: Codable, Identifiable {
    let id: String
    let userName: String
    let userImage: String?
    let totalReferrals: Int
    let totalEarnings: String
    let rank: Int
    
    enum CodingKeys: String, CodingKey {
        case id, rank
        case userName = "user_name"
        case userImage = "user_image"
        case totalReferrals = "total_referrals"
        case totalEarnings = "total_earnings"
    }
}
