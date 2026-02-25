//
//  CertificationModels.swift
//  TheContractor
//

import Foundation

struct Certification: Codable, Identifiable {
    let id: String
    let companyId: String
    let certificateName: String
    let certificateNameArabic: String
    let issuingAuthority: String
    let certificateNumber: String
    let issueDate: String
    let expiryDate: String?
    let documentUrl: String
    let verificationStatus: String
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case certificateName = "certificate_name"
        case certificateNameArabic = "certificate_name_arabic"
        case issuingAuthority = "issuing_authority"
        case certificateNumber = "certificate_number"
        case issueDate = "issue_date"
        case expiryDate = "expiry_date"
        case documentUrl = "document_url"
        case verificationStatus = "verification_status"
        case isVerified = "is_verified"
    }
}

struct License: Codable, Identifiable {
    let id: String
    let companyId: String
    let licenseType: String
    let licenseTypeArabic: String
    let licenseNumber: String
    let issuingAuthority: String
    let issueDate: String
    let expiryDate: String
    let documentUrl: String
    let verificationStatus: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case licenseType = "license_type"
        case licenseTypeArabic = "license_type_arabic"
        case licenseNumber = "license_number"
        case issuingAuthority = "issuing_authority"
        case issueDate = "issue_date"
        case expiryDate = "expiry_date"
        case documentUrl = "document_url"
        case verificationStatus = "verification_status"
        case isActive = "is_active"
    }
}

struct CertificationUpload {
    let companyId: String
    let certificateName: String
    let certificateNameArabic: String
    let issuingAuthority: String
    let certificateNumber: String
    let issueDate: String
    let expiryDate: String?
}
