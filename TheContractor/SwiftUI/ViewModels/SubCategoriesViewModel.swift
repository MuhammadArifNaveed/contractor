//  SubCategoriesViewModel.swift
import SwiftUI

class SubCategoriesViewModel: ObservableObject {
    let category: CategoryViewModel
    @Published var subCategories: [SubCategoryViewModel] = []
    
    init(category: CategoryViewModel) {
        self.category = category
    }
    
    func loadSubCategories() {
        subCategories = category.sub_categories.subCategoryList
    }
    
    func selectSubCategory(_ sub: SubCategoryViewModel) {
        print("Selected: \(sub.name)")
    }
}
