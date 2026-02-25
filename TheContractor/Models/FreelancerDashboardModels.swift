//
//  FreelancerDashboardModels.swift
//  TheContractor
//

import Foundation

struct FreelancerDashboardStats: Codable {
    let totalJobs: String
    let completedJobs: String
    let pendingJobs: String
    let totalEarnings: String
    let avgRating: String
    let totalReviews: String
    
    enum CodingKeys: String, CodingKey {
        case totalJobs = "total_jobs"
        case completedJobs = "completed_jobs"
        case pendingJobs = "pending_jobs"
        case totalEarnings = "total_earnings"
        case avgRating = "avg_rating"
        case totalReviews = "total_reviews"
    }
}

struct FreelancerJobItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let clientName: String
    let location: String
    let budget: String
    let startDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, budget, status
        case clientName = "client_name"
        case startDate = "start_date"
    }
}

struct FreelancerProfileUpdate {
    let userId: String
    let skills: [String]
    let experience: String
    let hourlyRate: String
    let availability: String
    let bio: String
    let portfolio: [Data]?
}
