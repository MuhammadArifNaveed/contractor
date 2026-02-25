//
//  DocumentModels.swift
//  TheContractor
//

import Foundation

struct DocumentItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let fileUrl: String
    let fileType: String
    let fileSize: String
    let categoryId: String?
    let uploadedBy: String
    let uploadedDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case fileUrl = "file_url"
        case fileType = "file_type"
        case fileSize = "file_size"
        case categoryId = "category_id"
        case uploadedBy = "uploaded_by"
        case uploadedDate = "uploaded_date"
    }
}

struct DocumentUpload {
    let title: String
    let description: String
    let categoryId: String?
    let fileData: Data
    let fileName: String
    let fileType: String
}

struct CompanyDocument: Codable, Identifiable {
    let id: String
    let companyId: String
    let documentType: String
    let documentName: String
    let documentUrl: String
    let verificationStatus: String
    let uploadedDate: String
    let expiryDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case documentType = "document_type"
        case documentName = "document_name"
        case documentUrl = "document_url"
        case verificationStatus = "verification_status"
        case uploadedDate = "uploaded_date"
        case expiryDate = "expiry_date"
    }
}
