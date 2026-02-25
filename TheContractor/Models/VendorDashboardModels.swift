//
//  VendorDashboardModels.swift
//  TheContractor
//

import Foundation

struct VendorDashboardStats: Codable {
    let totalEnquiries: String
    let pendingEnquiries: String
    let totalQuotations: String
    let acceptedQuotations: String
    let totalWorkshops: String
    let activeWorkshops: String
    let totalReviews: String
    let averageRating: String
    
    enum CodingKeys: String, CodingKey {
        case totalEnquiries = "total_enquiries"
        case pendingEnquiries = "pending_enquiries"
        case totalQuotations = "total_quotations"
        case acceptedQuotations = "accepted_quotations"
        case totalWorkshops = "total_workshops"
        case activeWorkshops = "active_workshops"
        case totalReviews = "total_reviews"
        case averageRating = "average_rating"
    }
}

struct VendorEnquiryItem: Codable, Identifiable {
    let id: String
    let userName: String
    let userPhone: String
    let userEmail: String
    let description: String
    let location: String
    let dateTime: String
    let status: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, location, status
        case userName = "user_name"
        case userPhone = "user_phone"
        case userEmail = "user_email"
        case dateTime = "date_time"
        case createdAt = "created_at"
    }
}

struct VendorQuotationItem: Codable, Identifiable {
    let id: String
    let userName: String
    let description: String
    let amount: String?
    let status: String
    let submittedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, description, amount, status
        case userName = "user_name"
        case submittedAt = "submitted_at"
    }
}

struct VendorQuotationSubmission {
    let quotationId: String
    let amount: String
    let notes: String
    let validUntil: String
}
