//
//  EnquiryDetailModels.swift
//  TheContractor
//

import Foundation

struct EnquiryDetailResponse: Codable {
    let enquiryId: String
    let userName: String
    let userPhone: String
    let userEmail: String
    let dateTime: String
    let location: String
    let description: String
    let createdAt: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case enquiryId = "enquiry_id"
        case userName = "user_name"
        case userPhone = "user_phone"
        case userEmail = "user_email"
        case dateTime = "date_time"
        case location
        case description
        case createdAt = "created_at"
        case status
    }
}

struct EnquiryListItem: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyLogo: String
    let dateTime: String
    let location: String
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case dateTime = "date_time"
        case location
        case status
        case createdAt = "created_at"
    }
}
