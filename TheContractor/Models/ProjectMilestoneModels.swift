//
//  ProjectMilestoneModels.swift
//  TheContractor
//

import Foundation

struct ProjectMilestone: Codable, Identifiable {
    let id: String
    let projectId: String
    let milestoneName: String
    let description: String
    let targetDate: String
    let completionDate: String?
    let status: String
    let progress: Double
    let dependencies: [String]?
    let assignedTo: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, status, progress, dependencies
        case projectId = "project_id"
        case milestoneName = "milestone_name"
        case targetDate = "target_date"
        case completionDate = "completion_date"
        case assignedTo = "assigned_to"
    }
}

struct MilestoneDeliverable: Codable, Identifiable {
    let id: String
    let milestoneId: String
    let deliverableName: String
    let description: String
    let isCompleted: Bool
    let completedAt: String?
    let documentUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case milestoneId = "milestone_id"
        case deliverableName = "deliverable_name"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case documentUrl = "document_url"
    }
}

struct MilestoneApproval: Codable, Identifiable {
    let id: String
    let milestoneId: String
    let approverName: String
    let status: String
    let comments: String?
    let approvedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, comments
        case milestoneId = "milestone_id"
        case approverName = "approver_name"
        case approvedAt = "approved_at"
    }
}

struct ProjectTimeline: Codable {
    let projectId: String
    let startDate: String
    let plannedEndDate: String
    let actualEndDate: String?
    let totalMilestones: Int
    let completedMilestones: Int
    let milestones: [ProjectMilestone]?
    
    enum CodingKeys: String, CodingKey {
        case milestones
        case projectId = "project_id"
        case startDate = "start_date"
        case plannedEndDate = "planned_end_date"
        case actualEndDate = "actual_end_date"
        case totalMilestones = "total_milestones"
        case completedMilestones = "completed_milestones"
    }
}
