//
//  CostEstimationModels.swift
//  TheContractor
//

import Foundation

struct CostEstimate: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let estimateNumber: String
    let preparedBy: String
    let estimateDate: String
    let totalCost: String
    let contingency: String
    let grandTotal: String
    let status: String
    let categories: [CostCategory]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, categories
        case projectId = "project_id"
        case projectName = "project_name"
        case estimateNumber = "estimate_number"
        case preparedBy = "prepared_by"
        case estimateDate = "estimate_date"
        case totalCost = "total_cost"
        case contingency
        case grandTotal = "grand_total"
    }
}

struct CostCategory: Codable, Identifiable {
    let id: String
    let categoryName: String
    let items: [CostItem]?
    let subtotal: String
    
    enum CodingKeys: String, CodingKey {
        case id, items, subtotal
        case categoryName = "category_name"
    }
}

struct CostItem: Codable, Identifiable {
    let id: String
    let itemDescription: String
    let quantity: String
    let unit: String
    let unitPrice: String
    let totalPrice: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, unit, notes
        case itemDescription = "item_description"
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
    }
}

struct BudgetVariance: Codable, Identifiable {
    let id: String
    let projectId: String
    let category: String
    let budgetedAmount: String
    let actualAmount: String
    let variance: String
    let variancePercentage: Double
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, variance, status
        case projectId = "project_id"
        case budgetedAmount = "budgeted_amount"
        case actualAmount = "actual_amount"
        case variancePercentage = "variance_percentage"
    }
}

struct CostForecast: Codable, Identifiable {
    let id: String
    let projectId: String
    let forecastDate: String
    let estimatedCompletion: String
    let projectedCost: String
    let costAtCompletion: String
    let varianceAtCompletion: String
    let preparedBy: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case forecastDate = "forecast_date"
        case estimatedCompletion = "estimated_completion"
        case projectedCost = "projected_cost"
        case costAtCompletion = "cost_at_completion"
        case varianceAtCompletion = "variance_at_completion"
        case preparedBy = "prepared_by"
    }
}
