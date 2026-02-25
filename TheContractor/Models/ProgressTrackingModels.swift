//
//  ProgressTrackingModels.swift
//  TheContractor
//

import Foundation

struct ProjectProgress: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let overallProgress: Double
    let plannedProgress: Double
    let variance: Double
    let phases: [PhaseProgress]?
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, phases
        case projectId = "project_id"
        case projectName = "project_name"
        case overallProgress = "overall_progress"
        case plannedProgress = "planned_progress"
        case variance
        case lastUpdated = "last_updated"
    }
}

struct PhaseProgress: Codable, Identifiable {
    let id: String
    let phaseName: String
    let startDate: String
    let endDate: String
    let progress: Double
    let status: String
    let tasksCompleted: Int
    let tasksTotal: Int
    
    enum CodingKeys: String, CodingKey {
        case id, progress, status
        case phaseName = "phase_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case tasksCompleted = "tasks_completed"
        case tasksTotal = "tasks_total"
    }
}

struct WorkLog: Codable, Identifiable {
    let id: String
    let projectId: String
    let workDate: String
    let loggedBy: String
    let hoursWorked: Double
    let taskDescription: String
    let progressPercentage: Double
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, notes
        case projectId = "project_id"
        case workDate = "work_date"
        case loggedBy = "logged_by"
        case hoursWorked = "hours_worked"
        case taskDescription = "task_description"
        case progressPercentage = "progress_percentage"
    }
}

struct ProgressPhoto: Codable, Identifiable {
    let id: String
    let projectId: String
    let phaseId: String
    let photoDate: String
    let description: String
    let uploadedBy: String
    let imageUrl: String
    let latitude: String?
    let longitude: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, latitude, longitude
        case projectId = "project_id"
        case phaseId = "phase_id"
        case photoDate = "photo_date"
        case uploadedBy = "uploaded_by"
        case imageUrl = "image_url"
    }
}
