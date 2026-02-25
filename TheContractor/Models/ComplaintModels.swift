//
//  ComplaintModels.swift
//  TheContractor
//

import Foundation

struct ComplaintSubmission {
    let companyId: String
    let subject: String
    let description: String
    let images: [Data]?
}

struct ComplaintListItem: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyLogo: String
    let subject: String
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case subject
        case status
        case createdAt = "created_at"
    }
}

struct ComplaintDetail: Codable {
    let id: String
    let companyName: String
    let subject: String
    let description: String
    let status: String
    let images: [String]?
    let adminResponse: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case subject
        case description
        case status
        case images
        case adminResponse = "admin_response"
        case createdAt = "created_at"
    }
}
