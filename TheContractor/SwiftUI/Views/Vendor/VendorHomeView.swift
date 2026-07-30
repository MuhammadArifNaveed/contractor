//
//  VendorHomeView.swift
//  TheContractor
//
//  Company (vendor) landing screen — Android's `VendorHome`. The data contract comes straight from
//  `VendorHome.vendorDashBoardAPI()`: POST vendor/dashboard returning `vendor_dashboard_counts`,
//  `pending_enquiries`, `accepted_enquiries` and `today_enquiries`, with each enquiry section hidden
//  when its array is empty.
//
//  The presentation is not a copy of `content_vendor_home.xml` — see VendorTheme.swift for why.
//
//  This file also holds the pieces the other vendor screens reuse: the shared load state, the
//  status/enquiry models, the two card styles, and the top bar.
//

import SwiftUI
import SwiftyJSON

struct VendorHomeView: View {

    @State private var state: VendorLoadState = .loading
    @State private var dashboardCounts: [VendorDashboardCount] = []
    @State private var pendingEnquiries: [VendorEnquiryRow] = []
    @State private var acceptedEnquiries: [VendorEnquiryRow] = []
    @State private var todayEnquiries: [VendorEnquiryRow] = []
    @State private var errorMessage: String?

    private var companyName: String { VendorSession.current?.company_name ?? "" }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: companyName.isEmpty ? "Dashboard" : companyName)

                ZStack {
                    VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        ScrollView { VendorSkeletonGrid(tiles: 4) }
                    case .noData:
                        VendorEmptyState(icon: "tray",
                                         title: "Nothing to show yet",
                                         message: "Your enquiry dashboard will fill in as customers get in touch.",
                                         actionTitle: "Try again",
                                         action: loadDashboard)
                    case .loaded:
                        content
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
        .onAppear(perform: loadDashboard)
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: VendorTheme.Space.xl) {
                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "Enquiries")

                    // Two columns rather than Android's three: the status names ("Completed",
                    // "Accepted") no longer truncate and the tiles clear the 44pt tap target.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: VendorTheme.Space.m), count: 2),
                              spacing: VendorTheme.Space.m) {
                        ForEach(dashboardCounts) { count in
                            NavigationLink(destination: VendorParticularEnquiriesView(status: count)) {
                                VendorDashboardCountCard(count: count)
                            }
                            .buttonStyle(VendorPressStyle())
                        }
                    }
                }

                if !pendingEnquiries.isEmpty {
                    section("Pending", pendingEnquiries, horizontal: true)
                }

                if !acceptedEnquiries.isEmpty {
                    section("Accepted", acceptedEnquiries, horizontal: true)
                }

                if !todayEnquiries.isEmpty {
                    section("Today", todayEnquiries, horizontal: false)
                }
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    private func section(_ title: String, _ rows: [VendorEnquiryRow], horizontal: Bool) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: title, count: rows.count)

            if horizontal {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                        ForEach(rows) { enquiry in
                            NavigationLink(destination: VendorEnquiryDetailView(enquiryId: enquiry.id)) {
                                VendorEnquiryRowCard(enquiry: enquiry)
                                    .frame(width: 210)
                            }
                            .buttonStyle(VendorPressStyle())
                        }
                    }
                    // Let cards clear the section's own padding when scrolled.
                    .padding(.horizontal, 1)
                }
            } else {
                VStack(spacing: VendorTheme.Space.m) {
                    ForEach(rows) { enquiry in
                        NavigationLink(destination: VendorEnquiryDetailView(enquiryId: enquiry.id)) {
                            VendorEnquiryRowCard(enquiry: enquiry)
                        }
                        .buttonStyle(VendorPressStyle())
                    }
                }
            }
        }
    }

    // MARK: - Data (VendorHome.vendorDashBoardAPI)

    private func loadDashboard() {
        guard !VendorSession.currentVendorId.isEmpty else {
            state = .noData
            return
        }
        if dashboardCounts.isEmpty { state = .loading }
        fetch()
    }

    /// `.refreshable` needs an async boundary; the service layer is callback-based.
    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        let vendorId = VendorSession.currentVendorId
        GCD.async(.Background) {
            LoginService.shared().getVendorDashboard(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }

                    dashboardCounts = json["vendor_dashboard_counts"].arrayValue.map(VendorDashboardCount.init)
                    pendingEnquiries = json["pending_enquiries"].arrayValue.map(VendorEnquiryRow.init)
                    acceptedEnquiries = json["accepted_enquiries"].arrayValue.map(VendorEnquiryRow.init)
                    todayEnquiries = json["today_enquiries"].arrayValue.map(VendorEnquiryRow.init)
                    state = .loaded
                }
            }
        }
    }
}

// MARK: - Shared load state

/// Android's three-way screen state: progress dialog, `noData` label, or the populated layout.
enum VendorLoadState {
    case loading
    case loaded
    case noData
}

