//
//  VendorWorkshopDetailView.swift
//  TheContractor
//
//  Port of Android's `VendorWorkshopDetail` / `VendorInterestedWorkshopDetail` — one screen behind
//  all three workshop lists (My Workshops, All Workshops, Interested Workshops), which until now
//  had no destination at all.
//
//  POST workshop/get_workshop_details → `workshop_details`, carrying the ad plus its `images` and
//  the `quotations` placed on it. Companies can add their own quotation via
//  POST workshop/add_workshop_quotation.
//

import SwiftUI
import SwiftyJSON

struct VendorWorkshopDetailView: View {
    let workshopId: String
    /// True on the All Workshops list, where placing a bid is the point of opening the ad.
    var allowsQuotation: Bool = false

    @State private var state: VendorLoadState = .loading
    @State private var detail: VendorWorkshopDetail?
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var subscriptionMessage: String?

    @State private var showQuotationSheet = false
    @State private var quotationPrice = ""
    @State private var quotationNote = ""
    @State private var isSubmitting = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Workshop", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 3) }
                case .noData:
                    VendorEmptyState(icon: "hammer",
                                     title: "Workshop unavailable",
                                     message: "This workshop ad could not be loaded.",
                                     actionTitle: "Try again",
                                     action: load)
                case .loaded:
                    if let detail = detail {
                        content(detail)
                    }
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
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        // Android raises a dialog rather than a toast when the backend answers "need subscription"
        // or "subscription expired", because the company has to act on it.
        .alert("Membership required", isPresented: Binding(get: { subscriptionMessage != nil },
                                                          set: { _ in subscriptionMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(subscriptionMessage ?? "")
        }
        .sheet(isPresented: $showQuotationSheet) {
            VendorWorkshopQuotationSheet(price: $quotationPrice, note: $quotationNote) {
                showQuotationSheet = false
                submitQuotation()
            } onCancel: {
                showQuotationSheet = false
            }
        }
        .onAppear(perform: load)
    }

    // MARK: - Layout

    private func content(_ detail: VendorWorkshopDetail) -> some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.l) {
                summaryCard(detail)

                if !detail.imagePaths.isEmpty {
                    imagesCard(detail)
                }

                if allowsQuotation {
                    quotationButton
                }

                if !detail.quotations.isEmpty {
                    quotationsCard(detail)
                }
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    private func summaryCard(_ detail: VendorWorkshopDetail) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            HStack(alignment: .top) {
                Text(detail.title)
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: VendorTheme.Space.s)
                Text(detail.adId)
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }

            HStack(spacing: VendorTheme.Space.xs) {
                // Android renders these as three separate coloured labels.
                statusChip(detail.isEnabled ? "Enabled" : "Disabled",
                           detail.isEnabled ? VendorTheme.positive : VendorTheme.negative)
                statusChip(detail.isPaid ? "Paid" : "Unpaid",
                           detail.isPaid ? VendorTheme.positive : VendorTheme.textTertiary)
                if !detail.bidType.isEmpty {
                    statusChip(detail.bidType.capitalized + " bid", VendorTheme.textSecondary)
                }
            }

