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
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack(spacing: AppTheme.Spacing.medium) {
                    // Company Logo
                    AsyncImage(url: URL(string: company.company_logo)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "building.2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(AppTheme.Colors.gray)
                            .padding(AppTheme.Spacing.small)
                    }
                    .frame(width: 80, height: 80)
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
                }
                
                Divider()
                    .padding(.top, 4)
            }
            .padding(AppTheme.Spacing.medium)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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
