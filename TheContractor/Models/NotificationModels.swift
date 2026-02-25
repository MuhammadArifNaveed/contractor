//
//  NotificationModels.swift
//  TheContractor
//

import Foundation

struct NotificationItem: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let type: String
    let isRead: Bool
    let relatedId: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, type
        case isRead = "is_read"
        case relatedId = "related_id"
        case createdAt = "created_at"
    }
}

struct NotificationSettings: Codable {
    var enquiryNotifications: Bool
    var quotationNotifications: Bool
    var workshopNotifications: Bool
    var promotionalNotifications: Bool
    var pushEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case enquiryNotifications = "enquiry_notifications"
        case quotationNotifications = "quotation_notifications"
        case workshopNotifications = "workshop_notifications"
        case promotionalNotifications = "promotional_notifications"
        case pushEnabled = "push_enabled"
    }
}
