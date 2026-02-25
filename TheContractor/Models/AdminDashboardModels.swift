//
//  AdminDashboardModels.swift
//  TheContractor
//

import Foundation

struct AdminDashboardStats: Codable {
    let totalUsers: Int
    let totalCompanies: Int
    let totalEnquiries: Int
    let totalRevenue: String
    let activeSubscriptions: Int
    let pendingApprovals: Int
    let todayRegistrations: Int
    let monthlyGrowth: Double
    
    enum CodingKeys: String, CodingKey {
        case totalUsers = "total_users"
        case totalCompanies = "total_companies"
        case totalEnquiries = "total_enquiries"
        case totalRevenue = "total_revenue"
        case activeSubscriptions = "active_subscriptions"
        case pendingApprovals = "pending_approvals"
        case todayRegistrations = "today_registrations"
        case monthlyGrowth = "monthly_growth"
    }
}

struct UserActivity: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let activityType: String
    let description: String
    let ipAddress: String?
    let deviceInfo: String?
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, timestamp
        case userId = "user_id"
        case userName = "user_name"
        case activityType = "activity_type"
        case ipAddress = "ip_address"
        case deviceInfo = "device_info"
    }
}

struct PendingApproval: Codable, Identifiable {
    let id: String
    let itemType: String
    let itemId: String
    let companyId: String?
    let companyName: String?
    let title: String
    let description: String
    let submittedBy: String
    let submittedAt: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, status
        case itemType = "item_type"
        case itemId = "item_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case submittedBy = "submitted_by"
        case submittedAt = "submitted_at"
    }
}

struct SystemHealthMetric: Codable, Identifiable {
    let id: String
    let metricName: String
    let value: Double
    let unit: String
    let status: String
    let threshold: Double
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, value, unit, status, threshold, timestamp
        case metricName = "metric_name"
    }
}

struct RevenueMetrics: Codable {
    let totalRevenue: String
    let subscriptionRevenue: String
    let commissionRevenue: String
    let monthlyRecurring: String
    let growthRate: Double
    let topCategories: [CategoryRevenue]
    
    enum CodingKeys: String, CodingKey {
        case growthRate, topCategories
        case totalRevenue = "total_revenue"
        case subscriptionRevenue = "subscription_revenue"
        case commissionRevenue = "commission_revenue"
        case monthlyRecurring = "monthly_recurring"
    }
}

struct CategoryRevenue: Codable, Identifiable {
    let id: String
    let categoryName: String
    let revenue: String
    let percentage: Double
    
    enum CodingKeys: String, CodingKey {
        case id, revenue, percentage
        case categoryName = "category_name"
    }
}
