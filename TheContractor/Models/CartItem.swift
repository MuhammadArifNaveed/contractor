//
//  CartItem.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation

/// Represents a company selected for enquiry cart
struct CartItem: Codable, Identifiable, Equatable {
    let id: String
    let companyName: String
    let companyArabicName: String
    let companyLogo: String
    let categoryName: String
    let categoryArabicName: String
    let reviewCount: String
    let avgRating: String
    let isVerified: String
    
    // Optional fields for location and description
    var dateTime: String?
    var location: String?
    var lat: String?
    var lng: String?
    var description: String?
    
    init(id: String,
         companyName: String,
         companyArabicName: String,
         companyLogo: String,
         categoryName: String,
         categoryArabicName: String,
         reviewCount: String,
         avgRating: String,
         isVerified: String,
         dateTime: String? = nil,
         location: String? = nil,
         lat: String? = nil,
         lng: String? = nil,
         description: String? = nil) {
        self.id = id
        self.companyName = companyName
        self.companyArabicName = companyArabicName
        self.companyLogo = companyLogo
        self.categoryName = categoryName
        self.categoryArabicName = categoryArabicName
        self.reviewCount = reviewCount
        self.avgRating = avgRating
        self.isVerified = isVerified
        self.dateTime = dateTime
        self.location = location
        self.lat = lat
        self.lng = lng
        self.description = description
    }
    
    // Equatable conformance
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Response model for cart limit API
struct CartLimitResponse: Codable {
    let cartLimit: Int
    let availableCartLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case cartLimit = "cart_limit"
        case availableCartLimit = "available_cart_limit"
    }
}
