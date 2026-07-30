//
//  VendorSubscriptionView.swift
//  TheContractor
//
//  Two drawer screens from Android:
//    • `VendorMembership`   — the plans on offer (POST vendor/memberships → `memberships_list`)
//    • `VendorMyMembership` — the plans already bought (POST vendor/my_memberships → `my_memberships`)
//
//  Android offers two ways to buy: a card payment through its payment gateway
//  (`vendor/buy_membership_online`) and a coupon code (`vendor/buy_membership_by_coupon`). Only the
//  coupon path is wired up here; the card path needs a gateway integration iOS does not have yet.
//

import SwiftUI
import SwiftyJSON

// MARK: - Memberships on offer

struct VendorSubscriptionView: View {
    @State private var state: VendorLoadState = .loading
    @State private var memberships: [VendorMembership] = []
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    @State private var couponMembership: VendorMembership?
    @State private var couponCode = ""
    @State private var isBuying = false

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Memberships")

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "crown",
                                     title: "No plans available",
                                     message: "Membership plans could not be loaded.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(memberships) { membership in
                                VendorMembershipCard(membership: membership) {
                                    couponCode = ""
                                    couponMembership = membership
                                }
                            }
                        }
                        .padding(10)
                    }
                }

                if isBuying {
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
        // Android's membership_coupon_dialog.
        .sheet(isPresented: Binding(get: { couponMembership != nil }, set: { if !$0 { couponMembership = nil } })) {
            if let membership = couponMembership {
                VendorCouponSheet(membershipTitle: membership.title, code: $couponCode) {
                    let selected = membership
                    couponMembership = nil
                    redeemCoupon(for: selected)
                } onCancel: {
                    couponMembership = nil
                    couponCode = ""
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorMemberships(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    memberships = json["memberships_list"].arrayValue.map(VendorMembership.init)
                    state = memberships.isEmpty ? .noData : .loaded
                }
            }
        }
    }

    private func redeemCoupon(for membership: VendorMembership) {
        let code = couponCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            noticeMessage = "Enter coupon code"
            return
        }

        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isBuying = true
        GCD.async(.Background) {
            LoginService.shared().buyVendorMembershipByCoupon(vendorId: vendorId, membershipId: membership.id, couponCode: code) { message, success in
                GCD.async(.Main) {
                    isBuying = false
                    couponCode = ""
                    noticeMessage = message.isEmpty ? (success ? "Membership activated." : "Please try again") : message
                    if success { load() }
                }
            }
        }
    }
}

// MARK: - Memberships already bought

struct VendorMyMembershipView: View {
    @State private var state: VendorLoadState = .loading
    @State private var memberships: [VendorMyMembership] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            VendorTopBar(title: "My Membership")

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "crown",
                                     title: "No memberships yet",
                                     message: "Plans you buy will be listed here.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(memberships) { membership in
                                NavigationLink(destination: VendorMyMembershipDetailView(membership: membership)) {
                                    VendorMyMembershipCard(membership: membership)
                                }
                                .buttonStyle(VendorPressStyle())
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
        .onAppear(perform: load)
    }

    private func load() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorMyMemberships(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    memberships = json["my_memberships"].arrayValue.map(VendorMyMembership.init)
                    state = memberships.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Models

/// Android `VendorMembershipModel`.
struct VendorMembership: Identifiable {
    let id: String
    let title: String
    let price: String
    let topTenDays: String
    let topTwentyDays: String
    let leadsCapacity: String
    let quotationsCapacity: String
    let customerSupport: String
    let authenticationCertificate: String
    let listingIn24: String
    let welcomeKit: String
    let workshopPrice: String
    let statusId: String
    let statusName: String
    let buyType: String
    let buyValue: String
    let color: String

    /// Android hides the Buy button and shows the bought-status block whenever `status_id` is set.
    var isOwned: Bool { !statusId.isEmpty }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.price = json["price"].stringValue
        self.topTenDays = json["top_ten_days"].stringValue
        self.topTwentyDays = json["top_twenty_days"].stringValue
        self.leadsCapacity = json["leads_capacity"].stringValue
        self.quotationsCapacity = json["quotations_capacity"].stringValue
        self.customerSupport = json["customer_support"].stringValue
        self.authenticationCertificate = json["authentication_certificate"].stringValue
        self.listingIn24 = json["listing_in_24"].stringValue
        self.welcomeKit = json["welcome_kit"].stringValue
        self.workshopPrice = json["workshop_price"].stringValue
        self.statusId = json["status_id"].stringValue
        self.statusName = json["status_name"].stringValue
        self.buyType = json["buy_type"].stringValue
        self.buyValue = json["buy_value"].stringValue
        self.color = json["color"].stringValue
    }
}

