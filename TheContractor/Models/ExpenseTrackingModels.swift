//
//  ExpenseTrackingModels.swift
//  TheContractor
//

import Foundation

struct Expense: Codable, Identifiable {
    let id: String
    let companyId: String
    let projectId: String?
    let categoryId: String
    let categoryName: String
    let amount: String
    let currency: String
    let expenseDate: String
    let description: String
    let paymentMethod: String
    let receiptUrl: String?
    let approvalStatus: String
    let submittedBy: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, description
        case companyId = "company_id"
        case projectId = "project_id"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case expenseDate = "expense_date"
        case paymentMethod = "payment_method"
        case receiptUrl = "receipt_url"
        case approvalStatus = "approval_status"
        case submittedBy = "submitted_by"
        case approvedBy = "approved_by"
    }
}

struct ExpenseCategory: Codable, Identifiable {
    let id: String
    let categoryName: String
    let categoryNameArabic: String
    let budgetLimit: String?
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryName = "category_name"
        case categoryNameArabic = "category_name_arabic"
        case budgetLimit = "budget_limit"
        case isActive = "is_active"
    }
}

struct BudgetAllocation: Codable, Identifiable {
    let id: String
    let projectId: String
    let categoryId: String
    let allocatedAmount: String
    let spentAmount: String
    let remainingAmount: String
    let period: String
    
    enum CodingKeys: String, CodingKey {
        case id, period
        case projectId = "project_id"
        case categoryId = "category_id"
        case allocatedAmount = "allocated_amount"
        case spentAmount = "spent_amount"
        case remainingAmount = "remaining_amount"
    }
}

struct ExpenseReport: Codable, Identifiable {
    let id: String
    let reportName: String
    let dateFrom: String
    let dateTo: String
    let totalExpenses: String
    let categorySummary: [CategoryExpense]?
    let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case reportName = "report_name"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case totalExpenses = "total_expenses"
        case categorySummary = "category_summary"
        case generatedAt = "generated_at"
    }
}

struct CategoryExpense: Codable, Identifiable {
    let id: String
    let categoryName: String
    let totalAmount: String
    let transactionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryName = "category_name"
        case totalAmount = "total_amount"
        case transactionCount = "transaction_count"
    }
}
