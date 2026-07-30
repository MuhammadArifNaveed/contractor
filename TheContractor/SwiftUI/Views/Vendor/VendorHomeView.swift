//
//  VendorHomeView.swift
//  TheContractor
//
//  Company (vendor) landing screen. Direct port of Android's `VendorHome` activity —
//  `content_vendor_home.xml` for the layout, `VendorHome.vendorDashBoardAPI()` for the data,
//  `VendorEnquiriesDashboardAdapter` / `VendorEnquiriesAdapter` for the two card styles.
//
//  This file also holds the pieces the other vendor enquiry screens reuse: the status/enquiry
//  models, the two card styles, the section heading, and the Android colour helpers.
//

import SwiftUI
import SwiftyJSON

struct VendorHomeView: View {

    // Android keeps `vendorHomeLayout` hidden until the API answers and only shows `noData`
    // when the response comes back with error == true.
    @State private var state: VendorLoadState = .loading
    @State private var dashboardCounts: [VendorDashboardCount] = []
    @State private var pendingEnquiries: [VendorEnquiryRow] = []
    @State private var acceptedEnquiries: [VendorEnquiryRow] = []
    @State private var todayEnquiries: [VendorEnquiryRow] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                toolbar

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

    // MARK: - Toolbar (app_bar_vendor.xml: yellow bar, drawer toggle, topicon logo)

    private var toolbar: some View {
        HStack(spacing: 12) {
            Button(action: VendorNavigation.openDrawer) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 32, height: 32)

            // Android's toolbar uses @drawable/topicon; the iOS asset catalog ships this as "logo".
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 34)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(VendorHomeStyle.appColor)
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                VendorSection(title: "Enquiries Dashboard") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                              spacing: 4) {
                        ForEach(dashboardCounts) { count in
                            NavigationLink(destination: VendorParticularEnquiriesView(status: count)) {
                                VendorDashboardCountCard(count: count)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                if !pendingEnquiries.isEmpty {
                    VendorSection(title: "Pending Enquiries") {
                        horizontalEnquiries(pendingEnquiries)
                    }
                }

                if !acceptedEnquiries.isEmpty {
                    VendorSection(title: "Accepted Enquiries") {
                        horizontalEnquiries(acceptedEnquiries)
                    }
                }

                if !todayEnquiries.isEmpty {
                    VendorSection(title: "Today Enquiries") {
                        VStack(spacing: 10) {
                            ForEach(todayEnquiries) { enquiry in
                                NavigationLink(destination: VendorEnquiryDetailView(enquiryId: enquiry.id)) {
                                    VendorEnquiryRowCard(enquiry: enquiry)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
    }

    private func horizontalEnquiries(_ enquiries: [VendorEnquiryRow]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(enquiries) { enquiry in
                    NavigationLink(destination: VendorEnquiryDetailView(enquiryId: enquiry.id)) {
                        VendorEnquiryRowCard(enquiry: enquiry)
                            .frame(width: 190)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Data (VendorHome.vendorDashBoardAPI)

    private func loadDashboard() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorDashboard(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
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

/// Android `VendorDashboardCountModel`. `count` arrives as a JSON number on some rows and a
/// string on others, so read it through `stringValue`.
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

/// Android `VendorEnquiryModel` — the fields `VendorEnquiriesAdapter` actually binds.
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

// MARK: - Section heading

/// Android's repeated `heading + heading_line_bacground + RecyclerView` block.
struct VendorSection<Content: View>: View {
    private let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)

            RoundedRectangle(cornerRadius: 2.5)
                .fill(VendorHomeStyle.appColor)
                .frame(width: 20, height: 2)
                .padding(.top, 2)

            content
                .padding(.top, 10)
        }
    }
}

// MARK: - Cards

/// Android `vendor_dashboard_row.xml` — a SquareLayout card holding name / count / "See All".
struct VendorDashboardCountCard: View {
    let count: VendorDashboardCount

    var body: some View {
        VStack(spacing: 2) {
            // Android's statusName is wrap_content inside a SquareLayout, so longer labels such as
            // "Completed" wrap rather than truncate.
            Text(count.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)

            Text(count.count)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)

            Text("See All")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.top, 5)
        }
        .padding(4)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

/// Android `vendor_enquiry_custom_row.xml` — enquiry number, formatted date, and a status
/// badge filled with the colour the API sends down for that status.
struct VendorEnquiryRowCard: View {
    let enquiry: VendorEnquiryRow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(enquiry.enquiryNumber)
                .font(.system(size: 14))
                .foregroundColor(.black)

            Text(VendorHomeStyle.formatDate(enquiry.createdAt))
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.4))

            VendorStatusBadge(name: enquiry.statusName, color: enquiry.color)
                .padding(.top, 5)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}

/// The rounded, API-coloured status pill Android builds with a `MaterialShapeDrawable`.
struct VendorStatusBadge: View {
    let name: String
    let color: String

    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(VendorHomeStyle.color(from: color))
            )
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

// MARK: - Style

/// The handful of Android resources the vendor screens depend on: `@color/appColor` (#f2be36),
/// `@color/background` (#f7f7f7), the per-status colours the API returns, and the date format.
enum VendorHomeStyle {
    static let appColor = Color(red: 242 / 255, green: 190 / 255, blue: 54 / 255)
    static let background = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)

    /// `Color.parseColor()` equivalent for the `#rrggbb` / `#aarrggbb` strings the API sends.
    /// Android throws on a malformed value; here an unusable colour just falls back to grey.
    static func color(from hex: String) -> Color {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }

        guard let number = UInt64(value, radix: 16) else { return Color(white: 0.45) }

        let r, g, b, a: Double
        switch value.count {
        case 6:
            r = Double((number & 0xFF0000) >> 16) / 255
            g = Double((number & 0x00FF00) >> 8) / 255
            b = Double(number & 0x0000FF) / 255
            a = 1
        case 8:
            a = Double((number & 0xFF00_0000) >> 24) / 255
            r = Double((number & 0x00FF_0000) >> 16) / 255
            g = Double((number & 0x0000_FF00) >> 8) / 255
            b = Double(number & 0x0000_00FF) / 255
        default:
            return Color(white: 0.45)
        }

        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Literal port of `VendorEnquiriesAdapter.parseDateToddMMyyyy()`, including its swapped
    /// day/month input pattern — matching Android's on-screen output matters more than being right.
    static func formatDate(_ time: String) -> String {
        reformat(time, from: "yyyy-dd-MM HH:mm:ss")
    }

    /// The workshop adapters use the same output pattern but parse the input correctly as
    /// `yyyy-MM-dd`, so they need their own entry point.
    static func formatWorkshopDate(_ time: String) -> String {
        reformat(time, from: "yyyy-MM-dd HH:mm:ss")
    }

    private static func reformat(_ time: String, from inputPattern: String) -> String {
        guard !time.isEmpty else { return "" }

        let input = DateFormatter()
        input.dateFormat = inputPattern
        input.locale = Locale(identifier: "en_US_POSIX")

        guard let date = input.date(from: time) else { return time }

        let output = DateFormatter()
        output.dateFormat = "yyyy-dd-MM h:mm a"
        output.locale = Locale(identifier: "en_US_POSIX")
        return output.string(from: date)
    }

    /// `ApiUrls.WORKSHOP_IMAGE_URL`.
    static func workshopImageURL(_ path: String) -> URL? {
        guard !path.isEmpty else { return nil }
        return URL(string: "https://contractor.bidcont.com/uploads/workshop/" + path)
    }
}

struct VendorHomeView_Previews: PreviewProvider {
    static var previews: some View {
        VendorHomeView()
    }
}
