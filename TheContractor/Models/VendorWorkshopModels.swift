//
//  VendorWorkshopModels.swift
//  TheContractor
//

import Foundation

struct VendorWorkshopItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let categoryId: String
    let location: String
    let date: String
    let startTime: String
    let endTime: String
    let price: String
    let capacity: String
    let enrolledCount: String
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, date, price, capacity, status
        case categoryId = "category_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case enrolledCount = "enrolled_count"
        case createdAt = "created_at"
    }
}

struct WorkshopCreation {
    let vendorId: String
    let title: String
    let titleArabic: String
    let description: String
    let categoryId: String
    let location: String
    let city: String
    let date: String
    let startTime: String
    let endTime: String
    let price: String
    let capacity: String
    let images: [Data]?
}

struct WorkshopEnrollmentDetail: Codable, Identifiable {
    let id: String
    let workshopId: String
    let userName: String
    let userPhone: String
    let userEmail: String
    let enrollmentDate: String
    let paymentStatus: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case workshopId = "workshop_id"
        case userName = "user_name"
        case userPhone = "user_phone"
        case userEmail = "user_email"
        case enrollmentDate = "enrollment_date"
        case paymentStatus = "payment_status"
    }
}
