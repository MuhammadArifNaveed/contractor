//
//  AdvancedFilterModels.swift
//  TheContractor
//

import Foundation

struct CompanyAdvancedFilters: Codable {
    let categoryIds: [String]?
    let cityIds: [String]?
    let minRating: Double?
    let maxRating: Double?
    let isVerified: Bool?
    let has24x7Service: Bool?
    let hasInsurance: Bool?
    let hasCertifications: Bool?
    let priceRange: String?
    let yearsInBusiness: String?
    let sortBy: String?
    let sortOrder: String?
    
    enum CodingKeys: String, CodingKey {
        case sortBy, sortOrder
        case categoryIds = "category_ids"
        case cityIds = "city_ids"
        case minRating = "min_rating"
        case maxRating = "max_rating"
        case isVerified = "is_verified"
        case has24x7Service = "has_24x7_service"
        case hasInsurance = "has_insurance"
        case hasCertifications = "has_certifications"
        case priceRange = "price_range"
        case yearsInBusiness = "years_in_business"
    }
}

struct WorkshopAdvancedFilters: Codable {
    let categoryIds: [String]?
    let cityIds: [String]?
    let priceMin: String?
    let priceMax: String?
    let dateFrom: String?
    let dateTo: String?
    let availability: String?
    let sortBy: String?
    let sortOrder: String?
    
    enum CodingKeys: String, CodingKey {
        case availability, sortBy, sortOrder
        case categoryIds = "category_ids"
        case cityIds = "city_ids"
        case priceMin = "price_min"
        case priceMax = "price_max"
        case dateFrom = "date_from"
        case dateTo = "date_to"
    }
}

struct FreelancerAdvancedFilters: Codable {
    let skills: [String]?
    let minHourlyRate: String?
    let maxHourlyRate: String?
    let minRating: Double?
    let experienceLevel: String?
    let availability: String?
    let sortBy: String?
    let sortOrder: String?
    
    enum CodingKeys: String, CodingKey {
        case skills, availability, sortBy, sortOrder
        case minHourlyRate = "min_hourly_rate"
        case maxHourlyRate = "max_hourly_rate"
        case minRating = "min_rating"
        case experienceLevel = "experience_level"
    }
}

struct SavedFilter: Codable, Identifiable {
    let id: String
    let userId: String
    let filterName: String
    let filterType: String
    let filterData: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case filterName = "filter_name"
        case filterType = "filter_type"
        case filterData = "filter_data"
        case createdAt = "created_at"
    }
}
