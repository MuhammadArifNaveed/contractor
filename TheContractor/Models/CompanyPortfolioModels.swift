//
//  CompanyPortfolioModels.swift
//  TheContractor
//

import Foundation

struct PortfolioItem: Codable, Identifiable {
    let id: String
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let categoryId: String
    let images: [String]
    let location: String
    let completionDate: String
    let clientName: String?
    let projectCost: String?
    let likesCount: Int
    let viewsCount: Int
    let isLiked: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, images, location
        case companyId = "company_id"
        case title
        case titleArabic = "title_arabic"
        case descriptionArabic = "description_arabic"
        case categoryId = "category_id"
        case completionDate = "completion_date"
        case clientName = "client_name"
        case projectCost = "project_cost"
        case likesCount = "likes_count"
        case viewsCount = "views_count"
        case isLiked = "is_liked"
        case createdAt = "created_at"
    }
}

struct PortfolioCreation {
    let companyId: String
    let title: String
    let titleArabic: String
    let description: String
    let descriptionArabic: String
    let categoryId: String
    let location: String
    let completionDate: String
    let clientName: String?
    let projectCost: String?
}

struct CompanyGallery: Codable {
    let images: [GalleryImage]
    let videos: [GalleryVideo]
    
    enum CodingKeys: String, CodingKey {
        case images, videos
    }
}

struct GalleryImage: Codable, Identifiable {
    let id: String
    let url: String
    let caption: String?
    let uploadedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, url, caption
        case uploadedAt = "uploaded_at"
    }
}

struct GalleryVideo: Codable, Identifiable {
    let id: String
    let url: String
    let thumbnail: String
    let title: String
    let duration: String?
    let uploadedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, url, thumbnail, title, duration
        case uploadedAt = "uploaded_at"
    }
}
