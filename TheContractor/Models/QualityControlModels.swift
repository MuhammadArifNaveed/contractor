//
//  QualityControlModels.swift
//  TheContractor
//

import Foundation

struct QualityInspection: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let inspectionType: String
    let inspectorName: String
    let inspectionDate: String
    let status: String
    let overallScore: Double
    let findings: [InspectionFinding]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, findings
        case projectId = "project_id"
        case projectName = "project_name"
        case inspectionType = "inspection_type"
        case inspectorName = "inspector_name"
        case inspectionDate = "inspection_date"
        case overallScore = "overall_score"
    }
}

struct InspectionFinding: Codable, Identifiable {
    let id: String
    let category: String
    let severity: String
    let description: String
    let recommendation: String
    let status: String
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, category, severity, description, recommendation, status, images
    }
}

struct QualityStandard: Codable, Identifiable {
    let id: String
    let standardName: String
    let standardNameArabic: String
    let category: String
    let description: String
    let criteria: [String]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, category, description, criteria
        case standardName = "standard_name"
        case standardNameArabic = "standard_name_arabic"
        case isActive = "is_active"
    }
}

struct QualityReport: Codable, Identifiable {
    let id: String
    let projectId: String
    let reportDate: String
    let complianceScore: Double
    let defectsFound: Int
    let defectsResolved: Int
    let recommendations: [String]
    let nextInspectionDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, recommendations
        case projectId = "project_id"
        case reportDate = "report_date"
        case complianceScore = "compliance_score"
        case defectsFound = "defects_found"
        case defectsResolved = "defects_resolved"
        case nextInspectionDate = "next_inspection_date"
    }
}
