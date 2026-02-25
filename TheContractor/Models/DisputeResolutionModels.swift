//
//  DisputeResolutionModels.swift
//  TheContractor
//

import Foundation

struct Dispute: Codable, Identifiable {
    let id: String
    let enquiryId: String
    let userId: String
    let companyId: String
    let disputeType: String
    let subject: String
    let description: String
    let status: String
    let priority: String
    let filedAt: String
    let resolvedAt: String?
    let resolution: String?
    
    enum CodingKeys: String, CodingKey {
        case id, subject, description, status, priority, resolution
        case enquiryId = "enquiry_id"
        case userId = "user_id"
        case companyId = "company_id"
        case disputeType = "dispute_type"
        case filedAt = "filed_at"
        case resolvedAt = "resolved_at"
    }
}

struct DisputeMessage: Codable, Identifiable {
    let id: String
    let disputeId: String
    let senderId: String
    let senderType: String
    let message: String
    let attachments: [String]?
    let sentAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, message, attachments
        case disputeId = "dispute_id"
        case senderId = "sender_id"
        case senderType = "sender_type"
        case sentAt = "sent_at"
    }
}

struct DisputeEvidence: Codable, Identifiable {
    let id: String
    let disputeId: String
    let uploadedBy: String
    let evidenceType: String
    let description: String
    let fileUrl: String
    let uploadedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case disputeId = "dispute_id"
        case uploadedBy = "uploaded_by"
        case evidenceType = "evidence_type"
        case fileUrl = "file_url"
        case uploadedAt = "uploaded_at"
    }
}

struct DisputeResolution: Codable {
    let disputeId: String
    let resolvedBy: String
    let resolution: String
    let compensationAmount: String?
    let actionTaken: String
    let closureNotes: String
    
    enum CodingKeys: String, CodingKey {
        case resolution
        case disputeId = "dispute_id"
        case resolvedBy = "resolved_by"
        case compensationAmount = "compensation_amount"
        case actionTaken = "action_taken"
        case closureNotes = "closure_notes"
    }
}
