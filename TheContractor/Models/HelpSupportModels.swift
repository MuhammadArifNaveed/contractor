//
//  HelpSupportModels.swift
//  TheContractor
//

import Foundation

struct FAQItem: Codable, Identifiable {
    let id: String
    let question: String
    let questionArabic: String
    let answer: String
    let answerArabic: String
    let categoryId: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id, question, answer
        case questionArabic = "question_arabic"
        case answerArabic = "answer_arabic"
        case categoryId = "category_id"
        case orderIndex = "order_index"
    }
}

struct SupportTicket: Codable, Identifiable {
    let id: String
    let userId: String
    let subject: String
    let description: String
    let category: String
    let priority: String
    let status: String
    let attachments: [String]?
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, subject, description, category, priority, status, attachments
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SupportMessage: Codable, Identifiable {
    let id: String
    let ticketId: String
    let senderId: String
    let senderType: String
    let message: String
    let attachments: [String]?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, message, attachments
        case ticketId = "ticket_id"
        case senderId = "sender_id"
        case senderType = "sender_type"
        case createdAt = "created_at"
    }
}
