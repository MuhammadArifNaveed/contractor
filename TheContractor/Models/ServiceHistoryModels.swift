//
//  ServiceHistoryModels.swift
//  TheContractor
//

import Foundation

struct ServiceRecord: Codable, Identifiable {
    let id: String
    let userId: String
    let companyId: String
    let companyName: String
    let serviceType: String
    let serviceDate: String
    let description: String
    let cost: String
    let technicianName: String
    let rating: Double?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, cost, rating, status
        case userId = "user_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case serviceType = "service_type"
        case serviceDate = "service_date"
        case technicianName = "technician_name"
    }
}

struct MaintenanceSchedule: Codable, Identifiable {
    let id: String
    let assetId: String
    let assetName: String
    let maintenanceType: String
    let frequency: String
    let lastServiceDate: String?
    let nextServiceDate: String
    let isOverdue: Bool
    let assignedTo: String?
    
    enum CodingKeys: String, CodingKey {
        case id, frequency
        case assetId = "asset_id"
        case assetName = "asset_name"
        case maintenanceType = "maintenance_type"
        case lastServiceDate = "last_service_date"
        case nextServiceDate = "next_service_date"
        case isOverdue = "is_overdue"
        case assignedTo = "assigned_to"
    }
}

struct ServiceReport: Codable, Identifiable {
    let id: String
    let serviceRecordId: String
    let reportDate: String
    let workPerformed: String
    let partsUsed: [PartUsed]?
    let recommendations: String
    let technicianSignature: String?
    let customerSignature: String?
    
    enum CodingKeys: String, CodingKey {
        case id, recommendations
        case serviceRecordId = "service_record_id"
        case reportDate = "report_date"
        case workPerformed = "work_performed"
        case partsUsed = "parts_used"
        case technicianSignature = "technician_signature"
        case customerSignature = "customer_signature"
    }
}

struct PartUsed: Codable, Identifiable {
    let id: String
    let partName: String
    let quantity: Int
    let unitPrice: String
    let totalPrice: String
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case partName = "part_name"
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
    }
}

struct ServiceReminder: Codable, Identifiable {
    let id: String
    let userId: String
    let assetId: String
    let reminderType: String
    let reminderDate: String
    let message: String
    let isSent: Bool
    let sentAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, message
        case userId = "user_id"
        case assetId = "asset_id"
        case reminderType = "reminder_type"
        case reminderDate = "reminder_date"
        case isSent = "is_sent"
        case sentAt = "sent_at"
    }
}
