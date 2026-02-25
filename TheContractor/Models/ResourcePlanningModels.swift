//
//  ResourcePlanningModels.swift
//  TheContractor
//

import Foundation

struct Resource: Codable, Identifiable {
    let id: String
    let resourceName: String
    let resourceType: String
    let availability: String
    let costPerHour: String
    let skillSet: [String]
    let currentProject: String?
    let utilization: Double
    
    enum CodingKeys: String, CodingKey {
        case id, availability, utilization
        case resourceName = "resource_name"
        case resourceType = "resource_type"
        case costPerHour = "cost_per_hour"
        case skillSet = "skill_set"
        case currentProject = "current_project"
    }
}

struct ResourceAllocation: Codable, Identifiable {
    let id: String
    let resourceId: String
    let resourceName: String
    let projectId: String
    let projectName: String
    let startDate: String
    let endDate: String
    let allocationPercentage: Double
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id, role
        case resourceId = "resource_id"
        case resourceName = "resource_name"
        case projectId = "project_id"
        case projectName = "project_name"
        case startDate = "start_date"
        case endDate = "end_date"
        case allocationPercentage = "allocation_percentage"
    }
}

struct ResourceForecast: Codable {
    let period: String
    let requiredResources: Int
    let availableResources: Int
    let gap: Int
    let utilizationRate: Double
    let recommendations: [String]
    
    enum CodingKeys: String, CodingKey {
        case period, gap, recommendations
        case requiredResources = "required_resources"
        case availableResources = "available_resources"
        case utilizationRate = "utilization_rate"
    }
}

struct CapacityPlanning: Codable, Identifiable {
    let id: String
    let projectId: String
    let phase: String
    let requiredSkills: [String]
    let estimatedHours: Double
    let plannedStartDate: String
    let plannedEndDate: String
    let allocatedResources: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, phase, status
        case projectId = "project_id"
        case requiredSkills = "required_skills"
        case estimatedHours = "estimated_hours"
        case plannedStartDate = "planned_start_date"
        case plannedEndDate = "planned_end_date"
        case allocatedResources = "allocated_resources"
    }
}
