//
//  VendorDirectHiringView.swift
//  TheContractor
//
//  Android's `VendorDirectHiring` and `VendorDirectHiringDetail`, reached from the vendor jobs
//  dashboard. The company sees everyone it hired directly and moves each of them along the process.
//
//  Not an accept/reject pair, despite how the endpoint name reads: Android's dialog is a five-value
//  status picker — Submitted, Viewed, Shortlisted, interviewed, Selected — sent verbatim as `status`.
//  The lower-case `interviewed` is Android's own spelling and is what goes over the wire.
//
//  Android's detail screen carries a `viewCV` label with no click listener and `ApiUrls` has no CV
//  path, so there is nothing to link a CV to — it is left off rather than invented.
//
//  Android's detail screen fetches nothing; the row is passed straight through from the list, and the
//  only call is the status update. This does the same.
//
//  `jobs/view_direct_hirings` was verified live for the QA company: 24 rows, and no `total_page` in the
//  response — which is why Android's load-more is commented out and this list is single-page.
//

import SwiftUI
import SwiftyJSON

struct VendorDirectHiringView: View {
    @State private var state: VendorLoadState = .loading
    @State private var hirings: [VendorDirectHire] = []
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Direct Hiring", onBack: { dismiss() })

                ZStack {
                    VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        ScrollView { VendorSkeletonList(rows: 4) }
                    case .noData:
                        VendorEmptyState(icon: "person.fill.badge.plus",
                                         title: "No direct hires",
                                         message: "People you hire directly from the applicant list will appear here.",
                                         actionTitle: "Try again",
                                         action: load)
                    case .loaded:
                        list
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
        .onAppear { if hirings.isEmpty { load() } }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.m) {
                ForEach(hirings) { hire in
                    NavigationLink(destination: VendorDirectHireDetailView(hire: hire, onUpdated: load)) {
                        row(hire)
                    }
                    .buttonStyle(VendorPressStyle())
                }
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    private func row(_ hire: VendorDirectHire) -> some View {
        HStack(alignment: .top, spacing: VendorTheme.Space.m) {
            VendorPersonAvatar(path: hire.image)

            VStack(alignment: .leading, spacing: 3) {
                Text(hire.fullName)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                if !hire.categoryTitle.isEmpty {
                    Text(hire.categoryTitle)
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textSecondary)
                }

                Text(VendorTheme.shortDate(hire.createdAt))
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }

            Spacer(minLength: 0)

            VendorDirectHireStatusChip(status: hire.hiringStatus)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Data

    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func load() {
        if hirings.isEmpty { state = .loading }
        fetch()
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            finished?()
            return
        }

        GCD.async(.Background) {
            LoginService.shared().getVendorDirectHirings(vendorId: session.id,
                                                        userId: session.user_id,
                                                        userType: session.user_type,
                                                        page: "1") { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json else {
                        if hirings.isEmpty { state = .noData }
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    hirings = json["direct_hirings"].arrayValue.map(VendorDirectHire.init)
                    state = hirings.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Detail

struct VendorDirectHireDetailView: View {
    let hire: VendorDirectHire
    let onUpdated: () -> Void

    /// Android's `hireDialog()` list, in its order and with its spelling.
    private static let statuses = ["Submitted", "Viewed", "Shortlisted", "interviewed", "Selected"]

    @State private var showingPicker = false
    @State private var chosenStatus = "Submitted"
    @State private var confirmingStatus: String?
    @State private var isUpdating = false
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    /// Shown instead of the row's value once the update lands, so the screen does not lie while the
    /// list behind it refetches.
    @State private var updatedStatus: String?

    @Environment(\.dismiss) private var dismiss

    private var currentStatus: String { updatedStatus ?? hire.hiringStatus }

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Direct Hire", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.m) {
                        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                            HStack(spacing: VendorTheme.Space.m) {
                                VendorPersonAvatar(path: hire.image)
                                    .frame(width: 64, height: 64)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hire.fullName)
                                        .font(VendorTheme.Text.screenTitle)
                                        .foregroundColor(VendorTheme.textPrimary)
                                    if !hire.categoryTitle.isEmpty {
                                        Text(hire.categoryTitle)
                                            .font(VendorTheme.Text.meta)
                                            .foregroundColor(VendorTheme.textSecondary)
                                    }
                                }

                                Spacer(minLength: 0)
                            }

                            VendorDirectHireStatusChip(status: currentStatus)

                            VendorField(label: "Hired", value: VendorTheme.date(hire.createdAt))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .vendorCard()

                        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                            VendorSectionHeader(title: "Contact")
                            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                                VendorField(label: "Phone", value: hire.phone)
                                VendorField(label: "Email", value: hire.email)
                            }
                            if !hire.address.isEmpty {
                                VendorField(label: "Address", value: hire.address)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .vendorCard()

                        Button(action: {
                            chosenStatus = Self.statuses.contains(currentStatus) ? currentStatus : "Submitted"
                            showingPicker = true
                        }) {
                            Text("Update status")
                                .font(VendorTheme.Text.cardTitle)
                                .foregroundColor(VendorTheme.onAccent)
                                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                                .background(
                                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                        .fill(VendorTheme.accent)
                                )
                        }
                        .buttonStyle(VendorPressStyle())
                        .disabled(isUpdating)
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isUpdating {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPicker) {
            statusPicker
        }
        // There is no way back to "no status" once one is set, so the choice is confirmed first.
        .alert("Set status to \(confirmingStatus ?? "")?", isPresented: Binding(get: { confirmingStatus != nil }, set: { if !$0 { confirmingStatus = nil } })) {
            Button("Set") {
                if let status = confirmingStatus { update(to: status) }
                confirmingStatus = nil
            }
            Button("Cancel", role: .cancel) { confirmingStatus = nil }
        }
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
    }

    private var statusPicker: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Hiring status", onBack: { showingPicker = false })

            ScrollView {
                VStack(spacing: VendorTheme.Space.s) {
                    ForEach(Self.statuses, id: \.self) { status in
                        Button(action: {
                            showingPicker = false
                            confirmingStatus = status
                        }) {
                            HStack {
                                Text(status.capitalized)
                                    .font(VendorTheme.Text.body)
                                    .foregroundColor(VendorTheme.textPrimary)
                                Spacer()
                                if status == currentStatus {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(VendorTheme.textSecondary)
                                }
                            }
                            .frame(minHeight: VendorTheme.minTapTarget)
                            .padding(.horizontal, VendorTheme.Space.m)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.surface)
                            )
                        }
                        .buttonStyle(VendorPressStyle())
                    }
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas.ignoresSafeArea(edges: .bottom))
        }
    }

