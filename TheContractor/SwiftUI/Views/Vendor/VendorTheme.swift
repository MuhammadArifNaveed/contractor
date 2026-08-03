//
//  VendorTheme.swift
//  TheContractor
//
//  The design system for the company (vendor) side.
//
//  The vendor screens started as a literal port of Android's 2021 Material layouts — 14sp bold
//  headings, 5dp corners, flat white boxes, hairline dividers. Faithful, and dated on iOS. The rule
//  from here on:
//
//    Data, behaviour, terminology and state transitions -> identical to Android.
//    Layout, type, spacing, colour, motion and empty states -> iOS-native and better.
//
//  So endpoint names, which fields a screen shows, the status colours the API sends, and the
//  validation wording are all locked. Everything visual below is ours.
//

import SwiftUI

// MARK: - Tokens

enum VendorTheme {

    /// Brand accent. The one value carried over unchanged from Android (`@color/appColor`).
    static let accent = Color(red: 242 / 255, green: 190 / 255, blue: 54 / 255)

    /// Foreground for anything drawn on `accent`. The accent is a light yellow, so white text on it
    /// fails contrast — Android uses white throughout and it is genuinely hard to read.
    static let onAccent = Color(red: 26 / 255, green: 20 / 255, blue: 0)

    // MARK: Colours
    //
    // Resolved through UIColor so every surface has a real dark-mode value. Android is light-only;
    // matching that would mean a white-on-white app for anyone in dark mode.

    /// Page background behind cards.
    static let canvas = dynamic(light: 0xF4F4F6, dark: 0x0E0E10)
    /// Card and row surface.
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x1C1C1F)
    /// Slightly raised surface, for nested content.
    static let surfaceRaised = dynamic(light: 0xFAFAFB, dark: 0x26262A)
    /// Hairlines and dividers.
    static let separator = dynamic(light: 0xE4E4E8, dark: 0x33333A)

    static let textPrimary = dynamic(light: 0x111114, dark: 0xF2F2F4)
    static let textSecondary = dynamic(light: 0x62636B, dark: 0x9B9CA5)
    static let textTertiary = dynamic(light: 0x8E8F98, dark: 0x6E6F78)

    static let positive = dynamic(light: 0x009C53, dark: 0x2FBE7A)
    static let negative = dynamic(light: 0xD51F1F, dark: 0xF2635C)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? rgb(dark) : rgb(light) })
    }

    private static func rgb(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1)
    }

    // MARK: Type
    //
    // Relative to the user's text size so Dynamic Type works — Android's fixed 12/14sp does not
    // scale for anyone who needs it larger.

    enum Text {
        static let screenTitle = Font.system(.title3, design: .rounded).weight(.semibold)
        static let sectionTitle = Font.system(.headline, design: .rounded).weight(.semibold)
        static let cardTitle = Font.system(.subheadline).weight(.semibold)
        static let metric = Font.system(.title2, design: .rounded).weight(.bold)
        static let body = Font.system(.subheadline)
        static let label = Font.system(.caption).weight(.semibold)
        static let meta = Font.system(.caption)
        static let badge = Font.system(.caption2).weight(.bold)
    }

    // MARK: Metrics

    enum Space {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 14
        static let badge: CGFloat = 7
        static let control: CGFloat = 10
    }

    /// Minimum comfortable tap target. Android's 5dp-padded cards fall well under this.
    static let minTapTarget: CGFloat = 44
}

// MARK: - Card surface

