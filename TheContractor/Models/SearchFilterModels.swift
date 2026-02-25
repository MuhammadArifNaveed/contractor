//
//  SearchFilterModels.swift
//  TheContractor
//

import Foundation

struct CompanySearchFilters {
    var categoryId: String?
    var subCategoryId: String?
    var cityId: String?
    var searchQuery: String?
    var isVerified: Bool?
    var minRating: Double?
    var pageNo: Int = 1
    
    func toParams() -> [String: String] {
        var params: [String: String] = ["page_no": "\(pageNo)"]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        if let subCategoryId = subCategoryId { params["sub_category_id"] = subCategoryId }
        if let cityId = cityId { params["city_id"] = cityId }
        if let searchQuery = searchQuery, !searchQuery.isEmpty { params["search"] = searchQuery }
        if let isVerified = isVerified { params["is_verified"] = isVerified ? "1" : "0" }
        if let minRating = minRating { params["min_rating"] = "\(minRating)" }
        return params
    }
}

struct FreelancerSearchFilters {
    var categoryId: String?
    var cityId: String?
    var searchQuery: String?
    var minRating: Double?
    var pageNo: Int = 1
    
    func toParams() -> [String: String] {
        var params: [String: String] = ["page_no": "\(pageNo)"]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        if let cityId = cityId { params["city_id"] = cityId }
        if let searchQuery = searchQuery, !searchQuery.isEmpty { params["search"] = searchQuery }
        if let minRating = minRating { params["min_rating"] = "\(minRating)" }
        return params
    }
}

struct WorkshopSearchFilters {
    var categoryId: String?
    var cityId: String?
    var searchQuery: String?
    var dateFrom: String?
    var dateTo: String?
    var pageNo: Int = 1
    
    func toParams() -> [String: String] {
        var params: [String: String] = ["page_no": "\(pageNo)"]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        if let cityId = cityId { params["city_id"] = cityId }
        if let searchQuery = searchQuery, !searchQuery.isEmpty { params["search"] = searchQuery }
        if let dateFrom = dateFrom { params["date_from"] = dateFrom }
        if let dateTo = dateTo { params["date_to"] = dateTo }
        return params
    }
}
