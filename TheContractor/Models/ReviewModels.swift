//
//  ReviewModels.swift
//  TheContractor
//

import Foundation

struct ReviewItem: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userImage: String?
    let rating: Double
    let comment: String
    let createdAt: String
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, rating, comment, images
        case userId = "user_id"
        case userName = "user_name"
        case userImage = "user_image"
        case createdAt = "created_at"
    }
}

struct ReviewSubmission {
    let companyId: String
    let userId: String
    let rating: Double
    let comment: String
    let images: [Data]?
    
    var isValid: Bool {
        return !companyId.isEmpty &&
               !userId.isEmpty &&
               rating >= 1.0 && rating <= 5.0 &&
               !comment.isEmpty &&
               comment.count >= 10
    }
}

struct CompanyRatingStats: Codable {
    let totalReviews: Int
    let averageRating: Double
    let fiveStarCount: Int
    let fourStarCount: Int
    let threeStarCount: Int
    let twoStarCount: Int
    let oneStarCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalReviews = "total_reviews"
        case averageRating = "average_rating"
        case fiveStarCount = "five_star_count"
        case fourStarCount = "four_star_count"
        case threeStarCount = "three_star_count"
        case twoStarCount = "two_star_count"
        case oneStarCount = "one_star_count"
    }
}
