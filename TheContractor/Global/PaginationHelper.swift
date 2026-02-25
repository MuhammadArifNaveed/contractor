//
//  PaginationHelper.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import Combine

/// A generic pagination helper for managing paginated data in SwiftUI lists
class PaginationHelper<T>: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All loaded items
    @Published var items: [T] = []
    
    /// Current page number (1-based)
    @Published var currentPage: Int = 1
    
    /// Whether currently loading data
    @Published var isLoading: Bool = false
    
    /// Whether there are more pages available
    @Published var hasMorePages: Bool = true
    
    /// Error message if loading failed
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    
    private var totalPages: Int = 1
    private let pageSize: Int
    
    // MARK: - Initialization
    
    /// Initialize pagination helper
    /// - Parameter pageSize: Number of items per page (default: 20)
    init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    // MARK: - Public Methods
    
    /// Reset pagination to initial state
    func reset() {
        items.removeAll()
        currentPage = 1
        isLoading = false
        hasMorePages = true
        errorMessage = nil
        totalPages = 1
    }
    
    /// Load the first page
    /// - Parameter loader: Async function that loads data for a given page
    func loadFirstPage(loader: @escaping (Int) async throws -> PaginatedResponse<T>) async {
        reset()
        await loadPage(loader: loader)
    }
    
    /// Load next page if available
    /// - Parameter loader: Async function that loads data for a given page
    func loadNextPageIfNeeded(loader: @escaping (Int) async throws -> PaginatedResponse<T>) async {
        guard !isLoading && hasMorePages else { return }
        await loadPage(loader: loader)
    }
    
    /// Check if we should load more items when user reaches a specific item
    /// - Parameters:
    ///   - item: The current item being displayed
    ///   - threshold: How many items from the end to trigger loading (default: 5)
    ///   - loader: Async function that loads data for a given page
    func loadMoreIfNeeded(currentItem item: T?, threshold: Int = 5, loader: @escaping (Int) async throws -> PaginatedResponse<T>) async where T: Identifiable {
        guard let item = item else { return }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -threshold)
        if let itemIndex = items.firstIndex(where: { ($0 as? any Identifiable)?.id as? AnyHashable == (item as? any Identifiable)?.id as? AnyHashable }),
           itemIndex >= thresholdIndex {
            await loadNextPageIfNeeded(loader: loader)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadPage(loader: @escaping (Int) async throws -> PaginatedResponse<T>) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await loader(currentPage)
            
            await MainActor.run {
                // Append new items
                items.append(contentsOf: response.items)
                
                // Update pagination state
                totalPages = response.totalPages
                hasMorePages = currentPage < totalPages
                
                // Increment page for next load
                if hasMorePages {
                    currentPage += 1
                }
                
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Paginated Response Model

/// Response structure for paginated API calls
struct PaginatedResponse<T> {
    let items: [T]
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    
    /// Initialize from API response
    /// - Parameters:
    ///   - items: Array of items for current page
    ///   - currentPage: Current page number (1-based)
    ///   - totalPages: Total number of pages
    ///   - totalItems: Total number of items across all pages
    init(items: [T], currentPage: Int, totalPages: Int, totalItems: Int) {
        self.items = items
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalItems = totalItems
    }
    
    /// Convenience initializer when totalPages is calculated from count
    /// - Parameters:
    ///   - items: Array of items for current page
    ///   - currentPage: Current page number (1-based)
    ///   - totalItems: Total number of items
    ///   - pageSize: Items per page
    init(items: [T], currentPage: Int, totalItems: Int, pageSize: Int = 20) {
        self.items = items
        self.currentPage = currentPage
        self.totalItems = totalItems
        self.totalPages = totalItems > 0 ? Int(ceil(Double(totalItems) / Double(pageSize))) : 1
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

extension View {
    /// Triggers pagination when this view appears and is near the end of the list
    /// - Parameters:
    ///   - item: The current item
    ///   - threshold: Number of items from end to trigger (default: 5)
    ///   - pagination: The pagination helper
    ///   - loader: The async loader function
    func onAppearLoadMore<T>(
        item: T?,
        threshold: Int = 5,
        pagination: PaginationHelper<T>,
        loader: @escaping (Int) async throws -> PaginatedResponse<T>
    ) -> some View where T: Identifiable {
        self.task {
            await pagination.loadMoreIfNeeded(currentItem: item, threshold: threshold, loader: loader)
        }
    }
}
