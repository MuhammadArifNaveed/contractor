//
//  IntegrationModels.swift
//  TheContractor
//

import Foundation

struct ThirdPartyIntegration: Codable, Identifiable {
    let id: String
    let integrationName: String
    let integrationType: String
    let isEnabled: Bool
    let apiKey: String?
    let webhookUrl: String?
    let lastSynced: String?
    let syncStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case integrationName = "integration_name"
        case integrationType = "integration_type"
        case isEnabled = "is_enabled"
        case apiKey = "api_key"
        case webhookUrl = "webhook_url"
        case lastSynced = "last_synced"
        case syncStatus = "sync_status"
    }
}

struct WebhookEvent: Codable, Identifiable {
    let id: String
    let eventType: String
    let payload: String
    let triggeredAt: String
    let status: String
    let response: String?
    let retryCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, payload, status, response
        case eventType = "event_type"
        case triggeredAt = "triggered_at"
        case retryCount = "retry_count"
    }
}

struct APILog: Codable, Identifiable {
    let id: String
    let endpoint: String
    let method: String
    let requestData: String?
    let responseData: String?
    let statusCode: Int
    let duration: Double
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id, endpoint, method, duration, timestamp
        case requestData = "request_data"
        case responseData = "response_data"
        case statusCode = "status_code"
    }
}
