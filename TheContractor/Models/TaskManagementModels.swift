//
//  TaskManagementModels.swift
//  TheContractor
//

import Foundation

struct Task: Codable, Identifiable {
    let id: String
    let projectId: String
    let title: String
    let description: String
    let assignedTo: String
    let assignedToName: String
    let priority: String
    let status: String
    let dueDate: String
    let estimatedHours: String
    let actualHours: String?
    let completionPercentage: Double
    let createdBy: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, priority, status
        case projectId = "project_id"
        case assignedTo = "assigned_to"
        case assignedToName = "assigned_to_name"
        case dueDate = "due_date"
        case estimatedHours = "estimated_hours"
        case actualHours = "actual_hours"
        case completionPercentage = "completion_percentage"
        case createdBy = "created_by"
        case createdAt = "created_at"
    }
}

struct TaskDependency: Codable, Identifiable {
    let id: String
    let taskId: String
    let dependsOnTaskId: String
    let dependencyType: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case dependsOnTaskId = "depends_on_task_id"
        case dependencyType = "dependency_type"
    }
}

struct TaskComment: Codable, Identifiable {
    let id: String
    let taskId: String
    let userId: String
    let userName: String
    let comment: String
    let attachments: [String]?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, comment, attachments
        case taskId = "task_id"
        case userId = "user_id"
        case userName = "user_name"
        case createdAt = "created_at"
    }
}

struct TaskChecklist: Codable, Identifiable {
    let id: String
    let taskId: String
    let itemName: String
    let isCompleted: Bool
    let completedBy: String?
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case itemName = "item_name"
        case isCompleted = "is_completed"
        case completedBy = "completed_by"
        case completedAt = "completed_at"
    }
}
