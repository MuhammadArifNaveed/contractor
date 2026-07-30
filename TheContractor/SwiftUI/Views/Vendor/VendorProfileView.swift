//
//  VendorProfileView.swift
//  TheContractor
//
//  Port of Android's `VendorProfile`. The drawer header's "View Profile" and the drawer's own
//  "Profile" row both land here, as they do on Android.
//
//  POST vendor/my_company → `Vendor_profile`, plus the online/offline switch on
//  POST vendor/is_online. Presentation per VendorTheme, not Android's layout.
//

import SwiftUI
import SwiftyJSON

struct VendorProfileView: View {
    @State private var state: VendorLoadState = .loading
    @State private var profile: VendorCompanyProfile?
    @State private var isOnline = false
    @State private var isTogglingOnline = false
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Profile")

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 3) }
                case .noData:
                    VendorEmptyState(icon: "building.2",
                                     title: "Profile unavailable",
                                     message: "Your company profile could not be loaded.",
                                     actionTitle: "Try again",
                                     action: load)
                case .loaded:
                    if let profile = profile {
                        content(profile)
                    }
                }

                if isTogglingOnline {
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

    // MARK: - Layout

    private func content(_ profile: VendorCompanyProfile) -> some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.l) {
                header(profile)
                onlineCard
                aboutCard(profile)
                locationCard(profile)
                registrationCard(profile)
                contactCard(profile)
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    private func header(_ profile: VendorCompanyProfile) -> some View {
        HStack(spacing: VendorTheme.Space.m) {
            AsyncImage(url: VendorTheme.companyLogoURL(profile.logo)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    ZStack {
                        VendorTheme.surfaceRaised
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(VendorTheme.textTertiary)
                    }
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(profile.companyName)
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                if !profile.categoryName.isEmpty {
                    Text(profile.categoryName)
                        .font(VendorTheme.Text.body)
                        .foregroundColor(VendorTheme.textSecondary)
                }

                // Android does not surface these at all; they are already in the response and tell
                // the company how customers see them.
                HStack(spacing: VendorTheme.Space.xs) {
                    if profile.isVerified { flag("Verified", "checkmark.seal.fill") }
                    if profile.isTitanium { flag("Titanium", "star.fill") }
                    if profile.isTrusted { flag("Trusted", "hand.thumbsup.fill") }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func flag(_ title: String, _ icon: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 8, weight: .bold))
            Text(title).font(VendorTheme.Text.badge)
        }
        .foregroundColor(VendorTheme.textPrimary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(VendorTheme.accent.opacity(0.28)))
    }

    /// Android splits this into a "Go Online" / "Go Offline" button plus a separate Yes/No label.
    /// One switch carries both the state and the action.
    private var onlineCard: some View {
        HStack(spacing: VendorTheme.Space.m) {
            Circle()
                .fill(isOnline ? VendorTheme.positive : VendorTheme.textTertiary)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(isOnline ? "Online" : "Offline")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                Text(isOnline ? "Customers can reach you now" : "You are hidden from customers")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: Binding(get: { isOnline }, set: { toggleOnline(to: $0) }))
                .labelsHidden()
                .tint(VendorTheme.accent)
        }
        .vendorCard()
    }

    private func aboutCard(_ profile: VendorCompanyProfile) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "About")
            VendorField(label: "Description",
                        value: profile.description.isEmpty ? "Not added" : profile.description)
            if !profile.speciality.isEmpty {
                VendorField(label: "Speciality", value: profile.speciality)
            }
            if !profile.employees.isEmpty {
                VendorField(label: "Employees", value: profile.employees)
            }
            if !profile.timing.isEmpty {
                VendorField(label: "Working hours", value: profile.timing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func locationCard(_ profile: VendorCompanyProfile) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Location")
            VendorField(label: "Address", value: profile.address.isEmpty ? "Not added" : profile.address)
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "City", value: profile.cityName.isEmpty ? "Not added" : profile.cityName)
                VendorField(label: "Area", value: profile.areaName.isEmpty ? "Not added" : profile.areaName)
            }
            VendorField(label: "Country", value: profile.countryName.isEmpty ? "Not added" : profile.countryName)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func registrationCard(_ profile: VendorCompanyProfile) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Registration")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Company ID", value: profile.serialNumber)
                VendorField(label: "Registered", value: VendorTheme.shortDate(profile.createdAt))
            }
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Membership no.",
                            value: profile.membershipNumber.isEmpty ? "Not added" : profile.membershipNumber)
                VendorField(label: "Licence",
                            value: profile.license.isEmpty ? "Not added" : profile.license)
            }
            if !profile.since.isEmpty {
                VendorField(label: "In business since", value: profile.since)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func contactCard(_ profile: VendorCompanyProfile) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Contact")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Phone", value: profile.phone)
                VendorField(label: "WhatsApp",
                            value: profile.whatsapp.isEmpty ? "Not added" : profile.whatsapp)
            }
            VendorField(label: "Email", value: profile.email)
            if !profile.website.isEmpty {
                VendorField(label: "Website", value: profile.website)
            }
            if !profile.ownerName.isEmpty {
                VendorField(label: "Owner", value: profile.ownerName)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Data

    private func load() {
        guard !VendorSession.currentVendorId.isEmpty else {
            state = .noData
            return
        }
        if profile == nil { state = .loading }
        fetch()
    }

    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        let vendorId = VendorSession.currentVendorId
        GCD.async(.Background) {
            LoginService.shared().getVendorProfile(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json, json["Vendor_profile"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    let loaded = VendorCompanyProfile(json["Vendor_profile"])
                    profile = loaded
                    isOnline = loaded.isOnline
                    state = .loaded
                }
            }
        }
    }

    private func toggleOnline(to desired: Bool) {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        // Flip optimistically, then reconcile with the server.
        isOnline = desired
        isTogglingOnline = true
        GCD.async(.Background) {
            LoginService.shared().setVendorOnline(vendorId: vendorId, isOnline: desired) { message, success in
                GCD.async(.Main) {
                    isTogglingOnline = false
                    if success {
                        noticeMessage = message.isEmpty
                            ? (desired ? "You are now online." : "You are now offline.")
                            : message
                    } else {
                        isOnline = !desired
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Model

/// Android's vendor profile record. The response also carries the bcrypt password, otp and
/// verification tokens; none of those are read here.
struct VendorCompanyProfile {
    let id: String
    let companyName: String
    let categoryName: String
    let description: String
    let speciality: String
    let employees: String
    let timing: String
    let since: String
    let address: String
    let cityName: String
    let areaName: String
    let countryName: String
    let serialNumber: String
    let membershipNumber: String
    let license: String
    let createdAt: String
    let phone: String
    let whatsapp: String
    let email: String
    let website: String
    let ownerName: String
    let logo: String
    let isOnline: Bool
    let isVerified: Bool
    let isTitanium: Bool
    let isTrusted: Bool

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.companyName = json["company_name"].stringValue
        self.categoryName = json["category_name"].stringValue
        self.description = json["company_discription"].stringValue
        self.speciality = json["speciality"].stringValue
        self.employees = json["company_employees"].stringValue
        self.timing = json["company_timing"].stringValue
        self.since = json["company_since"].stringValue
        self.address = json["company_address"].stringValue
        self.cityName = json["city_name"].stringValue
        self.areaName = json["area_name"].stringValue
        self.countryName = json["country_name"].stringValue
        self.serialNumber = json["company_serial_number"].stringValue
        self.membershipNumber = json["company_membership_number"].stringValue
        self.license = json["company_license"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.phone = json["company_phone"].stringValue
        self.whatsapp = json["company_whatsapp"].stringValue
        self.email = json["company_email"].stringValue
        self.website = json["company_website"].stringValue
        self.ownerName = json["company_owner_name"].stringValue
        self.logo = json["company_logo"].stringValue
        self.isOnline = json["is_online"].stringValue == "1"
        self.isVerified = json["is_verified"].stringValue == "1"
        self.isTitanium = json["is_titanium"].stringValue == "1"
        self.isTrusted = json["is_trusted"].stringValue == "1"
    }
}
