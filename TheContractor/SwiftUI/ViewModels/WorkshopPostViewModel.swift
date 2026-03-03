//
//  WorkshopPostViewModel.swift
//  TheContractor
//
//  ViewModel for Workshop Ad Posting matching Android WorkshopFragment
//

import SwiftUI

class WorkshopPostViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoadingFilters = false
    @Published var isSubmitting = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var showSuccessAlert = false
    @Published var showImagePicker = false
    
    // Form Fields
    @Published var selectedTypeId = "0"
    @Published var selectedSectorId = "0"
    @Published var selectedCityId = "0"
    @Published var title = ""
    @Published var details = ""
    @Published var selectedImages: [SelectedImage] = []
    
    // Filter Data
    @Published var workshopTypes: [WorkshopFilterItem] = []
    @Published var workshopSectors: [WorkshopFilterItem] = []
    @Published var cities: [WorkshopFilterItem] = []
    
    // Validation
    var isFormValid: Bool {
        selectedTypeId != "0" &&
        selectedSectorId != "0" &&
        selectedCityId != "0" &&
        !title.isEmpty &&
        !details.isEmpty
    }
    
    // MARK: - Load Filter Data
    func loadFilterData() {
        isLoadingFilters = true
        errorMessage = ""
        
        let url = "\(EndPoints.BASE_URL)Home/workshop_filter_api"
        
        LoginService.shared().makePostAPICall(with: url, params: [:]) { [weak self] message, success, json, error in
            DispatchQueue.main.async {
                self?.isLoadingFilters = false
                
                if success, let json = json {
                    // Parse workshop types
                    if let typesArray = json["workshop_type"].array {
                        var types = [WorkshopFilterItem(id: "0", name: "Select Type")]
                        types.append(contentsOf: typesArray.compactMap { item in
                            guard let id = item["value"].string, let name = item["name"].string else { return nil }
                            return WorkshopFilterItem(id: id, name: name)
                        })
                        self?.workshopTypes = types
                    }
                    
                    // Parse work sectors
                    if let sectorsArray = json["work_sector"].array {
                        var sectors = [WorkshopFilterItem(id: "0", name: "Select Sector")]
                        sectors.append(contentsOf: sectorsArray.compactMap { item in
                            guard let id = item["value"].string, let name = item["name"].string else { return nil }
                            return WorkshopFilterItem(id: id, name: name)
                        })
                        self?.workshopSectors = sectors
                    }
                    
                    // Parse cities
                    if let citiesArray = json["freelancer_cities"].array {
                        var cityList = [WorkshopFilterItem(id: "0", name: "Select City")]
                        cityList.append(contentsOf: citiesArray.compactMap { item in
                            guard let id = item["id"].string, let name = item["name"].string else { return nil }
                            return WorkshopFilterItem(id: id, name: name)
                        })
                        self?.cities = cityList
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load filter data"
                }
            }
        }
    }
    
    // MARK: - Submit Workshop Ad
    func submitWorkshopAd() {
        guard isFormValid else {
            if selectedTypeId == "0" {
                errorMessage = "Please Select Type"
            } else if selectedSectorId == "0" {
                errorMessage = "Please Select Sector"
            } else if selectedCityId == "0" {
                errorMessage = "Please Select City"
            } else if title.isEmpty {
                errorMessage = "Enter Title"
            } else if details.isEmpty {
                errorMessage = "Enter Description"
            }
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        
        // Get user data
        guard let userId = Global.shared.user?.id,
              let userType = Global.shared.user?.userType else {
            errorMessage = "User not logged in"
            isSubmitting = false
            return
        }
        
        let url = "\(EndPoints.BASE_URL)Home/post_work_shop_ad_new_api"
        
        // Prepare parameters
        var params: [String: Any] = [
            "user_id": userId,
            "user_type": userType,
            "ad_type": selectedTypeId,
            "ad_sector": selectedSectorId,
            "ad_city": selectedCityId,
            "title": title,
            "detail": details
        ]
        
        // Convert images to base64 if any
        if !selectedImages.isEmpty {
            var imageStrings: [String] = []
            for selectedImage in selectedImages {
                if let imageData = selectedImage.image.jpegData(compressionQuality: 0.7) {
                    let base64String = imageData.base64EncodedString()
                    imageStrings.append(base64String)
                }
            }
            params["images"] = imageStrings
        }
        
        LoginService.shared().makePostAPICall(with: url, params: params) { [weak self] message, success, json, error in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                if success {
                    self?.successMessage = message ?? "Workshop ad submitted successfully"
                    self?.showSuccessAlert = true
                    self?.clearForm()
                } else {
                    self?.errorMessage = message ?? "Failed to submit workshop ad"
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    private func clearForm() {
        selectedTypeId = "0"
        selectedSectorId = "0"
        selectedCityId = "0"
        title = ""
        details = ""
        selectedImages.removeAll()
    }
}

// MARK: - Models
struct WorkshopFilterItem: Identifiable {
    let id: String
    let name: String
}