    private func update(to status: String) {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            errorMessage = "Sign in again to update this"
            return
        }

        isUpdating = true
        GCD.async(.Background) {
            LoginService.shared().updateDirectHiringStatus(vendorId: session.id,
                                                          hiringId: hire.hiringId,
                                                          status: status) { message, success in
                GCD.async(.Main) {
                    isUpdating = false
                    if success {
                        updatedStatus = status
                        noticeMessage = message.isEmpty ? "Status updated." : message
                        onUpdated()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Pieces

/// `hiring_status` comes back empty until the company sets one, which reads as a gap in the row rather
/// than a state, so it is labelled.
struct VendorDirectHireStatusChip: View {
    let status: String

    var body: some View {
        Text(status.isEmpty ? "No status" : status.capitalized)
            .font(VendorTheme.Text.badge)
            .foregroundColor(status.isEmpty ? VendorTheme.textSecondary : VendorTheme.onAccent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(status.isEmpty ? VendorTheme.surfaceRaised : VendorTheme.accent)
            )
    }
}

// MARK: - Model

struct VendorDirectHire: Identifiable {
    let hiringId: String
    let hiringStatus: String
    let createdAt: String
    let name: String
    let surname: String
    let categoryTitle: String
    let phone: String
    let email: String
    let address: String
    let image: String

    var id: String { hiringId }

    var fullName: String {
        let joined = [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
        return joined.isEmpty ? "Applicant" : joined
    }

    init(_ json: JSON) {
        self.hiringId = json["hiring_id"].stringValue
        self.hiringStatus = json["hiring_status"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.categoryTitle = json["category_title"].stringValue
        self.phone = json["phone"].stringValue
        self.email = json["email"].stringValue
        self.address = json["address"].stringValue
        self.image = json["image"].stringValue
    }
}
