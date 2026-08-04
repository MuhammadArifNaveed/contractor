//
//  WorkshopPostViewModel.swift
//  TheContractor
//
//  ViewModel for Workshop Ad Posting matching Android WorkshopFragment
//

import SwiftUI
import SwiftyJSON

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

    /// `workshop/workshop_filter_data`, the same call the vendor Post Workshop screen makes. This used
    /// to post `Home/workshop_filter_api`, which 404s, and read the type/sector rows off a `name` key
    /// they do not have — the real rows are `{value, title}`, and the cities are `{id, name}`.
    func loadFilterData() {
        isLoadingFilters = true
        errorMessage = ""

        GCD.async(.Background) {
            LoginService.shared().getWorkshopFilterData { [weak self] message, success, json in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isLoadingFilters = false

                    guard success, let json = json else {
                        self.errorMessage = message.isEmpty ? "Failed to load filter data" : message
                        return
                    }

                    self.workshopTypes = [WorkshopFilterItem(id: "0", name: "Select Type")]
                        + json["workshop_type"].arrayValue.map {
                            WorkshopFilterItem(id: $0["value"].stringValue, name: $0["title"].stringValue)
                        }
                    self.workshopSectors = [WorkshopFilterItem(id: "0", name: "Select Sector")]
                        + json["work_sector"].arrayValue.map {
                            WorkshopFilterItem(id: $0["value"].stringValue, name: $0["title"].stringValue)
                        }
                    self.cities = [WorkshopFilterItem(id: "0", name: "Select City")]
                        + json["freelancer_cities"].arrayValue.map {
                            WorkshopFilterItem(id: $0["id"].stringValue, name: $0["name"].stringValue)
                        }
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

        guard let user = Global.shared.user, !user.id.isEmpty else {
            errorMessage = "User not logged in"
            isSubmitting = false
            return
        }

        // `workshop/submit_workshop_ad` is shared with the vendor side — `user_type` is what tells the
        // backend which one is posting. The previous call posted `Home/post_work_shop_ad_new_api`
        // (404) with base64 image strings and Android's part names spelled differently
        // (`ad_type`/`ad_sector`/`ad_city`/`detail`); Android sends repeated `images[]` file parts.
        let images = selectedImages.compactMap { $0.image.jpegData(compressionQuality: 0.7) }

        GCD.async(.Background) {
            LoginService.shared().submitWorkshopAd(vendorId: "",
                                                   userId: user.id,
                                                   userType: user.userType,
                                                   bidType: self.selectedTypeId,
                                                   workSector: self.selectedSectorId,
                                                   workCity: self.selectedCityId,
                                                   title: self.title,
                                                   description: self.details,
                                                   images: images) { [weak self] message, success in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isSubmitting = false
                    if success {
                        self.successMessage = message.isEmpty ? "Workshop ad submitted successfully" : message
                        self.showSuccessAlert = true
                        self.clearForm()
                    } else {
                        self.errorMessage = message.isEmpty ? "Failed to submit workshop ad" : message
                    }
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
