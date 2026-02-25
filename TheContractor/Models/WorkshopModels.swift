//
//  WorkshopModels.swift
//  TheContractor
//

import Foundation

struct WorkshopItem: Codable, Identifiable {
    let id: String
    let companyId: String
    let companyName: String
    let companyLogo: String
    let title: String
    let titleArabic: String
    let description: String
    let categoryId: String
    let categoryName: String
    let location: String
    let city: String
    let date: String
    let startTime: String
    let endTime: String
    let price: String
    let capacity: String
    let enrolledCount: String
    let status: String
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, description, location, city, date, price, capacity, status, images
        case companyId = "company_id"
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case title
        case titleArabic = "title_arabic"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case startTime = "start_time"
        case endTime = "end_time"
        case enrolledCount = "enrolled_count"
    }
}

struct WorkshopEnrollment {
    let userId: String
    let workshopId: String
    let paymentMethod: String?
}

struct UserWorkshopEnrollment: Codable, Identifiable {
    let id: String
    let workshopId: String
    let workshopTitle: String
    let companyName: String
    let date: String
    let startTime: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case workshopId = "workshop_id"
        case workshopTitle = "workshop_title"
        case companyName = "company_name"
        case date
        case startTime = "start_time"
        case status
    }
}
