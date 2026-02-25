//
//  ContractManagementModels.swift
//  TheContractor
//

import Foundation

struct Contract: Codable, Identifiable {
    let id: String
    let contractNumber: String
    let userId: String
    let companyId: String
    let projectName: String
    let contractType: String
    let value: String
    let startDate: String
    let endDate: String
    let status: String
    let terms: String
    let documentUrl: String?
    let signedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, value, status, terms
        case contractNumber = "contract_number"
        case userId = "user_id"
        case companyId = "company_id"
        case projectName = "project_name"
        case contractType = "contract_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case documentUrl = "document_url"
        case signedAt = "signed_at"
    }
}

struct ContractMilestone: Codable, Identifiable {
    let id: String
    let contractId: String
    let milestoneName: String
    let description: String
    let amount: String
    let dueDate: String
    let status: String
    let completedAt: String?
    let paymentStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, amount, status
        case contractId = "contract_id"
        case milestoneName = "milestone_name"
        case dueDate = "due_date"
        case completedAt = "completed_at"
        case paymentStatus = "payment_status"
    }
}

struct ContractAmendment: Codable, Identifiable {
    let id: String
    let contractId: String
    let amendmentType: String
    let description: String
    let previousValue: String
    let newValue: String
    let requestedBy: String
    let approvedBy: String?
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, status
        case contractId = "contract_id"
        case amendmentType = "amendment_type"
        case previousValue = "previous_value"
        case newValue = "new_value"
        case requestedBy = "requested_by"
        case approvedBy = "approved_by"
        case createdAt = "created_at"
    }
}
