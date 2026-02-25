//
//  EmergencyServiceModels.swift
//  TheContractor
//

import Foundation

struct EmergencyCompany: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyLogo: String
    let categoryName: String
    let phone: String
    let emergencyPhone: String
    let location: String
    let city: String
    let avgRating: String
    let isVerified: String
    let is24x7: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, phone, location, city
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case categoryName = "category_name"
        case emergencyPhone = "emergency_phone"
        case avgRating = "avg_rating"
        case isVerified = "is_verified"
        case is24x7 = "is_24x7"
    }
}

struct EmergencyRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let serviceType: String
    let urgencyLevel: String
    let location: String
    let latitude: String
    let longitude: String
    let description: String
    let contactNumber: String
    let status: String
    let requestedAt: String
    let assignedCompanyId: String?
    let assignedCompanyName: String?
    let estimatedArrival: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, status
        case userId = "user_id"
        case userName = "user_name"
        case serviceType = "service_type"
        case urgencyLevel = "urgency_level"
        case location
        case latitude
        case longitude
        case contactNumber = "contact_number"
        case requestedAt = "requested_at"
        case assignedCompanyId = "assigned_company_id"
        case assignedCompanyName = "assigned_company_name"
        case estimatedArrival = "estimated_arrival"
    }
}

struct EmergencyResponse: Codable, Identifiable {
    let id: String
    let requestId: String
    let companyId: String
    let companyName: String
    let responseTime: String
    let technicianName: String
    let technicianPhone: String
    let status: String
    let arrivedAt: String?
    let completedAt: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case requestId = "request_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case responseTime = "response_time"
        case technicianName = "technician_name"
        case technicianPhone = "technician_phone"
        case arrivedAt = "arrived_at"
        case completedAt = "completed_at"
    }
}

struct EmergencyContact: Codable, Identifiable {
    let id: String
    let serviceCategory: String
    let companyName: String
    let contactNumber: String
    let email: String
    let availableHours: String
    let coverage: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case id, email, priority
        case serviceCategory = "service_category"
        case companyName = "company_name"
        case contactNumber = "contact_number"
        case availableHours = "available_hours"
        case coverage
    }
}

struct EmergencyProtocol: Codable, Identifiable {
    let id: String
    let protocolName: String
    let protocolNameArabic: String
    let serviceType: String
    let steps: [ProtocolStep]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, steps
        case protocolName = "protocol_name"
        case protocolNameArabic = "protocol_name_arabic"
        case serviceType = "service_type"
        case isActive = "is_active"
    }
}

struct ProtocolStep: Codable, Identifiable {
    let id: String
    let stepOrder: Int
    let stepDescription: String
    let estimatedDuration: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case stepOrder = "step_order"
        case stepDescription = "step_description"
        case estimatedDuration = "estimated_duration"
    }
}
