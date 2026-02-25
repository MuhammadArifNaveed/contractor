//
//  VendorRatingModels.swift
//  TheContractor
//

import Foundation

struct VendorRatingCriteria: Codable, Identifiable {
    let id: String
    let criteriaName: String
    let criteriaNameArabic: String
    let description: String
    let weight: Double
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id, description, weight
        case criteriaName = "criteria_name"
        case criteriaNameArabic = "criteria_name_arabic"
        case orderIndex = "order_index"
    }
}

struct DetailedVendorRating: Codable {
    let companyId: String
    let overallRating: Double
    let totalReviews: Int
    let criteriaRatings: [CriteriaRating]
    let ratingDistribution: [Int]
    let recentTrend: String
    
    enum CodingKeys: String, CodingKey {
        case overallRating, criteriaRatings, recentTrend
        case companyId = "company_id"
        case totalReviews = "total_reviews"
        case ratingDistribution = "rating_distribution"
    }
}

struct CriteriaRating: Codable, Identifiable {
    let id: String
    let criteriaName: String
    let rating: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case id, rating, count
        case criteriaName = "criteria_name"
    }
}

struct VendorBadge: Codable, Identifiable {
    let id: String
    let badgeName: String
    let badgeNameArabic: String
    let badgeIcon: String
    let description: String
    let criteriaToEarn: String
    let earnedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case badgeName = "badge_name"
        case badgeNameArabic = "badge_name_arabic"
        case badgeIcon = "badge_icon"
        case criteriaToEarn = "criteria_to_earn"
        case earnedAt = "earned_at"
    }
}