// MARK: - Models

/// Android `VendorDashboardCountModel`. `count` arrives as a JSON number on some rows and a string
/// on others, and `id` is sometimes `"all"` — so both go through `stringValue`.
struct VendorDashboardCount: Identifiable, Hashable {
    let id: String
    let name: String
    let count: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.count = json["count"].stringValue
    }
}

/// Android `VendorEnquiryModel` — the fields `VendorEnquiriesAdapter` binds.
struct VendorEnquiryRow: Identifiable {
    let id: String
    let enquiryNumber: String
    let statusName: String
    let color: String
    let createdAt: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.enquiryNumber = json["enquiry_number"].stringValue
        self.statusName = json["s_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
    }
}

// MARK: - Cards

/// The count tile. Android stacks name / count / "See All" centred in a square; a left-aligned
/// metric with a chevron reads faster and gives the number room to be the focal point.
struct VendorDashboardCountCard: View {
    let count: VendorDashboardCount

    var body: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text(count.name)
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(count.count)
                .font(VendorTheme.Text.metric)
                .foregroundColor(VendorTheme.textPrimary)

            HStack(spacing: 3) {
                Text("See all")
                    .font(VendorTheme.Text.meta)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundColor(VendorTheme.accent)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .vendorCard()
    }
}

/// Android `vendor_enquiry_custom_row.xml` — enquiry number, date, and the API-coloured status pill.
struct VendorEnquiryRowCard: View {
    let enquiry: VendorEnquiryRow

    var body: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
            HStack(alignment: .top) {
                Text(enquiry.enquiryNumber)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: VendorTheme.Space.s)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(VendorTheme.textTertiary)
            }

            Text(VendorTheme.date(enquiry.createdAt))
                .font(VendorTheme.Text.meta)
                .foregroundColor(VendorTheme.textSecondary)

            VendorBadge(name: enquiry.statusName, colorHex: enquiry.color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }
}

// MARK: - Interaction

/// A restrained press response. `PlainButtonStyle` gives no feedback at all, which makes the cards
/// feel dead; the default `NavigationLink` styling tints the whole card blue.
struct VendorPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Top bar

/// The yellow action bar every vendor screen carries. Drawer-rooted screens leave `onBack` nil and
/// get the hamburger, matching Android's `ActionBarDrawerToggle`; pushed screens pass a dismiss
/// closure and get the back chevron.
struct VendorTopBar: View {
    private let title: String
    private let onBack: (() -> Void)?
    private let trailingIcon: String?
    private let trailingAction: (() -> Void)?

    init(title: String,
         onBack: (() -> Void)? = nil,
         trailingIcon: String? = nil,
         trailingAction: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
    }

    var body: some View {
        HStack(spacing: 2) {
            Button(action: tapLeading) {
                Image(systemName: onBack == nil ? "line.3.horizontal" : "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(VendorTheme.onAccent)
                    .frame(width: VendorTheme.minTapTarget, height: VendorTheme.minTapTarget)
            }

            Text(title)
                .font(VendorTheme.Text.screenTitle)
                .foregroundColor(VendorTheme.onAccent)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.leading, VendorTheme.Space.xs)

            Spacer(minLength: VendorTheme.Space.s)

            if let trailingIcon = trailingIcon, let trailingAction = trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(VendorTheme.onAccent)
                        .frame(width: VendorTheme.minTapTarget, height: VendorTheme.minTapTarget)
                }
            }
        }
        .padding(.horizontal, VendorTheme.Space.s)
        .frame(height: 56)
        // The bar has to own the status bar area too, otherwise the yellow behind the clock and the
        // yellow of the bar render as two disconnected bands with a white seam between them.
        .background(VendorTheme.accent.ignoresSafeArea(edges: .top))
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    private func tapLeading() {
        if let onBack = onBack {
            onBack()
        } else {
            VendorNavigation.openDrawer()
        }
    }
}

// MARK: - Navigation helpers

enum VendorNavigation {
    /// The vendor screens live inside the KYDrawerController, but the shared yellow top bar is
    /// hidden for companies, so each vendor screen owns its own hamburger.
    static func openDrawer() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        for window in scene.windows {
            if let drawer = findDrawer(from: window.rootViewController) {
                drawer.setDrawerState(.opened, animated: true)
                return
            }
        }
    }

    private static func findDrawer(from controller: UIViewController?) -> KYDrawerController? {
        guard let controller = controller else { return nil }
        if let drawer = controller as? KYDrawerController { return drawer }
        for child in controller.children {
            if let found = findDrawer(from: child) { return found }
        }
        return findDrawer(from: controller.presentedViewController)
    }
}

struct VendorHomeView_Previews: PreviewProvider {
    static var previews: some View {
        VendorHomeView()
    }
}
