//
//  SearchCompaniesViewModel.swift
//  TheContractor
//
//  ViewModel for SwiftUI Search screen
//

import SwiftUI
import Combine
import SwiftyJSON

struct SpecialityItem: Identifiable {
    let id: String
    let title: String
}

class SearchCompaniesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var specialities: [SpecialityItem] = []
    @Published var categories: [CategoryViewModel] = []
    @Published var subCategories: [SubCategoryViewModel] = []
    @Published var cities: [CityViewModel] = []

    @Published var selectedCategoryId: String = ""
    @Published var selectedSubCategoryIds: Set<String> = []
    @Published var selectedCityId: String = ""
    @Published var selectedSpecialityIds: Set<String> = []

    func loadSearchData() {
        isLoading = true
        errorMessage = nil

        let completeURL = EndPoints.BASE_URL + EndPoints.getSearch
        LoginService.shared().makeGetAPICall(with: completeURL, params: [:]) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let json = json {
                    // Parse specialities
                    let specs = json["specialities"].arrayValue.map {
                        SpecialityItem(id: $0["id"].stringValue,
                                       title: $0["speciality_title"].stringValue)
                    }
                    self?.specialities = specs

                    let categoryList = CategoryListViewModel(list: json["categories"])
                    self?.categories = categoryList.categoryList

                    if let firstCategory = categoryList.categoryList.first {
                        self?.selectedCategoryId = firstCategory.id
                        self?.subCategories = firstCategory.sub_categories.subCategoryList
                    }

                    let cityList = CitiesListViewModel(list: json["cities"])
                    self?.cities = cityList.cityList
                } else {
                    self?.errorMessage = message ?? "Failed to load search data"
                }
            }
        }
    }

    func selectCategory(_ category: CategoryViewModel) {
        selectedCategoryId = category.id
        subCategories = category.sub_categories.subCategoryList
        selectedSubCategoryIds.removeAll()
    }

    func toggleSubCategory(_ subCategory: SubCategoryViewModel) {
        if selectedSubCategoryIds.contains(subCategory.id) {
            selectedSubCategoryIds.remove(subCategory.id)
        } else {
            selectedSubCategoryIds.insert(subCategory.id)
        }
    }

    func selectCity(_ city: CityViewModel) {
        selectedCityId = city.id
    }

    func toggleSpeciality(_ item: SpecialityItem) {
        if selectedSpecialityIds.contains(item.id) {
            selectedSpecialityIds.remove(item.id)
        } else {
            selectedSpecialityIds.insert(item.id)
        }
    }
}
