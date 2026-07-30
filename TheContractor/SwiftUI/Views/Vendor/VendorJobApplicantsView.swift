//
//  VendorJobApplicantsView.swift
//  TheContractor
//
//  Two distinct Android screens that both list people:
//    • `VendorJobDetail` → applies for one job (POST jobs/view_applies → `job_applies`)
//    • `VendorApplicants` — the drawer item "Available Applicant"
//      (POST jobs/search_applicants → `available_users` + `total_page`)
//

import SwiftUI
import SwiftyJSON

// MARK: - Applications for one job

struct VendorJobApplicantsView: View {
    let jobUuid: String
    let jobTitle: String

    @State private var state: VendorLoadState = .loading
    @State private var applications: [VendorJobApplication] = []
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var isMutating = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Applicants", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "person.2",
                                     title: "No applicants yet",
                                     message: "People who apply to this job appear here.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            if !jobTitle.isEmpty {
                                Text(jobTitle)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            ForEach(applications) { application in
                                VendorJobApplicationCard(application: application) { status in
                                    updateStatus(application, to: status)
                                }
                            }
                        }
                        .padding(10)
                    }
                }

                if isMutating {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func load() {
        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorJobApplications(jobUuid: jobUuid, page: "1") { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    applications = json["job_applies"].arrayValue.map(VendorJobApplication.init)
                    state = applications.isEmpty ? .noData : .loaded
                }
            }
        }
    }

    private func updateStatus(_ application: VendorJobApplication, to status: String) {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isMutating = true
        GCD.async(.Background) {
            LoginService.shared().updateVendorJobApplicationStatus(vendorId: vendorId,
                                                                   applicationId: application.id,
                                                                   status: status) { message, success in
                GCD.async(.Main) {
                    isMutating = false
                    if success {
                        noticeMessage = message.isEmpty ? "Application updated." : message
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Available applicants (drawer item)

struct VendorAvailableApplicantsView: View {
    @State private var state: VendorLoadState = .loading
    @State private var applicants: [VendorApplicant] = []
    @State private var page = 1
    @State private var lastPage = 0
    @State private var isLoadingMore = false
    @State private var errorMessage: String?

    // Android's filter: the endpoint takes `category` and `city`, and the picker lists come from
    // jobs/get_job_search_fields.
    @State private var showFilter = false
    @State private var categories: [VendorJobFilterOption] = []
    @State private var cities: [VendorJobFilterOption] = []
    @State private var selectedCategory: VendorJobFilterOption?
    @State private var selectedCity: VendorJobFilterOption?

    private var activeFilterCount: Int {
        [selectedCategory != nil, selectedCity != nil].filter { $0 }.count
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Available Applicant",
                             trailingIcon: activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill"
                                                                 : "line.3.horizontal.decrease.circle",
                             trailingAction: { showFilter = true })

                ZStack {
                    VendorTheme.canvas
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        VendorSkeletonList()
                    case .noData:
                        VendorEmptyState(icon: "person.2",
                                     title: "No applicants found",
                                     message: "Try widening the category or city filter.")
                    case .loaded:
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(applicants) { applicant in
                                    NavigationLink(destination: VendorApplicantDetailView(applicant: applicant)) {
                                        VendorApplicantCard(applicant: applicant)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        if applicant.id == applicants.last?.id { loadNextPageIfNeeded() }
                                    }
                                }

                                if isLoadingMore {
                                    VendorBusyIndicator()
                                        .padding(.vertical, VendorTheme.Space.m)
                                }
                            }
                            .padding(10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showFilter) {
            VendorApplicantFilterSheet(categories: categories,
                                       cities: cities,
                                       selectedCategory: $selectedCategory,
                                       selectedCity: $selectedCity) {
                showFilter = false
                reload()
            } onCancel: {
                showFilter = false
            }
        }
        .onAppear {
            if applicants.isEmpty { fetch() }
            if categories.isEmpty { loadFilterOptions() }
        }
    }

    private func reload() {
        page = 1
        lastPage = 0
        applicants = []
        state = .loading
        fetch()
    }

    private func loadFilterOptions() {
        GCD.async(.Background) {
            LoginService.shared().getJobSearchFields { _, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else { return }
                    categories = json["job_categories"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["title"].stringValue)
                    }
                    cities = json["job_cities"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["name"].stringValue)
                    }
                }
            }
        }
    }

    private func loadNextPageIfNeeded() {
        guard !isLoadingMore, page < lastPage else { return }
        page += 1
        isLoadingMore = true
        fetch()
    }

    private func fetch() {
        let category = selectedCategory?.id ?? ""
        let city = selectedCity?.id ?? ""
        GCD.async(.Background) {
            LoginService.shared().getAvailableApplicants(page: String(page), category: category, city: city) { message, success, json in
                GCD.async(.Main) {
                    isLoadingMore = false
                    guard success, let json = json else {
                        if applicants.isEmpty {
                            state = .noData
                            errorMessage = message.isEmpty ? "Please try again" : message
                        }
                        return
                    }
                    lastPage = json["total_page"].int ?? Int(json["total_page"].stringValue) ?? 0
                    applicants += json["available_users"].arrayValue.map(VendorApplicant.init)
                    state = applicants.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Models

/// Android's `job_applies` row. The user's own fields arrive flattened with a `users_user_` prefix.
struct VendorJobApplication: Identifiable {
    let id: String
    let name: String
    let surname: String
    let email: String
    let phone: String
    let address: String
    let image: String
    let appliedAt: String
    let currentStatus: String
    let postTitle: String
    let cv: String

    var fullName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["users_user_name"].stringValue
        self.surname = json["users_user_sur_name"].stringValue
        self.email = json["users_user_email"].stringValue
        self.phone = json["users_user_phone"].stringValue
        self.address = json["users_user_address"].stringValue
        self.image = json["users_user_image"].stringValue
        self.appliedAt = json["applied_at"].stringValue
        self.currentStatus = json["current_status"].stringValue
        self.postTitle = json["post_title"].stringValue
        self.cv = json["cv"].stringValue
    }
}

/// Android's `available_users` row (`VendorApplicantListingModel`).
struct VendorApplicant: Identifiable {
    let id: String
    let uuid: String
    let name: String
    let surname: String
    let email: String
    let phone: String
    let address: String
    let image: String
    let video: String
    let categoryTitle: String
    let cityName: String
    let countryName: String
    let createdAt: String

    var fullName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.uuid = json["uuid"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.email = json["email"].stringValue
        self.phone = json["phone"].stringValue
        self.address = json["address"].stringValue
        self.image = json["image"].stringValue
        self.video = json["video"].stringValue
        self.categoryTitle = json["category_title"].stringValue
        self.cityName = json["user_city_name"].stringValue
        self.countryName = json["country_name"].stringValue
        self.createdAt = json["created_at"].stringValue
    }
}

// MARK: - Cards

struct VendorJobApplicationCard: View {
    let application: VendorJobApplication
    let onStatus: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                VendorPersonAvatar(path: application.image)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.fullName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    if !application.phone.isEmpty {
                        Text(application.phone)
                            .font(.system(size: 12))
                            .foregroundColor(VendorTheme.textSecondary)
                    }
                    Text(VendorTheme.date(application.appliedAt))
                        .font(.system(size: 12))
                        .foregroundColor(VendorTheme.textSecondary)
                }

                Spacer()
            }

            if !application.currentStatus.isEmpty {
                Text(application.currentStatus)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
            }

            Divider()

            HStack(spacing: 16) {
                Button(action: { onStatus("1") }) {
                    Text("Accept")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(VendorTheme.positive)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { onStatus("2") }) {
                    Text("Reject")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(VendorTheme.negative)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

struct VendorApplicantCard: View {
    let applicant: VendorApplicant

    var body: some View {
        HStack(spacing: 10) {
            VendorPersonAvatar(path: applicant.image)

            VStack(alignment: .leading, spacing: 2) {
                Text(applicant.fullName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)

                if !applicant.categoryTitle.isEmpty {
                    Text(applicant.categoryTitle)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                }

                Text([applicant.cityName, applicant.countryName].filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(.system(size: 12))
                    .foregroundColor(VendorTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(VendorTheme.textTertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

/// Android loads these from `ApiUrls.PROFILE_IMAGE_URL`.
struct VendorPersonAvatar: View {
    let path: String

    var body: some View {
        AsyncImage(url: VendorPersonAvatar.url(path)) { phase in
            if case .success(let image) = phase {
                image.resizable().scaledToFill()
            } else {
                ZStack {
                    VendorTheme.surfaceRaised
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(VendorTheme.textTertiary)
                }
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }

    static func url(_ path: String) -> URL? {
        guard !path.isEmpty else { return nil }
        return URL(string: "https://contractor.bidcont.com/uploads/users/" + path)
    }
}


// MARK: - Applicant filter

/// One option in the category or city picker, from `jobs/get_job_search_fields`. Categories arrive
/// under `title`, cities under `name`.
struct VendorJobFilterOption: Identifiable, Hashable {
    let id: String
    let name: String
}

/// Android puts category and city behind two spinners on the toolbar. A single sheet with a clear
/// action is fewer taps and shows both current selections at once.
struct VendorApplicantFilterSheet: View {
    let categories: [VendorJobFilterOption]
    let cities: [VendorJobFilterOption]
    @Binding var selectedCategory: VendorJobFilterOption?
    @Binding var selectedCity: VendorJobFilterOption?
    let onApply: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Filter applicants", onBack: onCancel)

            ScrollView {
                VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                    picker(title: "Category", options: categories, selection: $selectedCategory)
                    picker(title: "City", options: cities, selection: $selectedCity)

                    HStack(spacing: VendorTheme.Space.s) {
                        Button(action: {
                            selectedCategory = nil
                            selectedCity = nil
                            onApply()
                        }) {
                            Text("Clear")
                                .font(VendorTheme.Text.cardTitle)
                                .foregroundColor(VendorTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, VendorTheme.Space.m)
                                .background(
                                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                        .fill(VendorTheme.surfaceRaised)
                                )
                        }
                        .buttonStyle(VendorPressStyle())

                        Button(action: onApply) {
                            Text("Apply")
                                .font(VendorTheme.Text.cardTitle)
                                .foregroundColor(.black.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, VendorTheme.Space.m)
                                .background(
                                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                        .fill(VendorTheme.accent)
                                )
                        }
                        .buttonStyle(VendorPressStyle())
                    }
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas)
        }
    }

    private func picker(title: String,
                        options: [VendorJobFilterOption],
                        selection: Binding<VendorJobFilterOption?>) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
            VendorSectionHeader(title: title)

            if options.isEmpty {
                VendorSkeleton(height: 32)
            } else {
                // Wrapping chips rather than a menu: with a handful of options every choice is
                // visible without a second tap.
                VendorChipRow(options: options, selection: selection)
            }
        }
    }
}

/// A simple wrapping row of selectable chips.
struct VendorChipRow: View {
    let options: [VendorJobFilterOption]
    @Binding var selection: VendorJobFilterOption?

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: VendorTheme.Space.s)],
                  alignment: .leading,
                  spacing: VendorTheme.Space.s) {
            ForEach(options) { option in
                let isSelected = selection?.id == option.id
                Button(action: { selection = isSelected ? nil : option }) {
                    Text(option.name)
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(isSelected ? .black.opacity(0.85) : VendorTheme.textPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VendorTheme.Space.s)
                        .background(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.badge, style: .continuous)
                                .fill(isSelected ? VendorTheme.accent : VendorTheme.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: VendorTheme.Radius.badge, style: .continuous)
                                .stroke(isSelected ? Color.clear : VendorTheme.separator, lineWidth: 0.5)
                        )
                }
                .buttonStyle(VendorPressStyle())
            }
        }
    }
}
