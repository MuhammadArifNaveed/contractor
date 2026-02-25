//
//  InsuranceModels.swift
//  TheContractor
//

import Foundation

struct InsurancePolicy: Codable, Identifiable {
    let id: String
    let companyId: String
    let policyType: String
    let policyTypeArabic: String
    let policyNumber: String
    let provider: String
    let coverageAmount: String
    let startDate: String
    let endDate: String
    let documentUrl: String
    let verificationStatus: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, provider
        case companyId = "company_id"
        case policyType = "policy_type"
        case policyTypeArabic = "policy_type_arabic"
        case policyNumber = "policy_number"
        case coverageAmount = "coverage_amount"
        case startDate = "start_date"
        case endDate = "end_date"
        case documentUrl = "document_url"
        case verificationStatus = "verification_status"
        case isActive = "is_active"
    }
}

struct InsuranceClaim: Codable, Identifiable {
    let id: String
    let policyId: String
    let userId: String
    let enquiryId: String?
    let claimAmount: String
    let claimDescription: String
    let claimDate: String
    let status: String
    let documents: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, documents
        case policyId = "policy_id"
        case userId = "user_id"
        case enquiryId = "enquiry_id"
        case claimAmount = "claim_amount"
        case claimDescription = "claim_description"
        case claimDate = "claim_date"
    }
}

struct InsuranceUpload {
    let companyId: String
    let policyType: String
    let policyTypeArabic: String
    let policyNumber: String
    let provider: String
    let coverageAmount: String
    let startDate: String
    let endDate: String
}
