//
//  SocialModels.swift
//  TheContractor
//

import Foundation

struct SocialPost: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userImage: String?
    let content: String
    let images: [String]?
    let likesCount: Int
    let commentsCount: Int
    let isLiked: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, content, images
        case userId = "user_id"
        case userName = "user_name"
        case userImage = "user_image"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isLiked = "is_liked"
        case createdAt = "created_at"
    }
}

struct Comment: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let userImage: String?
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case userId = "user_id"
        case userName = "user_name"
        case userImage = "user_image"
        case createdAt = "created_at"
    }
}

struct ShareContent {
    let contentType: String
    let contentId: String
    let platform: String
    let message: String?
}
