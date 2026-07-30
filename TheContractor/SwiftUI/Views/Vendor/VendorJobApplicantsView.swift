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
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                case .noData:
                    Text("Data Not Found")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
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
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
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

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Available Applicant")

                ZStack {
                    VendorHomeStyle.background
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                    case .noData:
                        Text("Data Not Found")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
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
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                                        .padding(.vertical, 8)
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
        .onAppear { if applicants.isEmpty { fetch() } }
    }

    private func loadNextPageIfNeeded() {
        guard !isLoadingMore, page < lastPage else { return }
        page += 1
        isLoadingMore = true
        fetch()
    }

    /// Android passes empty category and city until the user opens the filter sheet.
    private func fetch() {
        GCD.async(.Background) {
            LoginService.shared().getAvailableApplicants(page: String(page), category: "", city: "") { message, success, json in
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
                            .foregroundColor(Color(white: 0.35))
                    }
                    Text(VendorHomeStyle.formatWorkshopDate(application.appliedAt))
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.45))
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
                        .foregroundColor(Color(red: 0.00, green: 0.61, blue: 0.33))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { onStatus("2") }) {
                    Text("Reject")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.84, green: 0.12, blue: 0.12))
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
                    .foregroundColor(Color(white: 0.4))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(white: 0.6))
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
                    Color(white: 0.9)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(white: 0.6))
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
