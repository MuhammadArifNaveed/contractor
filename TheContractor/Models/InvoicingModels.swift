//
//  InvoicingModels.swift
//  TheContractor
//

import Foundation

struct Invoice: Codable, Identifiable {
    let id: String
    let invoiceNumber: String
    let companyId: String
    let companyName: String
    let userId: String
    let userName: String
    let invoiceDate: String
    let dueDate: String
    let subtotal: String
    let taxAmount: String
    let discountAmount: String
    let totalAmount: String
    let status: String
    let paidAmount: String
    let balanceAmount: String
    let items: [InvoiceItem]?
    
    enum CodingKeys: String, CodingKey {
        case id, subtotal, status, items
        case invoiceNumber = "invoice_number"
        case companyId = "company_id"
        case companyName = "company_name"
        case userId = "user_id"
        case userName = "user_name"
        case invoiceDate = "invoice_date"
        case dueDate = "due_date"
        case taxAmount = "tax_amount"
        case discountAmount = "discount_amount"
        case totalAmount = "total_amount"
        case paidAmount = "paid_amount"
        case balanceAmount = "balance_amount"
    }
}

struct InvoiceItem: Codable, Identifiable {
    let id: String
    let description: String
    let quantity: Double
    let unitPrice: String
    let totalPrice: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, quantity
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
    }
}

struct InvoicePayment: Codable, Identifiable {
    let id: String
    let invoiceId: String
    let amount: String
    let paymentMethod: String
    let paymentDate: String
    let transactionId: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, notes
        case invoiceId = "invoice_id"
        case paymentMethod = "payment_method"
        case paymentDate = "payment_date"
        case transactionId = "transaction_id"
    }
}

struct PaymentReminder: Codable, Identifiable {
    let id: String
    let invoiceId: String
    let reminderDate: String
    let sentAt: String?
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, status
        case invoiceId = "invoice_id"
        case reminderDate = "reminder_date"
        case sentAt = "sent_at"
    }
}
