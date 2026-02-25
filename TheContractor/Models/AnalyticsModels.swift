//
//  AnalyticsModels.swift
//  TheContractor
//

import Foundation

struct UserAnalytics: Codable {
    let totalSearches: Int
    let totalEnquiries: Int
    let totalQuotations: Int
    let totalWorkshopsAttended: Int
    let totalReviewsGiven: Int
    let favoriteCategories: [String]
    let recentActivities: [ActivityLog]
    
    enum CodingKeys: String, CodingKey {
        case favoriteCategories = "favorite_categories"
        case recentActivities = "recent_activities"
        case totalSearches = "total_searches"
        case totalEnquiries = "total_enquiries"
        case totalQuotations = "total_quotations"
        case totalWorkshopsAttended = "total_workshops_attended"
        case totalReviewsGiven = "total_reviews_given"
    }
}

struct ActivityLog: Codable, Identifiable {
    let id: String
    let activityType: String
    let description: String
    let timestamp: String
    let relatedId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, timestamp
        case activityType = "activity_type"
        case relatedId = "related_id"
    }
}

struct CompanyAnalytics: Codable {
    let totalViews: Int
    let totalEnquiries: Int
    let totalQuotations: Int
    let conversionRate: Double
    let avgResponseTime: String
    let popularServices: [String]
    
    enum CodingKeys: String, CodingKey {
        case popularServices = "popular_services"
        case totalViews = "total_views"
        case totalEnquiries = "total_enquiries"
        case totalQuotations = "total_quotations"
        case conversionRate = "conversion_rate"
        case avgResponseTime = "avg_response_time"
    }
}
