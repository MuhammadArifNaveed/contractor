//
//  VendorMyMembershipDetailView.swift
//  TheContractor
//
//  Port of Android's `activity_vendor_my_membership_detail`. No API call: every field is already in
//  the `vendor/my_memberships` row, so the list passes the record straight through.
//
//  The usage meters are the addition over Android, which prints the raw
//  "used / capacity" numbers as plain text.
//

import SwiftUI

struct VendorMyMembershipDetailView: View {
    let membership: VendorMyMembership

    @Environment(\.dismiss) private var dismiss

    @State private var showCouponSheet = false
    @State private var couponCode = ""
    @State private var isBuying = false
    @State private var noticeMessage: String?
    /// Flipped locally on a successful purchase. The list this screen was pushed from holds the record,
    /// and re-fetching it would mean backing out — so the card reflects the change and the list catches
    /// up on its next load.
    @State private var addOnJustBought = false

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Membership", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.l) {
                        headerCard
                        usageCard
                        windowsCard
                        purchaseCard
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isBuying {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .sheet(isPresented: $showCouponSheet) {
            VendorCouponSheet(membershipTitle: "Workshop add-on", code: $couponCode) {
                showCouponSheet = false
                redeemWorkshopCoupon()
            } onCancel: {
                showCouponSheet = false
                couponCode = ""
            }
        }
    }

    /// Android puts a "Buy now in AED <price>" button on this screen whenever the add-on is not already
    /// owned. Only the coupon half is offered here; the card half needs the gateway iOS does not have.
    private var hasAddOn: Bool {
        addOnJustBought || membership.workshopIncluded.lowercased() == "yes"
    }

    private func redeemWorkshopCoupon() {
        let code = couponCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            noticeMessage = "Enter coupon code"
            return
        }
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isBuying = true
        GCD.async(.Background) {
            LoginService.shared().buyWorkshopMembershipByCoupon(vendorId: vendorId,
                                                                membershipId: membership.id,
                                                                couponCode: code) { message, success in
                GCD.async(.Main) {
                    isBuying = false
                    couponCode = ""
                    noticeMessage = message.isEmpty
                        ? (success ? "Workshop add-on activated." : "Please try again")
                        : message
                    if success { addOnJustBought = true }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(membership.title)
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: VendorTheme.Space.s)
                Text("AED \(membership.price)")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
            }

            VendorBadge(name: membership.statusName, colorHex: membership.color)

            if !membership.number.isEmpty {
                Text(membership.number)
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var usageCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Usage")
            meter(title: "Leads", used: membership.leadsUsed, capacity: membership.leadsCapacity)
            meter(title: "Quotations", used: membership.quotationsUsed, capacity: membership.quotationsCapacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    /// A bar rather than Android's bare numbers — "3 of 16" is easier to read as a proportion.
    private func meter(title: String, used: String, capacity: String) -> some View {
        let usedValue = Double(used) ?? 0
        let capacityValue = Double(capacity) ?? 0
        let fraction = capacityValue > 0 ? min(usedValue / capacityValue, 1) : 0
        let exhausted = capacityValue > 0 && usedValue >= capacityValue

        return VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            HStack {
                Text(title)
                    .font(VendorTheme.Text.body)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: 0)
                Text(capacityValue > 0 ? "\(used) of \(capacity)" : used)
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(exhausted ? VendorTheme.negative : VendorTheme.textSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(VendorTheme.surfaceRaised)
                    Capsule()
                        .fill(exhausted ? VendorTheme.negative : VendorTheme.accent)
                        .frame(width: max(geometry.size.width * fraction, fraction > 0 ? 6 : 0))
                }
            }
            .frame(height: 6)
        }
    }

    private var windowsCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Listing windows")
            window(title: "Top 10", start: membership.topTenStart, expiry: membership.topTenExpiry)
            window(title: "Top 20", start: membership.topTwentyStart, expiry: membership.topTwentyExpiry)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func window(title: String, start: String, expiry: String) -> some View {
        HStack(alignment: .top, spacing: VendorTheme.Space.m) {
            VendorField(label: "\(title) from",
                        value: start.isEmpty ? "Not started" : VendorTheme.shortDate(start))
            VendorField(label: "\(title) until",
                        value: expiry.isEmpty ? "—" : VendorTheme.shortDate(expiry))
        }
    }

    private var purchaseCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Purchase")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Bought on", value: VendorTheme.shortDate(membership.createdAt))
                VendorField(label: "Paid by", value: membership.buyType.isEmpty ? "—" : membership.buyType)
            }
            if !membership.couponCode.isEmpty {
                VendorField(label: "Coupon", value: membership.couponCode)
            }
            VendorField(label: "Workshop add-on",
                        value: hasAddOn
                            ? "Included (AED \(membership.workshopPrice))"
                            : "Not included")

            if !hasAddOn {
                Button(action: {
                    couponCode = ""
                    showCouponSheet = true
                }) {
                    Text(membership.workshopPrice.isEmpty
                         ? "Add with a coupon"
                         : "Add with a coupon — AED \(membership.workshopPrice)")
                        .font(VendorTheme.Text.label)
                        .foregroundColor(VendorTheme.onAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VendorTheme.Space.m)
                        .background(VendorTheme.accent)
                        .cornerRadius(VendorTheme.Radius.control)
                }
            }
            if !membership.detail.isEmpty {
                VendorField(label: "Type", value: membership.detail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }
}
