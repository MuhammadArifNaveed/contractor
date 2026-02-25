//
//  MaterialProcurementModels.swift
//  TheContractor
//

import Foundation

struct Material: Codable, Identifiable {
    let id: String
    let materialName: String
    let materialNameArabic: String
    let category: String
    let unit: String
    let standardPrice: String
    let supplierId: String?
    let supplierName: String?
    let specifications: String
    
    enum CodingKeys: String, CodingKey {
        case id, category, unit, specifications
        case materialName = "material_name"
        case materialNameArabic = "material_name_arabic"
        case standardPrice = "standard_price"
        case supplierId = "supplier_id"
        case supplierName = "supplier_name"
    }
}

struct ProcurementRequest: Codable, Identifiable {
    let id: String
    let projectId: String
    let projectName: String
    let requestedBy: String
    let requestDate: String
    let requiredDate: String
    let items: [ProcurementItem]?
    let totalAmount: String
    let status: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, items, status
        case projectId = "project_id"
        case projectName = "project_name"
        case requestedBy = "requested_by"
        case requestDate = "request_date"
        case requiredDate = "required_date"
        case totalAmount = "total_amount"
        case approvedBy = "approved_by"
    }
}

struct ProcurementItem: Codable, Identifiable {
    let id: String
    let materialId: String
    let materialName: String
    let quantity: String
    let unit: String
    let estimatedPrice: String
    let actualPrice: String?
    let supplierId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, unit
        case materialId = "material_id"
        case materialName = "material_name"
        case estimatedPrice = "estimated_price"
        case actualPrice = "actual_price"
        case supplierId = "supplier_id"
    }
}

struct Supplier: Codable, Identifiable {
    let id: String
    let companyName: String
    let contactPerson: String
    let phone: String
    let email: String
    let address: String
    let city: String
    let rating: Double
    let isVerified: Bool
    let specialization: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, phone, email, address, city, rating, specialization
        case companyName = "company_name"
        case contactPerson = "contact_person"
        case isVerified = "is_verified"
    }
}

struct PurchaseOrder: Codable, Identifiable {
    let id: String
    let procurementRequestId: String
    let supplierId: String
    let supplierName: String
    let orderDate: String
    let deliveryDate: String
    let totalAmount: String
    let paymentTerms: String
    let status: String
    let deliveryStatus: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case procurementRequestId = "procurement_request_id"
        case supplierId = "supplier_id"
        case supplierName = "supplier_name"
        case orderDate = "order_date"
        case deliveryDate = "delivery_date"
        case totalAmount = "total_amount"
        case paymentTerms = "payment_terms"
        case deliveryStatus = "delivery_status"
    }
}
