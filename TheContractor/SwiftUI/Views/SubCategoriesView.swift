//  SubCategoriesView.swift
import SwiftUI

struct SubCategoriesView: View {
    let category: CategoryViewModel
    @StateObject private var viewModel: SubCategoriesViewModel
    
    init(category: CategoryViewModel) {
        self.category = category
        _viewModel = StateObject(wrappedValue: SubCategoriesViewModel(category: category))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.subCategories.indices, id: \.self) { i in
                    SubCategoryCard(subCategory: viewModel.subCategories[i]) {
                        viewModel.selectSubCategory(viewModel.subCategories[i])
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(category.name)
        .onAppear { viewModel.loadSubCategories() }
    }
}

struct SubCategoryCard: View {
    let subCategory: SubCategoryViewModel
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                AsyncImage(url: URL(string: subCategory.icon)) { img in img.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                    .frame(height: 100)
                    .cornerRadius(8)
                Text(subCategory.name).font(AppTheme.Fonts.semibold(14)).lineLimit(2).multilineTextAlignment(.center)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}