private struct VendorCardModifier: ViewModifier {
    var padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.card, style: .continuous)
                    .fill(VendorTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.card, style: .continuous)
                    .stroke(VendorTheme.separator, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

extension View {
    /// The one card treatment for the whole vendor side. Replaces the
    /// `.padding(12).background(.white).cornerRadius(5).shadow(...)` that was copy-pasted into nine
    /// separate files.
    func vendorCard(padding: CGFloat = VendorTheme.Space.m) -> some View {
        modifier(VendorCardModifier(padding: padding))
    }
}

// MARK: - Section header

/// Replaces Android's `heading + heading_line_bacground` pair. Same information, given room to
/// breathe, with an optional trailing count.
struct VendorSectionHeader: View {
    let title: String
    var count: Int?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: VendorTheme.Space.s) {
            Text(title)
                .font(VendorTheme.Text.sectionTitle)
                .foregroundColor(VendorTheme.textPrimary)

            if let count = count, count > 0 {
                Text("\(count)")
                    .font(VendorTheme.Text.badge)
                    .foregroundColor(VendorTheme.textSecondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
                    .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Status badge

/// The status pill Android builds with a `MaterialShapeDrawable`. The API-provided colour is
/// preserved exactly; only the shape and the text contrast are ours.
struct VendorBadge: View {
    let name: String
    let colorHex: String

    var body: some View {
        let fill = VendorTheme.color(fromHex: colorHex)
        Text(name)
            .font(VendorTheme.Text.badge)
            .foregroundColor(VendorTheme.readableForeground(on: fill))
            .lineLimit(1)
            .padding(.horizontal, VendorTheme.Space.s)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.badge, style: .continuous)
                    .fill(fill)
            )
    }
}

// MARK: - Field row

/// A labelled value, used all over the detail screens.
struct VendorField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)

            Text(value.isEmpty ? "—" : value)
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Empty state

/// Replaces Android's bare "Data Not Found" label with something that says what is going on and,
/// where there is one, offers a way forward.
struct VendorEmptyState: View {
    let icon: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: VendorTheme.Space.m) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .light))
                .foregroundColor(VendorTheme.textTertiary)

            VStack(spacing: VendorTheme.Space.xs) {
                Text(title)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                if let message = message {
                    Text(message)
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(VendorTheme.Text.cardTitle)
                        .foregroundColor(VendorTheme.textPrimary)
                        .padding(.horizontal, VendorTheme.Space.l)
                        .padding(.vertical, VendorTheme.Space.s)
                        .background(Capsule().fill(VendorTheme.accent))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(VendorTheme.Space.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Skeleton loading

/// A shimmering placeholder. Reads as "content is arriving" rather than the indeterminate spinner
/// Android shows, which gives no hint of what is coming.
struct VendorSkeleton: View {
    var height: CGFloat = 14
    var width: CGFloat? = nil

    @State private var shift: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(VendorTheme.surfaceRaised)
            .frame(width: width, height: height)
            .overlay(
                LinearGradient(colors: [.clear, VendorTheme.separator.opacity(0.7), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .offset(x: shift * 160)
            )
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    shift = 1
                }
            }
    }
}

/// Card-shaped skeleton for list screens.
struct VendorSkeletonList: View {
    var rows: Int = 4

    var body: some View {
        VStack(spacing: VendorTheme.Space.m) {
            ForEach(0..<rows, id: \.self) { _ in
                VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
                    VendorSkeleton(height: 15, width: 150)
                    VendorSkeleton(height: 12, width: 90)
                    VendorSkeleton(height: 20, width: 70)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()
            }
        }
        .padding(VendorTheme.Space.l)
    }
}

/// A screen for a feature that is genuinely not built yet, so the drawer says so plainly rather than
/// opening something wired to the wrong endpoint.
struct VendorComingSoonView: View {
    let title: String
    let icon: String
    let headline: String
    let detail: String

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: title)

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)
                VendorEmptyState(icon: icon, title: headline, message: detail)
            }
        }
        .navigationBarHidden(true)
    }
}

/// Compact spinner for work in flight over content that is already on screen — a mutation behind a
/// dimmed overlay, or an infinite-scroll footer. A page skeleton would be wrong in both places,
/// because the content it would stand in for is already visible.
struct VendorBusyIndicator: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: VendorTheme.accent))
            .padding(VendorTheme.Space.m)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                    .fill(VendorTheme.surface)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 3)
    }
}

/// Grid-shaped skeleton for the count dashboards.
struct VendorSkeletonGrid: View {
    var tiles: Int = 4

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: VendorTheme.Space.m), count: 2),
                  spacing: VendorTheme.Space.m) {
            ForEach(0..<tiles, id: \.self) { _ in
                VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
                    VendorSkeleton(height: 13, width: 70)
                    VendorSkeleton(height: 26, width: 46)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()
            }
        }
        .padding(VendorTheme.Space.l)
    }
}

