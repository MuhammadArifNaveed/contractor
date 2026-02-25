//
//  BookmarkModels.swift
//  TheContractor
//

import Foundation

struct BookmarkedCompany: Codable, Identifiable {
    let id: String
    let companyId: String
    let companyName: String
    let companyNameArabic: String
    let companyLogo: String?
    let categoryName: String
    let avgRating: String
    let reviewCount: String
    let isVerified: String
    let location: String
    let bookmarkedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, location
        case companyId = "company_id"
        case companyName = "company_name"
        case companyNameArabic = "company_name_arabic"
        case companyLogo = "company_logo"
        case categoryName = "category_name"
        case avgRating = "avg_rating"
        case reviewCount = "review_count"
        case isVerified = "is_verified"
        case bookmarkedAt = "bookmarked_at"
    }
}

struct BookmarkedWorkshop: Codable, Identifiable {
    let id: String
    let workshopId: String
    let title: String
    let titleArabic: String
    let price: String
    let date: String
    let location: String
    let enrolledCount: String
    let capacity: String
    let bookmarkedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, date, location, capacity
        case workshopId = "workshop_id"
        case titleArabic = "title_arabic"
        case enrolledCount = "enrolled_count"
        case bookmarkedAt = "bookmarked_at"
    }
}

struct BookmarkedFreelancer: Codable, Identifiable {
    let id: String
    let freelancerId: String
    let name: String
    let profileImage: String?
    let skills: String
    let hourlyRate: String
    let avgRating: String
    let completedJobs: String
    let bookmarkedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, skills
        case freelancerId = "freelancer_id"
        case profileImage = "profile_image"
        case hourlyRate = "hourly_rate"
        case avgRating = "avg_rating"
        case completedJobs = "completed_jobs"
        case bookmarkedAt = "bookmarked_at"
    }
}
