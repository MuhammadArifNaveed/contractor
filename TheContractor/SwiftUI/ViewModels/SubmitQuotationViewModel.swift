//
//  SubmitQuotationViewModel.swift
//  TheContractor
//
//  ViewModel for submitting quotation requests (Quotation By Photo)
//

import SwiftUI
import Combine
import PhotosUI

// Category Model
struct CategoryModel: Identifiable, Codable {
    let id: String
    let name: String
    let nameAr: String
    var subCategories: [SubCategoryModel]
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case nameAr = "name_ar"
        case subCategories = "sub_categories"
    }
}

// SubCategory Model
struct SubCategoryModel: Identifiable, Codable {
    let id: String
    let name: String
    let nameAr: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case nameAr = "name_ar"
    }
}

class SubmitQuotationViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var selectedCategoryId: String = "0"
    @Published var selectedSubCategoryId: String = "0"
    @Published var currentSubCategories: [SubCategoryModel] = []
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var details = ""
    
    @Published var selectedImages: [UIImage] = []
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isSubmitting = false
    
    var isFormValid: Bool {
        selectedCategoryId != "0" &&
        selectedSubCategoryId != "0" &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !phone.isEmpty &&
        !email.isEmpty &&
        !details.isEmpty
    }
    
    func loadUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            firstName = user.name
            lastName = user.surname
            phone = user.phone
            // Email needs to be entered manually as it's not stored in UserViewModel
        }
    }
    
    func loadCategories() {
        isLoading = true
        errorMessage = ""
        
        LoginService.shared().getCategoriesWithSubCategories { [weak self] message, success, json in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let categoriesArray = json?["categories"].array, !categoriesArray.isEmpty {
                    self?.categories = categoriesArray.compactMap { categoryJson -> CategoryModel? in
                        let id = categoryJson["id"].stringValue
                        let name = categoryJson["name"].stringValue
                        let nameAr = categoryJson["arabic_name"].stringValue
                        guard !id.isEmpty else { return nil }
                        
                        let subCats: [SubCategoryModel] = categoryJson["sub_categories"].array?.compactMap { subJson -> SubCategoryModel? in
                            let subId = subJson["id"].stringValue
                            let subName = subJson["name"].stringValue
                            let subNameAr = subJson["arabic_name"].stringValue
                            guard !subId.isEmpty else { return nil }
                            return SubCategoryModel(id: subId, name: subName, nameAr: subNameAr)
                        } ?? []
                        
                        return CategoryModel(id: id, name: name, nameAr: nameAr, subCategories: subCats)
                    }
                } else {
                    self?.errorMessage = message
                }
            }
        }
    }
    
    func selectCategory(_ categoryId: String) {
        selectedCategoryId = categoryId
        selectedSubCategoryId = "0"
        
        if let category = categories.first(where: { $0.id == categoryId }) {
            currentSubCategories = category.subCategories
        } else {
            currentSubCategories = []
        }
    }
    
    func selectSubCategory(_ subCategoryId: String) {
        selectedSubCategoryId = subCategoryId
    }
    
    func submitQuotation(completion: @escaping (Bool, String) -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            completion(false, errorMessage)
            return
        }
        
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            completion(false, errorMessage)
            return
        }
        
        isSubmitting = true
        errorMessage = ""
        
        let imageDataArray: [Data]? = selectedImages.isEmpty ? nil :
            selectedImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
        
        LoginService.shared().requestQuotationByPhoto(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: email,
            detail: details,
            categoryId: selectedCategoryId,
            subCategoryId: selectedSubCategoryId,
            images: imageDataArray
        ) { [weak self] message, success in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                if success {
                    completion(true, message)
                } else {
                    self?.errorMessage = message
                    completion(false, message)
                }
            }
        }
    }
}
