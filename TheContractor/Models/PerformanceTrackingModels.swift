//
//  PerformanceTrackingModels.swift
//  TheContractor
//

import Foundation

struct PerformanceMetrics: Codable {
    let companyId: String
    let period: String
    let totalProjects: Int
    let completedProjects: Int
    let onTimeDelivery: Double
    let customerSatisfaction: Double
    let avgResponseTime: String
    let repeatCustomerRate: Double
    let revenueGrowth: Double
    
    enum CodingKeys: String, CodingKey {
        case period, revenueGrowth
        case companyId = "company_id"
        case totalProjects = "total_projects"
        case completedProjects = "completed_projects"
        case onTimeDelivery = "on_time_delivery"
        case customerSatisfaction = "customer_satisfaction"
        case avgResponseTime = "avg_response_time"
        case repeatCustomerRate = "repeat_customer_rate"
    }
}

struct KPITarget: Codable, Identifiable {
    let id: String
    let companyId: String
    let kpiName: String
    let targetValue: Double
    let currentValue: Double
    let unit: String
    let period: String
    let progress: Double
    
    enum CodingKeys: String, CodingKey {
        case id, unit, period, progress
        case companyId = "company_id"
        case kpiName = "kpi_name"
        case targetValue = "target_value"
        case currentValue = "current_value"
    }
}

struct ProjectPerformance: Codable, Identifiable {
    let id: String
    let projectName: String
    let companyId: String
    let plannedStartDate: String
    let actualStartDate: String?
    let plannedEndDate: String
    let actualEndDate: String?
    let budgetedCost: String
    let actualCost: String
    let completionPercentage: Double
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case projectName = "project_name"
        case companyId = "company_id"
        case plannedStartDate = "planned_start_date"
        case actualStartDate = "actual_start_date"
        case plannedEndDate = "planned_end_date"
        case actualEndDate = "actual_end_date"
        case budgetedCost = "budgeted_cost"
        case actualCost = "actual_cost"
        case completionPercentage = "completion_percentage"
    }
}

struct EmployeePerformance: Codable, Identifiable {
    let id: String
    let employeeName: String
    let companyId: String
    let completedTasks: Int
    let averageRating: Double
    let punctuality: Double
    let efficiency: Double
    let period: String
    
    enum CodingKeys: String, CodingKey {
        case id, period
        case employeeName = "employee_name"
        case companyId = "company_id"
        case completedTasks = "completed_tasks"
        case averageRating = "average_rating"
        case punctuality, efficiency
    }
}