            if !detail.description.isEmpty {
                VendorField(label: "Description", value: detail.description)
            }

            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Work sector", value: detail.workSector)
                VendorField(label: "City", value: detail.cityName)
            }

            VendorField(label: "Posted", value: VendorTheme.date(detail.createdAt))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func statusChip(_ title: String, _ color: Color) -> some View {
        Text(title)
            .font(VendorTheme.Text.badge)
            .foregroundColor(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.14)))
    }

    private func imagesCard(_ detail: VendorWorkshopDetail) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Images", count: detail.imagePaths.count)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VendorTheme.Space.s) {
                    ForEach(detail.imagePaths, id: \.self) { path in
                        AsyncImage(url: VendorTheme.workshopImageURL(path)) { phase in
                            if case .success(let image) = phase {
                                image.resizable().scaledToFill()
                            } else {
                                ZStack {
                                    VendorTheme.surfaceRaised
                                    Image(systemName: "photo")
                                        .foregroundColor(VendorTheme.textTertiary)
                                }
                            }
                        }
                        .frame(width: 132, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var quotationButton: some View {
        Button(action: {
            quotationPrice = ""
            quotationNote = ""
            showQuotationSheet = true
        }) {
            Text("Send a quotation")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    private func quotationsCard(_ detail: VendorWorkshopDetail) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Quotations", count: detail.quotations.count)

            ForEach(detail.quotations) { quotation in
                VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(quotation.displayPrice)
                            .font(VendorTheme.Text.cardTitle)
                            .foregroundColor(VendorTheme.textPrimary)
                        Spacer(minLength: VendorTheme.Space.s)
                        if quotation.isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(VendorTheme.textTertiary)
                        }
                    }

                    if !quotation.message.isEmpty {
                        Text(quotation.message)
                            .font(VendorTheme.Text.meta)
                            .foregroundColor(VendorTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text([quotation.date, quotation.time].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Data

    private func load() {
        if detail == nil { state = .loading }
        fetch()
    }

    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        GCD.async(.Background) {
            LoginService.shared().getWorkshopDetails(workshopId: workshopId) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json, json["workshop_details"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    detail = VendorWorkshopDetail(json["workshop_details"])
                    state = .loaded
                }
            }
        }
    }

    private func submitQuotation() {
        let price = quotationPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !price.isEmpty else {
            noticeMessage = "Enter your price"
            return
        }
        guard let session = VendorSession.current, !session.id.isEmpty else { return }

        isSubmitting = true
        GCD.async(.Background) {
            LoginService.shared().addWorkshopQuotation(vendorId: session.id,
                                                       userId: session.user_id,
                                                       userType: session.user_type,
                                                       workshopId: workshopId,
                                                       price: price,
                                                       message: quotationNote) { message, success, json in
                GCD.async(.Main) {
                    isSubmitting = false
                    guard success else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }

                    // Android branches on `action`; the two subscription cases need a dialog the
                    // company must acknowledge, the rest are informational.
                    let action = json?["action"].stringValue ?? ""
                    if action == "need subscription" || action == "subscription expired" {
                        subscriptionMessage = message.isEmpty
                            ? "Your membership does not allow sending quotations."
                            : message
                    } else {
                        noticeMessage = message.isEmpty ? "Quotation sent." : message
                        load()
                    }
                }
            }
        }
    }
}

// MARK: - Models

/// Android `WorkshopAdModel` as returned by `workshop/get_workshop_details`.
struct VendorWorkshopDetail {
    let id: String
    let adId: String
    let title: String
    let description: String
    let workSector: String
    let cityName: String
    let bidType: String
    let createdAt: String
    let imagePaths: [String]
    let quotations: [VendorWorkshopQuotation]
    private let isActive: String
    private let isPaidRaw: String

    /// Android shows "Enabled" in green / "Disabled" in red off `is_active`.
    var isEnabled: Bool { isActive == "1" }
    /// And "Paid" / "Unpaid" off `is_paid`.
    var isPaid: Bool { isPaidRaw == "1" }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.adId = json["ad_id"].stringValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.workSector = json["work_sector"].stringValue
        self.cityName = json["city_name"].stringValue
        self.bidType = json["bid_type"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.imagePaths = json["images"].arrayValue.map { $0["image_path"].stringValue }
        self.quotations = json["quotations"].arrayValue.map(VendorWorkshopQuotation.init)
        self.isActive = json["is_active"].stringValue
        self.isPaidRaw = json["is_paid"].stringValue
    }
}

/// One bid on a workshop ad.
struct VendorWorkshopQuotation: Identifiable {
    let id: String
    let initialPrice: String
    let finalPrice: String
    let message: String
    let date: String
    let time: String
    let status: String
    private let lockedRaw: String

    var isLocked: Bool { lockedRaw == "1" || lockedRaw.lowercased() == "yes" }

    /// The backend keeps both a starting and an agreed price; show the agreed one once it exists.
    var displayPrice: String {
        let value = finalPrice.isEmpty || finalPrice == "0" ? initialPrice : finalPrice
        return value.isEmpty ? "—" : "AED \(value)"
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.initialPrice = json["initial_price"].stringValue
        self.finalPrice = json["final_price"].stringValue
        self.message = json["message"].stringValue
        self.date = json["date"].stringValue
        self.time = json["time"].stringValue
        self.status = json["status"].stringValue
        self.lockedRaw = json["locked"].stringValue
    }
}

// MARK: - Quotation sheet

/// Android's workshop quotation dialog: a price, an optional note, and a submit that refuses an
/// empty price.
struct VendorWorkshopQuotationSheet: View {
    @Binding var price: String
    @Binding var note: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Send a quotation", onBack: onCancel)

            ScrollView {
                VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        Text("YOUR PRICE (AED)")
                            .font(VendorTheme.Text.label)
                            .foregroundColor(VendorTheme.textTertiary)
                            .tracking(0.4)

                        TextField("0", text: $price)
                            .keyboardType(.decimalPad)
                            .font(VendorTheme.Text.metric)
                            .padding(VendorTheme.Space.m)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.surfaceRaised)
                            )
                    }

                    VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                        Text("MESSAGE (OPTIONAL)")
                            .font(VendorTheme.Text.label)
                            .foregroundColor(VendorTheme.textTertiary)
                            .tracking(0.4)

                        TextEditor(text: $note)
                            .frame(height: 120)
                            .padding(VendorTheme.Space.s)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.surfaceRaised)
                            )
                    }

                    Button(action: onSubmit) {
                        Text("Send")
                            .font(VendorTheme.Text.cardTitle)
                            .foregroundColor(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VendorTheme.Space.m)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.accent)
                            )
                    }
                    .buttonStyle(VendorPressStyle())
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas)
        }
    }
}
