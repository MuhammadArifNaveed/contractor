//
//  SubcontractorModels.swift
//  TheContractor
//

import Foundation

struct Subcontractor: Codable, Identifiable {
    let id: String
    let companyName: String
    let companyNameArabic: String
    let tradeName: String
    let contactPerson: String
    let phone: String
    let email: String
    let licenseNumber: String
    let specialization: [String]?
    let rating: Double
    let isVerified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, phone, email, specialization, rating
        case companyName = "company_name"
        case companyNameArabic = "company_name_arabic"
        case tradeName = "trade_name"
        case contactPerson = "contact_person"
        case licenseNumber = "license_number"
        case isVerified = "is_verified"
    }
}

struct SubcontractorAgreement: Codable, Identifiable {
    let id: String
    let projectId: String
    let subcontractorId: String
    let subcontractorName: String
    let scopeOfWork: String
    let startDate: String
    let endDate: String
    let contractValue: String
    let paymentTerms: String
    let status: String
    let documentUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case projectId = "project_id"
        case subcontractorId = "subcontractor_id"
        case subcontractorName = "subcontractor_name"
        case scopeOfWork = "scope_of_work"
        case startDate = "start_date"
        case endDate = "end_date"
        case contractValue = "contract_value"
        case paymentTerms = "payment_terms"
        case documentUrl = "document_url"
    }
}

struct SubcontractorInvoice: Codable, Identifiable {
    let id: String
    let agreementId: String
    let subcontractorId: String
    let subcontractorName: String
    let invoiceNumber: String
    let invoiceDate: String
    let amount: String
    let workDescription: String
    let status: String
    let paidDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, status
        case agreementId = "agreement_id"
        case subcontractorId = "subcontractor_id"
        case subcontractorName = "subcontractor_name"
        case invoiceNumber = "invoice_number"
        case invoiceDate = "invoice_date"
        case workDescription = "work_description"
        case paidDate = "paid_date"
    }
}

struct SubcontractorPerformance: Codable, Identifiable {
    let id: String
    let subcontractorId: String
    let projectId: String
    let qualityRating: Double
    let timelinessRating: Double
    let safetyRating: Double
    let overallRating: Double
    let reviewedBy: String
    let reviewDate: String
    let comments: String?
    
    enum CodingKeys: String, CodingKey {
        case id, comments
        case subcontractorId = "subcontractor_id"
        case projectId = "project_id"
        case qualityRating = "quality_rating"
        case timelinessRating = "timeliness_rating"
        case safetyRating = "safety_rating"
        case overallRating = "overall_rating"
        case reviewedBy = "reviewed_by"
        case reviewDate = "review_date"
    }
}
