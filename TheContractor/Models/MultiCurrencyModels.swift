//
//  MultiCurrencyModels.swift
//  TheContractor
//

import Foundation

struct Currency: Codable, Identifiable {
    let id: String
    let code: String
    let name: String
    let nameArabic: String
    let symbol: String
    let exchangeRate: Double
    let isActive: Bool
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, code, name, symbol
        case nameArabic = "name_arabic"
        case exchangeRate = "exchange_rate"
        case isActive = "is_active"
        case isDefault = "is_default"
    }
}

struct PriceInCurrency: Codable {
    let amount: String
    let currencyCode: String
    let currencySymbol: String
    let convertedAmount: String?
    let userCurrency: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case convertedAmount = "converted_amount"
        case userCurrency = "user_currency"
    }
}

struct ExchangeRate: Codable, Identifiable {
    let id: String
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, rate
        case fromCurrency = "from_currency"
        case toCurrency = "to_currency"
        case lastUpdated = "last_updated"
    }
}

struct UserCurrencyPreference: Codable {
    let userId: String
    let preferredCurrency: String
    let autoConvert: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case preferredCurrency = "preferred_currency"
        case autoConvert = "auto_convert"
    }
}
