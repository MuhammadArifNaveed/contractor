//
//  PromotionModels.swift
//  TheContractor
//

import Foundation

struct Promotion: Codable, Identifiable {
    let id: String
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let discountType: String
    let discountValue: String
    let bannerImage: String?
    let startDate: String
    let endDate: String
    let termsConditions: String?
    let isActive: Bool
    let viewsCount: Int
    let claimsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case companyId = "company_id"
        case titleArabic = "title_arabic"
        case descriptionArabic = "description_arabic"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case bannerImage = "banner_image"
        case startDate = "start_date"
        case endDate = "end_date"
        case termsConditions = "terms_conditions"
        case isActive = "is_active"
        case viewsCount = "views_count"
        case claimsCount = "claims_count"
    }
}

struct PromotionClaim: Codable, Identifiable {
    let id: String
    let userId: String
    let promotionId: String
    let couponCode: String
    let claimedAt: String
    let usedAt: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case userId = "user_id"
        case promotionId = "promotion_id"
        case couponCode = "coupon_code"
        case claimedAt = "claimed_at"
        case usedAt = "used_at"
    }
}

struct PromotionCreation {
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let discountType: String
    let discountValue: String
    let startDate: String
    let endDate: String
    let termsConditions: String?
}
