//  WorkshopViewModel.swift
import SwiftUI

class WorkshopViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var items: [WorkshopItem] = []
    
    func loadItems() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_workshop_items", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["items"].array {
                    self?.items = arr.map { WorkshopItem(id: $0["id"].stringValue, title: $0["title"].stringValue, price: $0["price"].stringValue, image: $0["image"].stringValue) }
                }
            }
        }
    }
    
    func selectItem(_ item: WorkshopItem) { print("Selected: \(item.title)") }
}
