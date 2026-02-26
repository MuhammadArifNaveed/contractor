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
                    Button(action: { viewModel.selectSubCategory(viewModel.subCategories[i]) }) {
                        VStack(spacing: 8) {
                            Circle().fill(AppTheme.Colors.primary.opacity(0.2)).frame(height: 100)
                                .overlay(Image(systemName: "tag").font(.system(size: 40)).foregroundColor(AppTheme.Colors.primary))
                            Text(viewModel.subCategories[i].name).font(AppTheme.Fonts.semibold(14)).lineLimit(2).multilineTextAlignment(.center)
                        }
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(category.name)
        .onAppear { viewModel.loadSubCategories() }
    }
}
