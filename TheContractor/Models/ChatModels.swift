//
//  ChatModels.swift
//  TheContractor
//

import Foundation

struct ChatConversation: Codable, Identifiable {
    let id: String
    let participantId: String
    let participantName: String
    let participantImage: String?
    let participantType: String
    let lastMessage: String
    let lastMessageTime: String
    let unreadCount: Int
    let isOnline: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case participantId = "participant_id"
        case participantName = "participant_name"
        case participantImage = "participant_image"
        case participantType = "participant_type"
        case lastMessage = "last_message"
        case lastMessageTime = "last_message_time"
        case unreadCount = "unread_count"
        case isOnline = "is_online"
    }
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let message: String
    let messageType: String
    let attachments: [String]?
    let isRead: Bool
    let sentAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, message, attachments
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case senderName = "sender_name"
        case messageType = "message_type"
        case isRead = "is_read"
        case sentAt = "sent_at"
    }
}

struct MessageSend {
    let conversationId: String
    let senderId: String
    let receiverId: String
    let message: String
    let messageType: String
    let attachments: [Data]?
}

struct TypingIndicator: Codable {
    let conversationId: String
    let userId: String
    let isTyping: Bool
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case userId = "user_id"
        case isTyping = "is_typing"
    }
}
