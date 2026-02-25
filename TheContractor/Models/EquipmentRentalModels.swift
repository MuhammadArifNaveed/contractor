//
//  EquipmentRentalModels.swift
//  TheContractor
//

import Foundation

struct Equipment: Codable, Identifiable {
    let id: String
    let companyId: String
    let equipmentName: String
    let equipmentNameArabic: String
    let category: String
    let description: String
    let specifications: String
    let hourlyRate: String
    let dailyRate: String
    let weeklyRate: String
    let monthlyRate: String
    let images: [String]
    let isAvailable: Bool
    let condition: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, description, specifications, images, condition, location
        case companyId = "company_id"
        case equipmentName = "equipment_name"
        case equipmentNameArabic = "equipment_name_arabic"
        case hourlyRate = "hourly_rate"
        case dailyRate = "daily_rate"
        case weeklyRate = "weekly_rate"
        case monthlyRate = "monthly_rate"
        case isAvailable = "is_available"
    }
}

struct EquipmentRental: Codable, Identifiable {
    let id: String
    let equipmentId: String
    let equipmentName: String
    let userId: String
    let companyId: String
    let rentalType: String
    let startDate: String
    let endDate: String
    let totalAmount: String
    let depositAmount: String
    let status: String
    let deliveryAddress: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case equipmentId = "equipment_id"
        case equipmentName = "equipment_name"
        case userId = "user_id"
        case companyId = "company_id"
        case rentalType = "rental_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case totalAmount = "total_amount"
        case depositAmount = "deposit_amount"
        case deliveryAddress = "delivery_address"
    }
}

struct EquipmentMaintenance: Codable, Identifiable {
    let id: String
    let equipmentId: String
    let maintenanceType: String
    let scheduledDate: String
    let completedDate: String?
    let performedBy: String
    let cost: String
    let notes: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, cost, notes, status
        case equipmentId = "equipment_id"
        case maintenanceType = "maintenance_type"
        case scheduledDate = "scheduled_date"
        case completedDate = "completed_date"
        case performedBy = "performed_by"
    }
}
