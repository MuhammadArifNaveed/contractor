//
//  CustomerPortalModels.swift
//  TheContractor
//

import Foundation

struct CustomerDashboard: Codable {
    let userId: String
    let activeProjects: Int
    let pendingInvoices: Int
    let upcomingAppointments: Int
    let openTickets: Int
    let totalSpent: String
    let recentActivity: [ActivityItem]?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case activeProjects = "active_projects"
        case pendingInvoices = "pending_invoices"
        case upcomingAppointments = "upcoming_appointments"
        case openTickets = "open_tickets"
        case totalSpent = "total_spent"
        case recentActivity = "recent_activity"
    }
}

struct ActivityItem: Codable, Identifiable {
    let id: String
    let activityType: String
    let description: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, timestamp
        case activityType = "activity_type"
    }
}

struct ProjectStatus: Codable, Identifiable {
    let id: String
    let projectName: String
    let companyName: String
    let status: String
    let progress: Double
    let startDate: String
    let estimatedEndDate: String
    let milestones: [MilestoneStatus]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, progress, milestones
        case projectName = "project_name"
        case companyName = "company_name"
        case startDate = "start_date"
        case estimatedEndDate = "estimated_end_date"
    }
}

struct MilestoneStatus: Codable, Identifiable {
    let id: String
    let name: String
    let status: String
    let completedDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, status
        case completedDate = "completed_date"
    }
}

struct CustomerDocument: Codable, Identifiable {
    let id: String
    let documentType: String
    let documentName: String
    let fileUrl: String
    let uploadedAt: String
    let expiryDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case documentType = "document_type"
        case documentName = "document_name"
        case fileUrl = "file_url"
        case uploadedAt = "uploaded_at"
        case expiryDate = "expiry_date"
    }
}

struct CustomerPreference: Codable {
    let userId: String
    let emailNotifications: Bool
    let smsNotifications: Bool
    let pushNotifications: Bool
    let preferredLanguage: String
    let preferredCurrency: String
    let autoRenewSubscription: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case emailNotifications = "email_notifications"
        case smsNotifications = "sms_notifications"
        case pushNotifications = "push_notifications"
        case preferredLanguage = "preferred_language"
        case preferredCurrency = "preferred_currency"
        case autoRenewSubscription = "auto_renew_subscription"
    }
}
