//
//  CompanyFreelancersListView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI
import SwiftyJSON

struct CompanyFreelancersListView: View {
    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var vm = CompanyFreelancersListViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(title: "Freelancers")

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.items) { item in
                                CompanyFreelancerCard(
                                    item: item,
                                    onToggleFreelancerAvailability: { isChecked in
                                        vm.toggleFreelancerAvailability(for: item, to: isChecked)
                                    },
                                    onUpdate: {
                                        vm.selectedForUpdate = item
                                    }
                                )
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }

                NavigationLink(
                    destination: UpdateFreelancerView(),
                    isActive: Binding(
                        get: { vm.selectedForUpdate != nil },
                        set: { isActive in
                            if !isActive {
                                vm.selectedForUpdate = nil
                            }
                        }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.load()
        }
    }

    private func topBar(title: String) -> some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text(title)
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }
}

// MARK: - Card

private struct CompanyFreelancerCard: View {
    let item: CompanyFreelancerItem
    let onToggleFreelancerAvailability: (Bool) -> Void
    let onUpdate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                Circle()
                    .fill(AppTheme.Colors.secondaryBackground)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()

                        Text(item.formattedRate)
                            .font(AppTheme.Fonts.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }

                    if !item.category.isEmpty {
                        Text(item.category)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }

            if !item.skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(item.skills, id: \.self) { skill in
                            Text(skill)
                                .font(AppTheme.Fonts.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.primary.opacity(0.1))
                                .foregroundColor(AppTheme.Colors.primary)
                                .cornerRadius(12)
                        }
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text(item.location)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text(item.workingHours)
                    .font(AppTheme.Fonts.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Text("Member since \(item.memberSince)")
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textPrimary)

            // Checkbox row: "Yes, i am available as freelancer"
            Button(action: {
                onToggleFreelancerAvailability(!item.isAvailableAsFreelancer)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: item.isAvailableAsFreelancer ? "checkmark.square.fill" : "square")
                        .foregroundColor(AppTheme.Colors.primary)

                    Text(item.isAvailableAsFreelancer ? "Yes, i am available as freelancer" : "No, I am not available as freelancer")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: AppTheme.Spacing.small) {
                // Rating
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(item.rating.rounded()) ? "star.fill" : (index < Int(item.rating.rounded(.up)) ? "star.leadinghalf.filled" : "star"))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.starYellow)
                    }

                    Text("(\(item.reviewCount))")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Button(action: {
                    // This button reflects general availability ("Available" / "Not Available").
                    // API for toggling this is not defined yet.
                }) {
                    Text(item.isAvailable ? "Available" : "Not Available")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)

                Button(action: {
                    onUpdate()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .medium))
                        Text("Update")
                            .font(AppTheme.Fonts.caption)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .cardStyle(cornerRadius: AppTheme.CornerRadius.medium, shadowRadius: 2)
    }
}

// MARK: - Models & ViewModel

struct CompanyFreelancerItem: Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let hourlyRate: String
    let imageUrl: String
    let skills: [String]
    let location: String
    let workingHours: String
    let memberSince: String
    let rating: Double
    let reviewCount: Int
    /// Checkbox: "Yes, i am available as freelancer"
    var isAvailableAsFreelancer: Bool
    /// General availability button (Available / Not Available)
    var isAvailable: Bool

    var formattedRate: String { "\(hourlyRate)/hr" }
}

final class CompanyFreelancersListViewModel: ObservableObject {
    @Published var items: [CompanyFreelancerItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedForUpdate: CompanyFreelancerItem?

    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchCompanyFreelancersList { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    self.items = json["company_freelancers_list"].arrayValue.map { freelancer in
                        let id = freelancer["id"].stringValue
                        let name = freelancer["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let hourlyRate = freelancer["hourly_rate"].stringValue
                        let image = freelancer["image"].stringValue
                        let categoryName = freelancer["category_name"].stringValue
                        let cityName = freelancer["city_name"].stringValue
                        let areaName = freelancer["area_name"].stringValue
                        let location = [areaName, cityName].filter { !$0.isEmpty }.joined(separator: " , ")

                        let fromTime = freelancer["from_time"].stringValue
                        let toTime = freelancer["to_time"].stringValue
                        let workingHours = formatTimeRange(from: fromTime, to: toTime)

                        let createdAt = freelancer["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let memberSince = formatMemberSince(createdAt)

                        let ratingJSON = freelancer["rating"]
                        let avgRating = ratingJSON["avg_rating"].doubleValue
                        let totalOrders = ratingJSON["total_orders"].intValue

                        let skills = freelancer["skills"].arrayValue.map { $0["skill_title"].stringValue }

                        let availableAsFreelancerFlag = freelancer["is_available_as_freelancer"].stringValue
                        let availability = freelancer["availability"].stringValue
                        let isAvailableAsFreelancer = availableAsFreelancerFlag == "1"
                        let isAvailable = availability == "1"

                        return CompanyFreelancerItem(
                            id: id,
                            name: name,
                            category: categoryName,
                            hourlyRate: hourlyRate,
                            imageUrl: image,
                            skills: skills,
                            location: location,
                            workingHours: workingHours,
                            memberSince: memberSince,
                            rating: avgRating,
                            reviewCount: totalOrders,
                            isAvailableAsFreelancer: isAvailableAsFreelancer,
                            isAvailable: isAvailable
                        )
                    }
                } else {
                    self.errorMessage = message
                    self.items = []
                }
            }
        }
    }

    /// Toggle "Yes, i am available as freelancer" state for a given freelancer.
    func toggleFreelancerAvailability(for item: CompanyFreelancerItem, to isChecked: Bool) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        var updated = item
        updated.isAvailableAsFreelancer = isChecked
        items[index] = updated

        FreelancingService.shared.updateCompanyFreelancerStatus(freelancerId: item.id, isChecked: isChecked) { [weak self] message, success, available in
            DispatchQueue.main.async {
                guard let self else { return }
                guard let idx = self.items.firstIndex(where: { $0.id == item.id }) else { return }

                if success {
                    var confirmed = self.items[idx]
                    confirmed.isAvailableAsFreelancer = available
                    self.items[idx] = confirmed
                } else {
                    // Revert on failure
                    var reverted = self.items[idx]
                    reverted.isAvailableAsFreelancer = !isChecked
                    self.items[idx] = reverted
                    self.errorMessage = message
                }
            }
        }
    }
}

// MARK: - Formatting Helpers

private func formatTimeRange(from: String, to: String) -> String {
    let fromFormatted = formatTime(from)
    let toFormatted = formatTime(to)
    if fromFormatted.isEmpty || toFormatted.isEmpty {
        return ""
    }
    return "\(fromFormatted) to \(toFormatted)"
}

private func formatTime(_ value: String) -> String {
    guard !value.isEmpty else { return "" }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm:ss"
    if let date = formatter.date(from: value) {
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    return value
}

private func formatMemberSince(_ raw: String) -> String {
    guard !raw.isEmpty else { return "" }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    if let date = formatter.date(from: raw) {
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    return raw
}
