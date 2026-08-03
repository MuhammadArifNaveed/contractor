//
//  CartView.swift
//  TheContractor
//
//  The enquiry basket — Android's `Cart` screen with `OrderContactInfo` folded into it.
//
//  This is not a shopping cart. Nothing here is bought: the user collects companies while browsing,
//  says when and where the work is needed and what it involves, and sends the lot as one enquiry
//  through `Home/send_enquiries`. The version this replaces modelled item prices, quantities and a
//  currency total against `Home/get_cart` and `Home/submit_order` — concepts and endpoints that do
//  not exist in this product.
//
//  State lives in ConsumerCartStore; the only calls are Home/check_cart_limit and Home/send_enquiries.
//

import SwiftUI

struct CartView: View {
    @ObservedObject private var store = ConsumerCartStore.shared

    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var sentMessage: String?
    @State private var editing: CartCompany?

    var body: some View {
        VStack(spacing: 0) {
            // Opened from the drawer over the tab bar, like the other consumer screens, so back means
            // "restore the tab bar" rather than popping a navigation stack.
            VendorTopBar(title: "Submit Enquiry", onBack: {
                NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil)
            })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                if store.companies.isEmpty {
                    VendorEmptyState(icon: "tray",
                                     title: "No companies selected",
                                     message: "Browse companies and add the ones you want a quote from, then send them all in one enquiry.")
                } else {
                    content
                }

                if isSubmitting {
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
        .alert("", isPresented: Binding(get: { sentMessage != nil }, set: { _ in sentMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(sentMessage ?? "")
        }
        .sheet(item: $editing) { company in
            CartCompanyDetailsView(company: company,
                                   onSave: { updated in
                                       store.update(updated)
                                       editing = nil
                                   },
                                   onCancel: { editing = nil })
        }
        .onAppear { store.refreshLimit() }
    }

    private var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: VendorTheme.Space.m) {
                    // Android's `cartLimitIssue`: the plan caps how many companies one enquiry can go
                    // to, and submission is blocked until the basket fits.
                    if store.exceedsLimit {
                        HStack(alignment: .top, spacing: VendorTheme.Space.s) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(VendorTheme.negative)
                            Text("Your plan allows \(store.availableLimit). Remove \(store.overLimitBy) to continue.")
                                .font(VendorTheme.Text.meta)
                                .foregroundColor(VendorTheme.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .vendorCard()
                    }

                    ForEach(store.companies) { company in
                        row(company)
                    }
                }
                .padding(VendorTheme.Space.l)
            }

            submitBar
        }
    }

    private func row(_ company: CartCompany) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                AsyncImage(url: VendorTheme.companyLogoURL(company.companyLogo)) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        ZStack {
                            VendorTheme.surfaceRaised
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 16))
                                .foregroundColor(VendorTheme.textTertiary)
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(company.companyName)
                        .font(VendorTheme.Text.cardTitle)
                        .foregroundColor(VendorTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    if !company.categoryName.isEmpty {
                        Text(company.categoryName)
                            .font(VendorTheme.Text.meta)
                            .foregroundColor(VendorTheme.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                Button(action: { store.remove(companyId: company.id) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(VendorTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(VendorTheme.surfaceRaised))
                }
                .buttonStyle(VendorPressStyle())
                .accessibilityLabel("Remove \(company.companyName)")
            }

            if company.isReadyToSubmit {
                VendorField(label: "When", value: VendorTheme.date(company.dateTime))
                VendorField(label: "Where", value: company.location)
                VendorField(label: "Work needed", value: company.description)
            } else {
                HStack(spacing: VendorTheme.Space.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text("Details needed before this can be sent")
                        .font(VendorTheme.Text.meta)
                }
                .foregroundColor(VendorTheme.negative)
            }

            Button(action: { editing = company }) {
                Text(company.isReadyToSubmit ? "Edit details" : "Add details")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textPrimary)
                    .padding(.horizontal, VendorTheme.Space.m)
                    .padding(.vertical, VendorTheme.Space.s)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
                    .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
            }
            .buttonStyle(VendorPressStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var submitBar: some View {
        Button(action: submit) {
            Text("Send enquiry to \(store.count) \(store.count == 1 ? "company" : "companies")")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(store.canSubmit ? VendorTheme.onAccent : VendorTheme.textTertiary)
                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(store.canSubmit ? VendorTheme.accent : VendorTheme.surfaceRaised)
                )
        }
        .buttonStyle(VendorPressStyle())
        .disabled(!store.canSubmit || isSubmitting)
        .padding(VendorTheme.Space.l)
        .background(VendorTheme.surface.ignoresSafeArea(edges: .bottom))
        .overlay(
            Rectangle().fill(VendorTheme.separator).frame(height: 0.5),
            alignment: .top
        )
    }

    private func submit() {
        isSubmitting = true
        store.submit { message, success in
            isSubmitting = false
            if success {
                sentMessage = message.isEmpty ? "Your enquiry has been sent." : message
            } else {
                errorMessage = message.isEmpty ? "Please try again" : message
            }
        }
    }
}

// MARK: - Per-company details

/// The three things Android collects per basket row before it will build the payload: when the work is
/// needed, where, and what it involves. Latitude and longitude travel with the row from wherever the
/// location came from; nothing in the app picks them on a map yet, so they submit empty — the server
/// accepts that, and Android sends the same when its picker is skipped.
struct CartCompanyDetailsView: View {
    let company: CartCompany
    let onSave: (CartCompany) -> Void
    let onCancel: () -> Void

    @State private var when = Date()
    @State private var location = ""
    @State private var details = ""
    @State private var notice: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: company.companyName, onBack: onCancel)

            ScrollView {
                VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        fieldLabel("WHEN IS IT NEEDED")
                        DatePicker("", selection: $when, in: Date()...)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()

                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        fieldLabel("LOCATION")
                        TextField("Building, area, city", text: $location)
                            .font(VendorTheme.Text.body)
                            .padding(VendorTheme.Space.s)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.surfaceRaised)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()

                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        fieldLabel("WORK NEEDED")
                        TextEditor(text: $details)
                            .font(VendorTheme.Text.body)
                            .frame(height: 120)
                            .padding(VendorTheme.Space.xs)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.surfaceRaised)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()

                    Button(action: save) {
                        Text("Save")
                            .font(VendorTheme.Text.cardTitle)
                            .foregroundColor(VendorTheme.onAccent)
                            .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.accent)
                            )
                    }
                    .buttonStyle(VendorPressStyle())
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas.ignoresSafeArea(edges: .bottom))
        }
        .alert("", isPresented: Binding(get: { notice != nil }, set: { _ in notice = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notice ?? "")
        }
        .onAppear {
            location = company.location
            details = company.description
            if let parsed = CartCompanyDetailsView.parse(company.dateTime) { when = parsed }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(VendorTheme.Text.label)
            .foregroundColor(VendorTheme.textTertiary)
            .tracking(0.4)
    }

    private func save() {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            notice = "Enter a location"
            return
        }
        guard !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            notice = "Describe the work needed"
            return
        }
        var updated = company
        updated.dateTime = CartCompanyDetailsView.format(when)
        updated.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.description = details.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(updated)
    }

    /// The backend stores `date_time` as a MySQL datetime string.
    private static func format(_ date: Date) -> String {
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return out.string(from: date)
    }

    private static func parse(_ raw: String) -> Date? {
        guard !raw.isEmpty else { return nil }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return input.date(from: raw)
    }
}
