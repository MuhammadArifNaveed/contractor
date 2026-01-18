//
//  FreelancersView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI
import SDWebImage

struct FreelancersView: View {
    @StateObject private var viewModel = FreelancerListViewModel.mockData()
    @State private var showSearchSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                navigationBar
                
                // Freelancers List
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        ForEach(viewModel.freelancers.indices, id: \.self) { index in
                            FreelancerCardView(freelancer: viewModel.freelancers[index])
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSearchSheet) {
            SearchFreelancerView { filter in
                // Handle search with filter
                performSearch(with: filter)
            }
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 0) {
            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            
            // Title
            Text("Freelancers")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
            
            // Search button
            Button(action: { 
                showSearchSheet = true 
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }
    
    private func performSearch(with filter: FreelancerSearchFilter) {
        // TODO: Implement actual search API call
        print("Searching with filter: \(filter.skills), \(filter.rate), \(filter.selectedCategory), \(filter.selectedCity)")
    }
}

// MARK: - Freelancer Card View
struct FreelancerCardView: View {
    let freelancer: FreelancerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            // Header with image, name, profession, and rate
            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                // Profile Image
                ProfileImageView(imageUrl: freelancer.profileImage, size: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(freelancer.name)
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text(freelancer.profession)
                            .font(AppTheme.Fonts.regular(13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text(freelancer.formattedRate)
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
                
                Spacer()
                
                // Availability badge
                if freelancer.isAvailableHourly {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("Available Hourly")
                            .font(AppTheme.Fonts.small)
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(12)
                }
            }
            
            // Skills tags
            if !freelancer.skills.isEmpty {
                FlowLayoutView(items: freelancer.skills, spacing: 8) { skill in
                    SkillTag(text: skill)
                }
                .padding(.top, 4)
            }
            
            // Location and working hours
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(freelancer.location)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(freelancer.workingHours)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.top, 4)
            
            // Member since and rating
            HStack {
                Text("Member since \(freelancer.memberSince)")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                // Login button
                Button(action: {
                    // Handle hire action - show login if needed
                }) {
                    Text("Please Login to Hire")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
            }
            .padding(.top, 4)
            
            // Rating
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(freelancer.rating.rounded()) ? "star.fill" : (index < Int(freelancer.rating.rounded(.up)) ? "star.leadinghalf.filled" : "star"))
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.starYellow)
                }
                
                Text("(\(freelancer.reviewCount))")
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(.top, 4)
        }
        .padding(AppTheme.Spacing.medium)
        .cardStyle(cornerRadius: AppTheme.CornerRadius.medium, shadowRadius: 2)
    }
}

// MARK: - Skill Tag
struct SkillTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(AppTheme.Fonts.caption)
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.primary.opacity(0.2))
            .cornerRadius(15)
    }
}

// MARK: - Profile Image View
struct ProfileImageView: View {
    let imageUrl: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if imageUrl.isEmpty {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(AppTheme.Colors.gray)
            } else {
                // Using AsyncImage for iOS 15+
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(AppTheme.Colors.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(AppTheme.Colors.border, lineWidth: 1))
    }
}

// MARK: - Flow Layout for Skills (iOS 15 compatible)
struct FlowLayoutView<Item: Hashable, Content: View>: View {
    let items: [Item]
    let spacing: CGFloat
    let content: (Item) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            self.createLayout(in: geometry)
        }
        .frame(height: calculateHeight())
    }
    
    private func createLayout(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(items.indices, id: \.self) { index in
                content(items[index])
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        if index == items.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        if abs(width) > geometry.size.width {
                            height += dimension.height + spacing
                        }
                        let result = height
                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
    
    private func calculateHeight() -> CGFloat {
        // Simple estimation - will be dynamically adjusted
        let rows = CGFloat((items.count + 2) / 3) // Approximate 3 items per row
        return rows * 30 + (rows - 1) * spacing
    }
}

struct FreelancersView_Previews: PreviewProvider {
    static var previews: some View {
        FreelancersView()
    }
}
