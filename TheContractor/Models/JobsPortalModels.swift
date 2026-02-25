//
//  JobsPortalModels.swift
//  TheContractor
//

import Foundation

struct JobPosting: Codable, Identifiable {
    let id: String
    let companyId: String
    let companyName: String
    let companyLogo: String
    let title: String
    let description: String
    let categoryId: String
    let categoryName: String
    let location: String
    let city: String
    let jobType: String
    let experienceRequired: String
    let salary: String?
    let requirements: String
    let postedDate: String
    let expiryDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, city, requirements, salary, status
        case companyId = "company_id"
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case jobType = "job_type"
        case experienceRequired = "experience_required"
        case postedDate = "posted_date"
        case expiryDate = "expiry_date"
    }
}

struct JobApplication: Codable, Identifiable {
    let id: String
    let jobId: String
    let jobTitle: String
    let companyName: String
    let applicantName: String
    let applicantPhone: String
    let applicantEmail: String
    let resume: String?
    let coverLetter: String
    let status: String
    let appliedDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case jobId = "job_id"
        case jobTitle = "job_title"
        case companyName = "company_name"
        case applicantName = "applicant_name"
        case applicantPhone = "applicant_phone"
        case applicantEmail = "applicant_email"
        case resume
        case coverLetter = "cover_letter"
        case appliedDate = "applied_date"
    }
}

struct JobApplicationSubmission {
    let jobId: String
    let userId: String
    let name: String
    let phone: String
    let email: String
    let coverLetter: String
    let resumeData: Data?
}
