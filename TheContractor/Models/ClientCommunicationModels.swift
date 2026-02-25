//
//  ClientCommunicationModels.swift
//  TheContractor
//

import Foundation

struct ClientMeeting: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let clientName: String
    let meetingDate: String
    let meetingType: String
    let agenda: String
    let attendees: [String]?
    let minutes: String?
    let actionItems: [ActionItem]?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, agenda, attendees, minutes, status
        case projectId = "project_id"
        case projectName = "project_name"
        case clientName = "client_name"
        case meetingDate = "meeting_date"
        case meetingType = "meeting_type"
        case actionItems = "action_items"
    }
}

struct ActionItem: Codable, Identifiable {
    let id: String
    let description: String
    let assignedTo: String
    let dueDate: String
    let priority: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, priority, status
        case assignedTo = "assigned_to"
        case dueDate = "due_date"
    }
}

struct ClientFeedback: Codable, Identifiable {
    let id: String
    let projectId: String
    let clientName: String
    let feedbackDate: String
    let category: String
    let rating: Double
    let comments: String
    let concerns: String?
    let respondedBy: String?
    let responseDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, category, rating, comments, concerns
        case projectId = "project_id"
        case clientName = "client_name"
        case feedbackDate = "feedback_date"
        case respondedBy = "responded_by"
        case responseDate = "response_date"
    }
}

struct ProjectUpdate: Codable, Identifiable {
    let id: String
    let projectId: String
    let updateDate: String
    let subject: String
    let message: String
    let sentBy: String
    let recipients: [String]?
    let attachments: [String]?
    let isPublished: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, subject, message, recipients, attachments
        case projectId = "project_id"
        case updateDate = "update_date"
        case sentBy = "sent_by"
        case isPublished = "is_published"
    }
}

struct ClientApproval: Codable, Identifiable {
    let id: String
    let projectId: String
    let approvalType: String
    let description: String
    let requestedDate: String
    let requiredBy: String
    let approvedDate: String?
    let status: String
    let documentUrl: String?
    let comments: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, status, comments
        case projectId = "project_id"
        case approvalType = "approval_type"
        case requestedDate = "requested_date"
        case requiredBy = "required_by"
        case approvedDate = "approved_date"
        case documentUrl = "document_url"
    }
}

struct ChangeRequest: Codable, Identifiable {
    let id: String
    let projectId: String
    let requestedBy: String
    let requestDate: String
    let changeDescription: String
    let justification: String
    let estimatedCost: String
    let estimatedTime: String
    let status: String
    let reviewedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case projectId = "project_id"
        case requestedBy = "requested_by"
        case requestDate = "request_date"
        case changeDescription = "change_description"
        case justification
        case estimatedCost = "estimated_cost"
        case estimatedTime = "estimated_time"
        case reviewedBy = "reviewed_by"
    }
}
