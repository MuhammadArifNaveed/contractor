//
//  ComplianceModels.swift
//  TheContractor
//

import Foundation

struct ComplianceChecklist: Codable, Identifiable {
    let id: String
    let companyId: String
    let checklistName: String
    let category: String
    let totalItems: Int
    let completedItems: Int
    let status: String
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, status
        case companyId = "company_id"
        case checklistName = "checklist_name"
        case totalItems = "total_items"
        case completedItems = "completed_items"
        case lastUpdated = "last_updated"
    }
}

struct ComplianceItem: Codable, Identifiable {
    let id: String
    let checklistId: String
    let itemName: String
    let description: String
    let isCompleted: Bool
    let completedBy: String?
    let completedAt: String?
    let documentUrl: String?
    let expiryDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case checklistId = "checklist_id"
        case itemName = "item_name"
        case isCompleted = "is_completed"
        case completedBy = "completed_by"
        case completedAt = "completed_at"
        case documentUrl = "document_url"
        case expiryDate = "expiry_date"
    }
}

struct RegulatoryRequirement: Codable, Identifiable {
    let id: String
    let requirementName: String
    let requirementNameArabic: String
    let category: String
    let description: String
    let authority: String
    let effectiveDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, description, authority, status
        case requirementName = "requirement_name"
        case requirementNameArabic = "requirement_name_arabic"
        case effectiveDate = "effective_date"
    }
}

struct ComplianceViolation: Codable, Identifiable {
    let id: String
    let companyId: String
    let violationType: String
    let severity: String
    let description: String
    let reportedBy: String
    let reportedAt: String
    let resolvedAt: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, severity, description, status
        case companyId = "company_id"
        case violationType = "violation_type"
        case reportedBy = "reported_by"
        case reportedAt = "reported_at"
        case resolvedAt = "resolved_at"
    }
}
