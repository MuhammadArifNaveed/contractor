//
//  CategoryCard.swift
//  TheContractor
//
//  Reusable category card component matching Android design
//

import SwiftUI

struct CategoryCard: View {
    let category: CategoryViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.Spacing.small) {
                AsyncImage(url: URL(string: category.icon)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "square.grid.2x2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(AppTheme.Colors.gray)
                        .padding(20)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppTheme.Colors.primary.opacity(0.1),
                            AppTheme.Colors.primary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Text(category.name)
                    .font(AppTheme.Fonts.semibold(14))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Grid Layout Helper
struct CategoriesGrid: View {
    let categories: [CategoryViewModel]
    let columns: Int = 3
    let onCategoryTap: (CategoryViewModel) -> Void
    
    private var gridLayout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppTheme.Spacing.medium), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: AppTheme.Spacing.medium) {
            ForEach(categories.indices, id: \.self) { index in
                CategoryCard(category: categories[index]) {
                    onCategoryTap(categories[index])
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
    }
}

// MARK: - Preview
struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(category: CategoryViewModel()) {
            print("Category tapped")
        }
        .frame(width: 120)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
