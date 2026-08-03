//
//  CompanyCard.swift
//  TheContractor
//
//  Reusable company card component matching Android design
//

import SwiftUI

struct CompanyCard: View {
    let company: CompanyViewModel
    let onTap: () -> Void

    /// Android adds to the enquiry basket straight from the list adapters (`CompaniesAdapter`,
    /// `TitaniumCompaniesAdapter`), not only from the details screen, so the row carries the control.
    @ObservedObject private var cart = ConsumerCartStore.shared

    init(company: CompanyViewModel, onTap: @escaping () -> Void) {
        self.company = company
        self.onTap = onTap
    }

    // The row was a Button wrapping everything, which would have swallowed taps on the basket
    // control nested inside it. The tap target is now a gesture on the content instead.
    var body: some View {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    // Company Logo
                    AsyncImage(url: URL(string: company.company_logo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipped()
                        case .failure(_):
                            Image(systemName: "building.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(AppTheme.Colors.gray)
                                .padding(AppTheme.Spacing.small)
                                .frame(width: 80, height: 80)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(company.company_name)
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .lineLimit(2)
                        
                        if !company.category_name.isEmpty {
                            Text(company.category_name)
                                .font(AppTheme.Fonts.regular(13))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.starYellow)
                            
                            Text(company.total_rating)
                                .font(AppTheme.Fonts.medium(13))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Text("(\(company.review_count))")
                                .font(AppTheme.Fonts.regular(12))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()

                    basketButton
                }

                Divider()
                    .padding(.top, 4)
            }
            .padding(AppTheme.Spacing.medium)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
    }

    private var basketButton: some View {
        Button(action: toggleInCart) {
            Image(systemName: isInCart ? "checkmark" : "plus")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isInCart ? .white : AppTheme.Colors.textPrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(isInCart ? AppTheme.Colors.primary
                                          : AppTheme.Colors.secondaryBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(company.id.isEmpty)
        .accessibilityLabel(isInCart ? "Remove \(company.company_name) from enquiry"
                                     : "Add \(company.company_name) to enquiry")
    }

    private var isInCart: Bool {
        cart.contains(companyId: company.id)
    }

    private func toggleInCart() {
        guard !company.id.isEmpty else { return }
        cart.toggle(CartCompany(id: company.id,
                                companyName: company.company_name,
                                companyLogo: company.company_logo,
                                categoryName: company.category_name))
    }
}

// MARK: - Preview
struct CompanyCard_Previews: PreviewProvider {
    static var previews: some View {
        CompanyCard(company: CompanyViewModel()) {
            print("Company tapped")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
