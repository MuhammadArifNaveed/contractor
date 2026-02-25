//
//  TrainingCenterModels.swift
//  TheContractor
//

import Foundation

struct TrainingCourse: Codable, Identifiable {
    let id: String
    let courseName: String
    let courseNameArabic: String
    let category: String
    let description: String
    let duration: String
    let level: String
    let instructor: String
    let capacity: Int
    let enrolledCount: Int
    let startDate: String
    let endDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, description, duration, level, instructor, capacity, status
        case courseName = "course_name"
        case courseNameArabic = "course_name_arabic"
        case enrolledCount = "enrolled_count"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct TrainingEnrollment: Codable, Identifiable {
    let id: String
    let courseId: String
    let courseName: String
    let userId: String
    let userName: String
    let enrolledAt: String
    let completionStatus: String
    let completionDate: String?
    let certificateUrl: String?
    let grade: String?
    
    enum CodingKeys: String, CodingKey {
        case id, grade
        case courseId = "course_id"
        case courseName = "course_name"
        case userId = "user_id"
        case userName = "user_name"
        case enrolledAt = "enrolled_at"
        case completionStatus = "completion_status"
        case completionDate = "completion_date"
        case certificateUrl = "certificate_url"
    }
}

struct TrainingModule: Codable, Identifiable {
    let id: String
    let courseId: String
    let moduleName: String
    let moduleOrder: Int
    let contentType: String
    let contentUrl: String?
    let duration: String
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, duration
        case courseId = "course_id"
        case moduleName = "module_name"
        case moduleOrder = "module_order"
        case contentType = "content_type"
        case contentUrl = "content_url"
        case isCompleted = "is_completed"
    }
}

struct TrainingAssessment: Codable, Identifiable {
    let id: String
    let courseId: String
    let userId: String
    let assessmentType: String
    let totalQuestions: Int
    let correctAnswers: Int
    let score: Double
    let passingScore: Double
    let isPassed: Bool
    let attemptedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, score
        case courseId = "course_id"
        case userId = "user_id"
        case assessmentType = "assessment_type"
        case totalQuestions = "total_questions"
        case correctAnswers = "correct_answers"
        case passingScore = "passing_score"
        case isPassed = "is_passed"
        case attemptedAt = "attempted_at"
    }
}

struct TrainingCertificate: Codable, Identifiable {
    let id: String
    let userId: String
    let courseId: String
    let courseName: String
    let certificateNumber: String
    let issuedDate: String
    let expiryDate: String?
    let certificateUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case courseName = "course_name"
        case certificateNumber = "certificate_number"
        case issuedDate = "issued_date"
        case expiryDate = "expiry_date"
        case certificateUrl = "certificate_url"
    }
}
