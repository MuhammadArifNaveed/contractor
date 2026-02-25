//
//  SiteLogisticsModels.swift
//  TheContractor
//

import Foundation

struct DeliverySchedule: Codable, Identifiable {
    let id: String
    let projectId: String
    let supplierId: String
    let supplierName: String
    let deliveryDate: String
    let materialDescription: String
    let quantity: String
    let deliveryStatus: String
    let receivedBy: String?
    let receivedDate: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, notes
        case projectId = "project_id"
        case supplierId = "supplier_id"
        case supplierName = "supplier_name"
        case deliveryDate = "delivery_date"
        case materialDescription = "material_description"
        case deliveryStatus = "delivery_status"
        case receivedBy = "received_by"
        case receivedDate = "received_date"
    }
}

struct SiteAccess: Codable, Identifiable {
    let id: String
    let projectId: String
    let personName: String
    let company: String
    let purpose: String
    let accessDate: String
    let exitDate: String?
    let authorizedBy: String
    let badgeNumber: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, company, purpose, status
        case projectId = "project_id"
        case personName = "person_name"
        case accessDate = "access_date"
        case exitDate = "exit_date"
        case authorizedBy = "authorized_by"
        case badgeNumber = "badge_number"
    }
}

struct EquipmentDeployment: Codable, Identifiable {
    let id: String
    let projectId: String
    let equipmentType: String
    let equipmentName: String
    let deploymentDate: String
    let returnDate: String?
    let assignedTo: String
    let location: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, location, status
        case projectId = "project_id"
        case equipmentType = "equipment_type"
        case equipmentName = "equipment_name"
        case deploymentDate = "deployment_date"
        case returnDate = "return_date"
        case assignedTo = "assigned_to"
    }
}

struct SiteReport: Codable, Identifiable {
    let id: String
    let projectId: String
    let reportDate: String
    let reportedBy: String
    let weatherConditions: String
    let workersPresent: Int
    let workCompleted: String
    let issuesEncountered: String?
    let safetyIncidents: Int
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, images
        case projectId = "project_id"
        case reportDate = "report_date"
        case reportedBy = "reported_by"
        case weatherConditions = "weather_conditions"
        case workersPresent = "workers_present"
        case workCompleted = "work_completed"
        case issuesEncountered = "issues_encountered"
        case safetyIncidents = "safety_incidents"
    }
}
