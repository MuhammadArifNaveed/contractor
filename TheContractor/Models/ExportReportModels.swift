//
//  ExportReportModels.swift
//  TheContractor
//

import Foundation

struct ExportRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let exportType: String
    let format: String
    let dateFrom: String
    let dateTo: String
    let filters: [String: String]?
    let status: String
    let fileUrl: String?
    let requestedAt: String
    let completedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, format, filters, status
        case userId = "user_id"
        case exportType = "export_type"
        case dateFrom = "date_from"
        case dateTo = "date_to"
        case fileUrl = "file_url"
        case requestedAt = "requested_at"
        case completedAt = "completed_at"
    }
}

struct ReportTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let nameArabic: String
    let reportType: String
    let description: String
    let availableFormats: [String]
    let fields: [String]
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, fields
        case nameArabic = "name_arabic"
        case reportType = "report_type"
        case availableFormats = "available_formats"
        case isActive = "is_active"
    }
}

struct DashboardReport: Codable {
    let reportType: String
    let generatedAt: String
    let dateRange: String
    let totalRevenue: String
    let totalEnquiries: Int
    let totalQuotations: Int
    let conversionRate: Double
    let topCategories: [CategoryStats]
    let trends: [TrendData]
    
    enum CodingKeys: String, CodingKey {
        case generatedAt, dateRange, conversionRate, trends
        case reportType = "report_type"
        case totalRevenue = "total_revenue"
        case totalEnquiries = "total_enquiries"
        case totalQuotations = "total_quotations"
        case topCategories = "top_categories"
    }
}

struct CategoryStats: Codable, Identifiable {
    let id: String
    let categoryName: String
    let count: Int
    let revenue: String
    let percentage: Double
    
    enum CodingKeys: String, CodingKey {
        case id, count, revenue, percentage
        case categoryName = "category_name"
    }
}

struct TrendData: Codable, Identifiable {
    let id: String
    let date: String
    let value: Double
    let metric: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, value, metric
    }
}
