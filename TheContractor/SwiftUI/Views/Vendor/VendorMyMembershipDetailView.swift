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
            }
        }
        .navigationBarHidden(true)
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
                        value: membership.workshopIncluded.lowercased() == "yes"
                            ? "Included (AED \(membership.workshopPrice))"
                            : "Not included")
            if !membership.detail.isEmpty {
                VendorField(label: "Type", value: membership.detail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }
}
