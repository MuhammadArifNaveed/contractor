//
//  ServiceRequestModels.swift
//  TheContractor
//

import Foundation

struct ServiceRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let serviceType: String
    let categoryId: String
    let title: String
    let description: String
    let location: String
    let latitude: String
    let longitude: String
    let preferredDate: String
    let budgetRange: String
    let urgency: String
    let status: String
    let images: [String]?
    let matchedCompanies: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, latitude, longitude, urgency, status, images
        case userId = "user_id"
        case serviceType = "service_type"
        case categoryId = "category_id"
        case preferredDate = "preferred_date"
        case budgetRange = "budget_range"
        case matchedCompanies = "matched_companies"
        case createdAt = "created_at"
    }
}

struct ServiceProposal: Codable, Identifiable {
    let id: String
    let requestId: String
    let companyId: String
    let companyName: String
    let companyLogo: String?
    let proposedAmount: String
    let estimatedDuration: String
    let description: String
    let includedServices: [String]
    let validUntil: String
    let status: String
    let submittedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, status
        case requestId = "request_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case proposedAmount = "proposed_amount"
        case estimatedDuration = "estimated_duration"
        case includedServices = "included_services"
        case validUntil = "valid_until"
        case submittedAt = "submitted_at"
    }
}

struct ServiceSchedule: Codable, Identifiable {
    let id: String
    let requestId: String
    let companyId: String
    let scheduledDate: String
    let scheduledTime: String
    let duration: String
    let assignedTechnician: String?
    let status: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, duration, status, notes
        case requestId = "request_id"
        case companyId = "company_id"
        case scheduledDate = "scheduled_date"
        case scheduledTime = "scheduled_time"
        case assignedTechnician = "assigned_technician"
    }
}
