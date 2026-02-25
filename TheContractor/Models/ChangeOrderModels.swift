//
//  ChangeOrderModels.swift
//  TheContractor
//

import Foundation

struct ChangeOrder: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let changeOrderNumber: String
    let requestedBy: String
    let requestDate: String
    let description: String
    let reason: String
    let impactOnSchedule: String
    let impactOnCost: String
    let status: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, reason, status
        case projectId = "project_id"
        case projectName = "project_name"
        case changeOrderNumber = "change_order_number"
        case requestedBy = "requested_by"
        case requestDate = "request_date"
        case impactOnSchedule = "impact_on_schedule"
        case impactOnCost = "impact_on_cost"
        case approvedBy = "approved_by"
    }
}

struct ChangeOrderItem: Codable, Identifiable {
    let id: String
    let changeOrderId: String
    let itemDescription: String
    let originalScope: String
    let revisedScope: String
    let additionalCost: String
    let additionalTime: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case changeOrderId = "change_order_id"
        case itemDescription = "item_description"
        case originalScope = "original_scope"
        case revisedScope = "revised_scope"
        case additionalCost = "additional_cost"
        case additionalTime = "additional_time"
    }
}

struct RiskAssessment: Codable, Identifiable {
    let id: String
    let projectId: String
    let riskCategory: String
    let riskDescription: String
    let likelihood: String
    let impact: String
    let riskLevel: String
    let mitigationPlan: String
    let owner: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, likelihood, impact, owner, status
        case projectId = "project_id"
        case riskCategory = "risk_category"
        case riskDescription = "risk_description"
        case riskLevel = "risk_level"
        case mitigationPlan = "mitigation_plan"
    }
}
