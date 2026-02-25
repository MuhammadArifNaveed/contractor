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

struct EmergencyRequest {
    let userId: String
    let companyId: String
    let description: String
    let location: String
    let lat: String
    let lng: String
    let urgencyLevel: String
}
