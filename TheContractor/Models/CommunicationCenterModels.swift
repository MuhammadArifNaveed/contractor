//
//  CommunicationCenterModels.swift
//  TheContractor
//

import Foundation

struct Announcement: Codable, Identifiable {
    let id: String
    let title: String
    let titleArabic: String
    let message: String
    let messageArabic: String
    let targetAudience: String
    let priority: String
    let publishedBy: String
    let publishedAt: String
    let expiresAt: String?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, priority
        case titleArabic = "title_arabic"
        case messageArabic = "message_arabic"
        case targetAudience = "target_audience"
        case publishedBy = "published_by"
        case publishedAt = "published_at"
        case expiresAt = "expires_at"
        case isActive = "is_active"
    }
}

struct BulkMessage: Codable, Identifiable {
    let id: String
    let subject: String
    let message: String
    let recipients: [String]
    let sendMethod: String
    let scheduledFor: String?
    let sentAt: String?
    let status: String
    let totalRecipients: Int
    let successCount: Int
    let failureCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, subject, message, recipients, status
        case sendMethod = "send_method"
        case scheduledFor = "scheduled_for"
        case sentAt = "sent_at"
        case totalRecipients = "total_recipients"
        case successCount = "success_count"
        case failureCount = "failure_count"
    }
}

struct Newsletter: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let category: String
    let publishDate: String
    let author: String
    let viewsCount: Int
    let subscribersCount: Int
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, category, author
        case publishDate = "publish_date"
        case viewsCount = "views_count"
        case subscribersCount = "subscribers_count"
        case imageUrl = "image_url"
    }
}

struct EmailTemplate: Codable, Identifiable {
    let id: String
    let templateName: String
    let subject: String
    let body: String
    let category: String
    let variables: [String]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, subject, body, category, variables
        case templateName = "template_name"
        case isActive = "is_active"
    }
}

struct CommunicationLog: Codable, Identifiable {
    let id: String
    let recipientId: String
    let recipientName: String
    let messageType: String
    let subject: String
    let sentAt: String
    let deliveryStatus: String
    let openedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, subject
        case recipientId = "recipient_id"
        case recipientName = "recipient_name"
        case messageType = "message_type"
        case sentAt = "sent_at"
        case deliveryStatus = "delivery_status"
        case openedAt = "opened_at"
    }
}
