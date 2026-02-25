//
//  SettingsModels.swift
//  TheContractor
//

import Foundation

struct AppSettings: Codable {
    var language: String
    var currency: String
    var measurementUnit: String
    var dateFormat: String
    var notificationsEnabled: Bool
    var locationServicesEnabled: Bool
    var darkModeEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case language, currency
        case measurementUnit = "measurement_unit"
        case dateFormat = "date_format"
        case notificationsEnabled = "notifications_enabled"
        case locationServicesEnabled = "location_services_enabled"
        case darkModeEnabled = "dark_mode_enabled"
    }
}

struct LanguageOption: Codable, Identifiable {
    let id: String
    let name: String
    let code: String
    let flag: String
    let isRTL: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, code, flag
        case isRTL = "is_rtl"
    }
}

struct AppVersion: Codable {
    let version: String
    let buildNumber: String
    let releaseDate: String
    let features: [String]
    let isUpdateRequired: Bool
    let updateUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case version, features
        case buildNumber = "build_number"
        case releaseDate = "release_date"
        case isUpdateRequired = "is_update_required"
        case updateUrl = "update_url"
    }
}
