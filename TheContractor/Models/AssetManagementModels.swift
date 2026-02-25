//
//  AssetManagementModels.swift
//  TheContractor
//

import Foundation

struct Asset: Codable, Identifiable {
    let id: String
    let companyId: String
    let assetName: String
    let assetType: String
    let assetCode: String
    let category: String
    let purchaseDate: String
    let purchasePrice: String
    let currentValue: String
    let condition: String
    let location: String
    let assignedTo: String?
    let status: String
    let warrantyExpiry: String?
    
    enum CodingKeys: String, CodingKey {
        case id, category, condition, location, status
        case companyId = "company_id"
        case assetName = "asset_name"
        case assetType = "asset_type"
        case assetCode = "asset_code"
        case purchaseDate = "purchase_date"
        case purchasePrice = "purchase_price"
        case currentValue = "current_value"
        case assignedTo = "assigned_to"
        case warrantyExpiry = "warranty_expiry"
    }
}

struct AssetDepreciation: Codable, Identifiable {
    let id: String
    let assetId: String
    let year: String
    let depreciationRate: Double
    let depreciationAmount: String
    let bookValue: String
    let calculatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, year
        case assetId = "asset_id"
        case depreciationRate = "depreciation_rate"
        case depreciationAmount = "depreciation_amount"
        case bookValue = "book_value"
        case calculatedAt = "calculated_at"
    }
}

struct AssetTransfer: Codable, Identifiable {
    let id: String
    let assetId: String
    let assetName: String
    let fromLocation: String
    let toLocation: String
    let transferredBy: String
    let transferDate: String
    let reason: String
    let status: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, reason, status
        case assetId = "asset_id"
        case assetName = "asset_name"
        case fromLocation = "from_location"
        case toLocation = "to_location"
        case transferredBy = "transferred_by"
        case transferDate = "transfer_date"
        case approvedBy = "approved_by"
    }
}

struct AssetAudit: Codable, Identifiable {
    let id: String
    let auditDate: String
    let auditorName: String
    let totalAssets: Int
    let verifiedAssets: Int
    let missingAssets: Int
    let damagedAssets: Int
    let status: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case auditDate = "audit_date"
        case auditorName = "auditor_name"
        case totalAssets = "total_assets"
        case verifiedAssets = "verified_assets"
        case missingAssets = "missing_assets"
        case damagedAssets = "damaged_assets"
    }
}

struct AssetDisposal: Codable, Identifiable {
    let id: String
    let assetId: String
    let assetName: String
    let disposalDate: String
    let disposalMethod: String
    let disposalValue: String?
    let reason: String
    let approvedBy: String
    let documentUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, reason
        case assetId = "asset_id"
        case assetName = "asset_name"
        case disposalDate = "disposal_date"
        case disposalMethod = "disposal_method"
        case disposalValue = "disposal_value"
        case approvedBy = "approved_by"
        case documentUrl = "document_url"
    }
}
