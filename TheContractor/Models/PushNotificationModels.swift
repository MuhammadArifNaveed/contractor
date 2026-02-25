//
//  PushNotificationModels.swift
//  TheContractor
//

import Foundation

struct PushNotificationSettings: Codable {
    let userId: String
    let deviceToken: String
    let platform: String
    let enquiryNotifications: Bool
    let quotationNotifications: Bool
    let chatNotifications: Bool
    let promotionNotifications: Bool
    let workshopNotifications: Bool
    let orderNotifications: Bool
    
    enum CodingKeys: String, CodingKey {
        case platform
        case userId = "user_id"
        case deviceToken = "device_token"
        case enquiryNotifications = "enquiry_notifications"
        case quotationNotifications = "quotation_notifications"
        case chatNotifications = "chat_notifications"
        case promotionNotifications = "promotion_notifications"
        case workshopNotifications = "workshop_notifications"
        case orderNotifications = "order_notifications"
    }
}

struct PushNotification: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let body: String
    let notificationType: String
    let data: [String: String]?
    let sentAt: String
    let readAt: String?
    let actionUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, data
        case userId = "user_id"
        case notificationType = "notification_type"
        case sentAt = "sent_at"
        case readAt = "read_at"
        case actionUrl = "action_url"
    }
}

struct NotificationSchedule: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let scheduledFor: String
    let notificationType: String
    let targetUsers: [String]
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, status
        case scheduledFor = "scheduled_for"
        case notificationType = "notification_type"
        case targetUsers = "target_users"
    }
}