/// Android `VendorMyMembershipModel`, reduced to what `VendorMyMembershipAdapter` binds.
struct VendorMyMembership: Identifiable {
    let id: String
    let title: String
    let number: String
    let price: String
    let statusName: String
    let color: String
    let createdAt: String
    let buyType: String
    let couponCode: String
    let leadsCapacity: String
    let leadsUsed: String
    let quotationsCapacity: String
    let quotationsUsed: String
    let topTenStart: String
    let topTenExpiry: String
    let topTwentyStart: String
    let topTwentyExpiry: String
    let workshopIncluded: String
    let workshopPrice: String
    let detail: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["membership_title"].stringValue
        self.number = json["membership_number"].stringValue
        self.price = json["membership_price"].stringValue
        self.statusName = json["s_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.buyType = json["buy_type"].stringValue
        self.couponCode = json["coupon_code"].stringValue
        self.leadsCapacity = json["membership_leads_capacity"].stringValue
        self.leadsUsed = json["leads_used"].stringValue
        self.quotationsCapacity = json["membership_quotations_capacity"].stringValue
        self.quotationsUsed = json["quotations_used"].stringValue
        self.topTenStart = json["top_ten_start_date"].stringValue
        self.topTenExpiry = json["top_ten_expiry_date"].stringValue
        self.topTwentyStart = json["top_twenty_start_date"].stringValue
        self.topTwentyExpiry = json["top_twenty_expiry_date"].stringValue
        self.workshopIncluded = json["workshop_include"].stringValue
        self.workshopPrice = json["workshop_price"].stringValue
        self.detail = json["membership_detail"].stringValue
    }
}

// MARK: - Cards

/// Android `membership_custom_row.xml`. Each perk shows the plan's number of days / capacity, or a
/// tick when it is simply included, or a cross when the value is "0".
struct VendorMembershipCard: View {
    let membership: VendorMembership
    let onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(membership.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("AED \(membership.price)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }

            Rectangle()
                .fill(VendorTheme.surfaceRaised)
                .frame(height: 0.5)

            perk("Top 10 (Listed in 1st Page)", days: membership.topTenDays)
            perk("Top 20 (Listed in 2nd Page)", days: membership.topTwentyDays)
            perk("Lead Capacity", capacity: membership.leadsCapacity)
            perk("Quotation By Photo", capacity: membership.quotationsCapacity)
            perk("Customer Support", included: membership.customerSupport)
            perk("Authentication Certificate", included: membership.authenticationCertificate)
            perk("Listing in 24/7", included: membership.listingIn24)
            perk("Welcome Kit", included: membership.welcomeKit)
            perk("Workshop (Add-On)", addOnPrice: membership.workshopPrice)

            if membership.isOwned {
                HStack(spacing: 6) {
                    VendorBadge(name: membership.statusName, colorHex: membership.color)
                    Text(membership.buyType)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                    Text("(\(membership.buyValue))")
                        .font(.system(size: 12))
                        .foregroundColor(VendorTheme.textSecondary)
                }
                .padding(.top, 4)
            } else {
                Button(action: onBuy) {
                    Text("Buy Membership")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(VendorTheme.accent)
                        .cornerRadius(5)
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }

    private func perk(_ label: String, days: String) -> some View {
        perkRow(label, value: days == "0" ? nil : "\(days) Days")
    }

    private func perk(_ label: String, capacity: String) -> some View {
        perkRow(label, value: capacity == "0" ? nil : "1 to \(capacity) (Max)")
    }

    private func perk(_ label: String, included: String) -> some View {
        perkRow(label, value: included == "0" ? nil : "")
    }

    private func perk(_ label: String, addOnPrice: String) -> some View {
        perkRow(label, value: addOnPrice == "0" ? nil : "Additional AED \(addOnPrice)")
    }

    /// `value == nil` is Android's `ic_cross`; an empty string is its bare `ic_tick`.
    private func perkRow(_ label: String, value: String?) -> some View {
        HStack(spacing: 6) {
            Image(systemName: value == nil ? "xmark" : "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(value == nil ? VendorTheme.negative : VendorTheme.positive)
                .frame(width: 14)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.black)

            Spacer()

            if let value = value, !value.isEmpty {
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(VendorTheme.textSecondary)
            }
        }
    }
}

/// Android `my_membership_custom_row.xml`.
struct VendorMyMembershipCard: View {
    let membership: VendorMyMembership

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(membership.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text("AED \(membership.price)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
            }

            Text(membership.number)
                .font(.system(size: 13))
                .foregroundColor(.black)

            Text(VendorTheme.date(membership.createdAt))
                .font(.system(size: 13))
                .foregroundColor(VendorTheme.textSecondary)

            VendorBadge(name: membership.statusName, colorHex: membership.color)
                .padding(.top, 3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Coupon sheet

/// Android `membership_coupon_dialog.xml`.
struct VendorCouponSheet: View {
    let membershipTitle: String
    @Binding var code: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Coupon Code", onBack: onCancel)

            VStack(alignment: .leading, spacing: 16) {
                Text(membershipTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)

                TextField("Coupon code", text: $code)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(VendorTheme.separator, lineWidth: 1)
                    )

                Button(action: onSubmit) {
                    Text("Apply")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(VendorTheme.accent)
                        .cornerRadius(5)
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VendorTheme.canvas)
        }
    }
}
