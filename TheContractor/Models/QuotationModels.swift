//
//  QuotationModels.swift
//  TheContractor
//

import Foundation

struct QuotationRequest: Codable {
    let companyId: String
    let description: String
    let location: String
    let dateTime: String
    
    enum CodingKeys: String, CodingKey {
        case companyId = "company_id"
        case description
        case location
        case dateTime = "date_time"
    }
}

struct QuotationListItem: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyLogo: String
    let description: String
    let amount: String?
    let status: String
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case description
        case amount
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct QuotationDetail: Codable {
    let id: String
    let companyName: String
    let companyLogo: String
    let description: String
    let amount: String?
    let status: String
    let location: String
    let dateTime: String
    let vendorNotes: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case description
        case amount
        case status
        case location
        case dateTime = "date_time"
        case vendorNotes = "vendor_notes"
        case createdAt = "created_at"
    }
}
