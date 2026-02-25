//
//  CompanyDetailView.swift
//  TheContractor
//
//  Company details screen matching Android CompanyDetails activity
//

import SwiftUI

struct CompanyDetailView: View {
    @StateObject private var viewModel: CompanyDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(company: CompanyViewModel) {
        _viewModel = StateObject(wrappedValue: CompanyDetailViewModel(company: company))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Company Header
                companyHeader
                
                // Action Buttons
                actionButtons
                
                // Company Info Sections
                VStack(spacing: AppTheme.Spacing.medium) {
                    // About Section
                    if !viewModel.company.company_discription.isEmpty {
                        infoSection(title: "About", content: viewModel.company.company_discription)
                    }
                    
                    // Contact Information
                    contactSection
                    
                    // Rating & Reviews
                    ratingSection
                }
                .padding(AppTheme.Spacing.medium)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Company Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Company Header
    private var companyHeader: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            // Company Logo
            AsyncImage(url: URL(string: viewModel.company.company_logo)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "building.2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(AppTheme.Colors.gray)
                    .padding(40)
            }
            .frame(width: 120, height: 120)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            
            // Company Name
            Text(viewModel.company.company_name)
                .font(AppTheme.Fonts.semibold(20))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Category
            if !viewModel.company.category_name.isEmpty {
                Text(viewModel.company.category_name)
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            // Rating
            HStack(spacing: 8) {
                RatingView(rating: Double(viewModel.company.total_rating) ?? 0.0, size: 18)
                
                Text(viewModel.company.total_rating)
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("(\(viewModel.company.review_count) reviews)")
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.Colors.primary.opacity(0.1),
                    Color.white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ActionButton(title: "Enquiry", icon: "envelope.fill", color: AppTheme.Colors.primary) {
                viewModel.submitEnquiry()
            }
            
            ActionButton(title: "Quotation", icon: "doc.text.fill", color: AppTheme.Colors.darkGreen) {
                viewModel.requestQuotation()
            }
            
            ActionButton(title: "Call", icon: "phone.fill", color: AppTheme.Colors.darkBlue) {
                viewModel.callCompany()
            }
        }
        .padding(AppTheme.Spacing.medium)
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Contact Information")
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            if !viewModel.company.login_email.isEmpty {
                ContactRow(icon: "envelope", text: viewModel.company.login_email)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            HStack {
                Text("Ratings & Reviews")
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: { viewModel.showAllReviews() }) {
                    Text("View All")
                        .font(AppTheme.Fonts.medium(14))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            // Rating Summary
            HStack(spacing: AppTheme.Spacing.large) {
                VStack {
                    Text(viewModel.company.total_rating)
                        .font(AppTheme.Fonts.bold(32))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    RatingView(rating: Double(viewModel.company.total_rating) ?? 0.0, size: 16)
                    
                    Text("\(viewModel.company.review_count) reviews")
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Info Section Helper
    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(content)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(AppTheme.Fonts.medium(13))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

// MARK: - Contact Row
struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24)
            
            Text(text)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
}

// MARK: - Preview
struct CompanyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompanyDetailView(company: CompanyViewModel())
        }
    }
}
