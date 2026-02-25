//
//  TenderManagementModels.swift
//  TheContractor
//

import Foundation

struct Tender: Codable, Identifiable {
    let id: String
    let organizationId: String
    let organizationName: String
    let tenderNumber: String
    let title: String
    let titleArabic: String
    let description: String
    let categoryId: String
    let estimatedValue: String
    let publishDate: String
    let closingDate: String
    let location: String
    let requirements: [String]
    let documents: [String]?
    let status: String
    let viewsCount: Int
    let bidsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, requirements, documents, status
        case organizationId = "organization_id"
        case organizationName = "organization_name"
        case tenderNumber = "tender_number"
        case titleArabic = "title_arabic"
        case categoryId = "category_id"
        case estimatedValue = "estimated_value"
        case publishDate = "publish_date"
        case closingDate = "closing_date"
        case viewsCount = "views_count"
        case bidsCount = "bids_count"
    }
}

struct TenderBid: Codable, Identifiable {
    let id: String
    let tenderId: String
    let companyId: String
    let companyName: String
    let bidAmount: String
    let proposedTimeline: String
    let technicalProposal: String
    let financialProposal: String
    let documents: [String]?
    let status: String
    let submittedAt: String
    let evaluationScore: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, status, documents
        case tenderId = "tender_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case bidAmount = "bid_amount"
        case proposedTimeline = "proposed_timeline"
        case technicalProposal = "technical_proposal"
        case financialProposal = "financial_proposal"
        case submittedAt = "submitted_at"
        case evaluationScore = "evaluation_score"
    }
}

struct TenderEvaluation: Codable, Identifiable {
    let id: String
    let tenderId: String
    let bidId: String
    let evaluatorId: String
    let technicalScore: Double
    let financialScore: Double
    let complianceScore: Double
    let totalScore: Double
    let comments: String
    let recommendation: String
    let evaluatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, comments, recommendation
        case tenderId = "tender_id"
        case bidId = "bid_id"
        case evaluatorId = "evaluator_id"
        case technicalScore = "technical_score"
        case financialScore = "financial_score"
        case complianceScore = "compliance_score"
        case totalScore = "total_score"
        case evaluatedAt = "evaluated_at"
    }
}

struct TenderAward: Codable, Identifiable {
    let id: String
    let tenderId: String
    let winningBidId: String
    let companyId: String
    let companyName: String
    let awardedAmount: String
    let contractDuration: String
    let awardedAt: String
    let contractStartDate: String
    let contractEndDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case tenderId = "tender_id"
        case winningBidId = "winning_bid_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case awardedAmount = "awarded_amount"
        case contractDuration = "contract_duration"
        case awardedAt = "awarded_at"
        case contractStartDate = "contract_start_date"
        case contractEndDate = "contract_end_date"
    }
}
