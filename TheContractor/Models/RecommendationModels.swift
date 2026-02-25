//
//  RecommendationModels.swift
//  TheContractor
//

import Foundation

struct RecommendedCompany: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyNameArabic: String
    let companyLogo: String?
    let categoryName: String
    let avgRating: String
    let reviewCount: String
    let isVerified: String
    let matchScore: Double
    let recommendationReason: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyNameArabic = "company_name_arabic"
        case companyLogo = "company_logo"
        case categoryName = "category_name"
        case avgRating = "avg_rating"
        case reviewCount = "review_count"
        case isVerified = "is_verified"
        case matchScore = "match_score"
        case recommendationReason = "recommendation_reason"
    }
}

struct RecommendedWorkshop: Codable, Identifiable {
    let id: String
    let title: String
    let titleArabic: String
    let categoryName: String
    let price: String
    let date: String
    let location: String
    let matchScore: Double
    let recommendationReason: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, date, location
        case titleArabic = "title_arabic"
        case categoryName = "category_name"
        case matchScore = "match_score"
        case recommendationReason = "recommendation_reason"
    }
}

struct RecommendedFreelancer: Codable, Identifiable {
    let id: String
    let name: String
    let profileImage: String?
    let skills: String
    let hourlyRate: String
    let avgRating: String
    let completedJobs: String
    let matchScore: Double
    let recommendationReason: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, skills
        case profileImage = "profile_image"
        case hourlyRate = "hourly_rate"
        case avgRating = "avg_rating"
        case completedJobs = "completed_jobs"
        case matchScore = "match_score"
        case recommendationReason = "recommendation_reason"
    }
}
