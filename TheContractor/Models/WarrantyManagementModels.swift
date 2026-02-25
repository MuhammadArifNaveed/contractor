//
//  WarrantyManagementModels.swift
//  TheContractor
//

import Foundation

struct Warranty: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let companyId: String
    let warrantyType: String
    let coverage: String
    let startDate: String
    let endDate: String
    let status: String
    let terms: String
    let certificateUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, coverage, status, terms
        case projectId = "project_id"
        case projectName = "project_name"
        case companyId = "company_id"
        case warrantyType = "warranty_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case certificateUrl = "certificate_url"
    }
}

struct WarrantyClaim: Codable, Identifiable {
    let id: String
    let warrantyId: String
    let userId: String
    let userName: String
    let issueDescription: String
    let priority: String
    let claimDate: String
    let status: String
    let resolutionDate: String?
    let resolutionNotes: String?
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, priority, status, images
        case warrantyId = "warranty_id"
        case userId = "user_id"
        case userName = "user_name"
        case issueDescription = "issue_description"
        case claimDate = "claim_date"
        case resolutionDate = "resolution_date"
        case resolutionNotes = "resolution_notes"
    }
}

struct WarrantyInspection: Codable, Identifiable {
    let id: String
    let warrantyId: String
    let inspectorName: String
    let inspectionDate: String
    let inspectionType: String
    let findings: String
    let recommendation: String
    let nextInspectionDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, findings, recommendation
        case warrantyId = "warranty_id"
        case inspectorName = "inspector_name"
        case inspectionDate = "inspection_date"
        case inspectionType = "inspection_type"
        case nextInspectionDate = "next_inspection_date"
    }
}

struct WarrantyRenewal: Codable, Identifiable {
    let id: String
    let warrantyId: String
    let renewalDate: String
    let newEndDate: String
    let renewalCost: String
    let status: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case warrantyId = "warranty_id"
        case renewalDate = "renewal_date"
        case newEndDate = "new_end_date"
        case renewalCost = "renewal_cost"
        case approvedBy = "approved_by"
    }
}
