//
//  QRCodeModels.swift
//  TheContractor
//

import Foundation

struct QRCode: Codable, Identifiable {
    let id: String
    let companyId: String
    let qrType: String
    let qrData: String
    let qrImageUrl: String
    let isActive: Bool
    let scansCount: Int
    let createdAt: String
    let expiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyId = "company_id"
        case qrType = "qr_type"
        case qrData = "qr_data"
        case qrImageUrl = "qr_image_url"
        case isActive = "is_active"
        case scansCount = "scans_count"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct QRScanResult: Codable {
    let qrId: String
    let companyId: String
    let companyName: String
    let qrType: String
    let data: [String: String]
    let actionType: String
    let actionUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case qrId = "qr_id"
        case companyId = "company_id"
        case companyName = "company_name"
        case qrType = "qr_type"
        case actionType = "action_type"
        case actionUrl = "action_url"
    }
}

struct QRCodeGeneration {
    let companyId: String
    let qrType: String
    let data: [String: String]
    let expiryHours: String?
}

struct QRScanLog: Codable, Identifiable {
    let id: String
    let qrId: String
    let userId: String?
    let scannedAt: String
    let latitude: String?
    let longitude: String?
    let deviceInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case id, latitude, longitude
        case qrId = "qr_id"
        case userId = "user_id"
        case scannedAt = "scanned_at"
        case deviceInfo = "device_info"
    }
}
