//
//  GeolocationModels.swift
//  TheContractor
//

import Foundation

struct NearbyCompany: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyNameArabic: String
    let companyLogo: String?
    let categoryName: String
    let avgRating: String
    let reviewCount: String
    let isVerified: String
    let address: String
    let latitude: String
    let longitude: String
    let distance: Double
    let distanceUnit: String
    
    enum CodingKeys: String, CodingKey {
        case id, address, latitude, longitude, distance
        case companyName = "company_name"
        case companyNameArabic = "company_name_arabic"
        case companyLogo = "company_logo"
        case categoryName = "category_name"
        case avgRating = "avg_rating"
        case reviewCount = "review_count"
        case isVerified = "is_verified"
        case distanceUnit = "distance_unit"
    }
}

struct ServiceArea: Codable, Identifiable {
    let id: String
    let companyId: String
    let cityId: String
    let cityName: String
    let areaName: String
    let areaNameArabic: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case cityId = "city_id"
        case cityName = "city_name"
        case areaName = "area_name"
        case areaNameArabic = "area_name_arabic"
        case isActive = "is_active"
    }
}

struct LocationTracking: Codable {
    let userId: String
    let latitude: String
    let longitude: String
    let accuracy: String
    let timestamp: String
    let activityType: String?
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, accuracy, timestamp
        case userId = "user_id"
        case activityType = "activity_type"
    }
}

struct GeoFence: Codable, Identifiable {
    let id: String
    let name: String
    let centerLatitude: String
    let centerLongitude: String
    let radius: Double
    let isActive: Bool
    let notifyOnEntry: Bool
    let notifyOnExit: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, radius
        case centerLatitude = "center_latitude"
        case centerLongitude = "center_longitude"
        case isActive = "is_active"
        case notifyOnEntry = "notify_on_entry"
        case notifyOnExit = "notify_on_exit"
    }
}
