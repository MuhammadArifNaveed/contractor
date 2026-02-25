//
//  VendorOnboardingModels.swift
//  TheContractor
//

import Foundation

struct OnboardingApplication: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyNameArabic: String
    let applicantName: String
    let email: String
    let phone: String
    let businessType: String
    let yearEstablished: String
    let licenseNumber: String
    let status: String
    let submittedAt: String
    let reviewedBy: String?
    let reviewedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone, status
        case companyName = "company_name"
        case companyNameArabic = "company_name_arabic"
        case applicantName = "applicant_name"
        case businessType = "business_type"
        case yearEstablished = "year_established"
        case licenseNumber = "license_number"
        case submittedAt = "submitted_at"
        case reviewedBy = "reviewed_by"
        case reviewedAt = "reviewed_at"
    }
}

struct OnboardingStep: Codable, Identifiable {
    let id: String
    let stepName: String
    let stepOrder: Int
    let isRequired: Bool
    let isCompleted: Bool
    let completedAt: String?
    let documents: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, documents
        case stepName = "step_name"
        case stepOrder = "step_order"
        case isRequired = "is_required"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
    }
}

struct VendorVerification: Codable, Identifiable {
    let id: String
    let companyId: String
    let verificationType: String
    let status: String
    let verifiedBy: String?
    let verifiedAt: String?
    let expiryDate: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case companyId = "company_id"
        case verificationType = "verification_type"
        case verifiedBy = "verified_by"
        case verifiedAt = "verified_at"
        case expiryDate = "expiry_date"
    }
}

struct OnboardingDocument: Codable, Identifiable {
    let id: String
    let applicationId: String
    let documentType: String
    let documentUrl: String
    let uploadedAt: String
    let verificationStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "application_id"
        case documentType = "document_type"
        case documentUrl = "document_url"
        case uploadedAt = "uploaded_at"
        case verificationStatus = "verification_status"
    }
}