// MARK: - Colour helpers

extension VendorTheme {

    /// `Color.parseColor()` equivalent for the `#rrggbb` / `#aarrggbb` strings the API returns for
    /// each status. Android throws on a malformed value; an unusable colour falls back to grey here.
    static func color(fromHex hex: String) -> Color {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }

        guard let number = UInt64(value, radix: 16) else { return Color(white: 0.45) }

        switch value.count {
        case 6:
            return Color(.sRGB,
                         red: Double((number & 0xFF0000) >> 16) / 255,
                         green: Double((number & 0x00FF00) >> 8) / 255,
                         blue: Double(number & 0x0000FF) / 255,
                         opacity: 1)
        case 8:
            return Color(.sRGB,
                         red: Double((number & 0x00FF_0000) >> 16) / 255,
                         green: Double((number & 0x0000_FF00) >> 8) / 255,
                         blue: Double(number & 0x0000_00FF) / 255,
                         opacity: Double((number & 0xFF00_0000) >> 24) / 255)
        default:
            return Color(white: 0.45)
        }
    }

    /// Black or white, whichever stays legible on the given fill. The API hands back some very light
    /// status colours, and Android draws white on all of them regardless.
    static func readableForeground(on fill: Color) -> Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(fill).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.65 ? Color.black.opacity(0.85) : .white
    }

    /// `ApiUrls.WORKSHOP_IMAGE_URL`, `PROFILE_IMAGE_URL`, `QUOTATION_IMAGE_URL`.
    private static let uploads = "https://contractor.bidcont.com/uploads/"

    static func workshopImageURL(_ path: String) -> URL? { uploadURL("workshop/", path) }
    static func companyLogoURL(_ path: String) -> URL? { uploadURL("companies/", path) }
    static func profileImageURL(_ path: String) -> URL? { uploadURL("users/", path) }
    static func quotationImageURL(_ path: String) -> URL? { uploadURL("quotations/", path) }

    private static func uploadURL(_ folder: String, _ path: String) -> URL? {
        guard !path.isEmpty else { return nil }
        // Some models absolutise the path themselves before it reaches a view (CompanyViewModel does),
        // so prefixing again would produce a URL that 404s.
        if path.hasPrefix("http") { return URL(string: path) }
        return URL(string: uploads + folder + path)
    }
}

// MARK: - Dates

extension VendorTheme {

    /// Android's `parseDateToddMMyyyy` reads `yyyy-dd-MM HH:mm:ss` on the enquiry/quotation rows and
    /// `yyyy-MM-dd HH:mm:ss` on the workshop rows, then prints `yyyy-dd-MM h:mm a` for both — which
    /// puts the day where the month belongs. Since the on-screen string is ours to choose, this
    /// formats correctly and readably instead, trying both input orders.
    static func date(_ raw: String) -> String {
        guard let parsed = parse(raw) else { return raw }
        let out = DateFormatter()
        out.locale = .current
        out.dateFormat = "d MMM yyyy, h:mm a"
        return out.string(from: parsed)
    }

    /// Short form for dense rows.
    static func shortDate(_ raw: String) -> String {
        guard let parsed = parse(raw) else { return raw }
        let out = DateFormatter()
        out.locale = .current
        out.dateFormat = "d MMM yyyy"
        return out.string(from: parsed)
    }

    private static func parse(_ raw: String) -> Date? {
        guard !raw.isEmpty else { return nil }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        // Real order first; the enquiry adapter's swapped order second.
        for pattern in ["yyyy-MM-dd HH:mm:ss", "yyyy-dd-MM HH:mm:ss"] {
            input.dateFormat = pattern
            if let date = input.date(from: raw) { return date }
        }
        return nil
    }
}


// MARK: - Sheet identity

/// `.sheet(item:)` needs an Identifiable, and the id-driven detail screens pass a plain String id.
/// Conforming String is the smallest way to express that without a wrapper type per screen.
extension String: Identifiable {
    public var id: String { self }
}
