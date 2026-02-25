//
//  SafetyComplianceModels.swift
//  TheContractor
//

import Foundation

struct SafetyTraining: Codable, Identifiable {
    let id: String
    let trainingName: String
    let trainingNameArabic: String
    let category: String
    let duration: String
    let certificateValidity: String
    let isRequired: Bool
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, duration, description
        case trainingName = "training_name"
        case trainingNameArabic = "training_name_arabic"
        case certificateValidity = "certificate_validity"
        case isRequired = "is_required"
    }
}

struct SafetyEnrollment: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let trainingId: String
    let trainingName: String
    let enrollmentDate: String
    let completionDate: String?
    let status: String
    let score: String?
    let certificateUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, score
        case userId = "user_id"
        case userName = "user_name"
        case trainingId = "training_id"
        case trainingName = "training_name"
        case enrollmentDate = "enrollment_date"
        case completionDate = "completion_date"
        case certificateUrl = "certificate_url"
    }
}

struct SiteInspection: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let inspectorName: String
    let inspectionDate: String
    let inspectionType: String
    let overallRating: String
    let findings: [InspectionFinding]?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, findings, status
        case projectId = "project_id"
        case projectName = "project_name"
        case inspectorName = "inspector_name"
        case inspectionDate = "inspection_date"
        case inspectionType = "inspection_type"
        case overallRating = "overall_rating"
    }
}

struct InspectionFinding: Codable, Identifiable {
    let id: String
    let category: String
    let severity: String
    let description: String
    let correctiveAction: String
    let deadline: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, severity, description, deadline, status
        case correctiveAction = "corrective_action"
    }
}

struct SafetyIncident: Codable, Identifiable {
    let id: String
    let projectId: String
    let incidentDate: String
    let incidentType: String
    let severity: String
    let description: String
    let injuriesCount: Int
    let reportedBy: String
    let status: String
    let investigationNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, status
        case projectId = "project_id"
        case incidentDate = "incident_date"
        case incidentType = "incident_type"
        case severity
        case injuriesCount = "injuries_count"
        case reportedBy = "reported_by"
        case investigationNotes = "investigation_notes"
    }
}
