//
//  AuditLogModels.swift
//  TheContractor
//

import Foundation

struct AuditLog: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let action: String
    let entityType: String
    let entityId: String
    let changes: String?
    let ipAddress: String
    let userAgent: String?
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, action, changes, timestamp
        case userId = "user_id"
        case userName = "user_name"
        case entityType = "entity_type"
        case entityId = "entity_id"
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
    }
}

struct SecurityEvent: Codable, Identifiable {
    let id: String
    let eventType: String
    let severity: String
    let userId: String?
    let ipAddress: String
    let description: String
    let detectedAt: String
    let resolved: Bool
    let resolvedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, severity, description, resolved
        case eventType = "event_type"
        case userId = "user_id"
        case ipAddress = "ip_address"
        case detectedAt = "detected_at"
        case resolvedAt = "resolved_at"
    }
}

struct DataChange: Codable, Identifiable {
    let id: String
    let auditLogId: String
    let fieldName: String
    let oldValue: String?
    let newValue: String?
    let changedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case auditLogId = "audit_log_id"
        case fieldName = "field_name"
        case oldValue = "old_value"
        case newValue = "new_value"
        case changedAt = "changed_at"
    }
}

struct ComplianceReport: Codable, Identifiable {
    let id: String
    let reportType: String
    let period: String
    let generatedBy: String
    let totalActions: Int
    let suspiciousActions: Int
    let failedLogins: Int
    let dataModifications: Int
    let generatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, period
        case reportType = "report_type"
        case generatedBy = "generated_by"
        case totalActions = "total_actions"
        case suspiciousActions = "suspicious_actions"
        case failedLogins = "failed_logins"
        case dataModifications = "data_modifications"
        case generatedAt = "generated_at"
    }
}
