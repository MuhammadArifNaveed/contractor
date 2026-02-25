//
//  VideoContentModels.swift
//  TheContractor
//

import Foundation

struct VideoContent: Codable, Identifiable {
    let id: String
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let videoUrl: String
    let thumbnailUrl: String
    let duration: String
    let categoryId: String
    let viewsCount: Int
    let likesCount: Int
    let isLiked: Bool
    let uploadedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, duration
        case companyId = "company_id"
        case titleArabic = "title_arabic"
        case descriptionArabic = "description_arabic"
        case videoUrl = "video_url"
        case thumbnailUrl = "thumbnail_url"
        case categoryId = "category_id"
        case viewsCount = "views_count"
        case likesCount = "likes_count"
        case isLiked = "is_liked"
        case uploadedAt = "uploaded_at"
    }
}

struct VideoUpload {
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let categoryId: String
}

struct VideoPlaybackStats: Codable {
    let videoId: String
    let totalViews: Int
    let avgWatchTime: String
    let completionRate: Double
    let likeRatio: Double
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case totalViews = "total_views"
        case avgWatchTime = "avg_watch_time"
        case completionRate = "completion_rate"
        case likeRatio = "like_ratio"
    }
}
