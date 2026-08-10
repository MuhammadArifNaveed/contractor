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
    /// True when the ad belongs to whoever is signed in — Android's `WorkshopAdDetail` shows
    /// "(Enabled) Make Disable" / "(Disabled) Make Enable" on your own ad only.
    var allowsStatusToggle: Bool = false

    @State private var state: VendorLoadState = .loading
    @State private var detail: VendorWorkshopDetail?
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var subscriptionMessage: String?

    @State private var showQuotationSheet = false
    @State private var quotationPrice = ""
    @State private var quotationNote = ""
    @State private var isSubmitting = false
    @State private var isTogglingStatus = false

    @State private var isOpeningChat = false
    @State private var chatThread: ChatConnection?

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

                if isSubmitting || isTogglingStatus || isOpeningChat {
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
        .sheet(item: $chatThread) { connection in
            ChatThreadView(connection: connection, role: .company)
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

                if canMessageOwner(detail) {
                    messageButton
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

            if allowsStatusToggle {
                Button(action: toggleStatus) {
                    HStack(spacing: VendorTheme.Space.xs) {
                        Image(systemName: detail.isEnabled ? "pause.circle" : "play.circle")
                            .font(.system(size: 14))
                        Text(detail.isEnabled ? "Disable this ad" : "Enable this ad")
                            .font(VendorTheme.Text.label)
                    }
                    .foregroundColor(detail.isEnabled ? VendorTheme.negative : VendorTheme.positive)
                    .padding(.horizontal, VendorTheme.Space.m)
                    .frame(minHeight: VendorTheme.minTapTarget)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
                }
                .buttonStyle(VendorPressStyle())
                .disabled(isTogglingStatus)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    /// `workshop/toggle_workshop_status` decides the new state itself, so the ad is re-read afterwards
    /// rather than assuming the flip succeeded in the direction we expected.
    private func toggleStatus() {
        isTogglingStatus = true
        GCD.async(.Background) {
            LoginService.shared().toggleWorkshopStatus(workshopId: workshopId) { message, success, _ in
                GCD.async(.Main) {
                    isTogglingStatus = false
                    if success {
                        noticeMessage = message.isEmpty ? "Updated." : message
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
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

    /// Android's `VendorWorkshopDetail` reveals its chat row only when the ad's `show_chat` flag is
    /// `"1"`. **iOS deliberately does not gate on it.** Every ad the backend serves carries
    /// `show_chat: "0"`, and no declared endpoint ever sets it — `workshop/submit_workshop_ad` does not
    /// take the flag — so honouring it hides the Message action on every ad in existence, which is to say
    /// it ships the feature dead. Android's own chat entry point is unreachable for a second reason
    /// anyway: the screen behind it is fed by `Vendor/workshop_ad_detail`, which 500s.
    ///
    /// Two checks remain. A company has to be looking, and the ad has to belong to a user: this screen is
    /// shared with the consumer side, and the two halves of a `user_connections` document are a company
    /// and a user — the schema has no company-to-company thread.
    private func canMessageOwner(_ detail: VendorWorkshopDetail) -> Bool {
        detail.userType == "users" && !detail.userId.isEmpty && ChatCompany.current != nil
    }

    private var messageButton: some View {
        Button(action: openChat) {
            HStack(spacing: VendorTheme.Space.xs) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Message")
                    .font(VendorTheme.Text.cardTitle)
            }
            .foregroundColor(VendorTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VendorTheme.Space.m)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                    .fill(VendorTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .stroke(VendorTheme.separator, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(VendorPressStyle())
        .disabled(isOpeningChat)
    }

    /// Two steps before the thread can open, both of which Android gets for free from the ad model it
    /// loads (`Vendor/workshop_ad_detail`, which the backend no longer serves): the owner's uuid and
    /// names, then the existing connection if these two have talked before.
    ///
    /// Nothing is written here. A connection document appears only when the first message is sent —
    /// `ChatService.send` creates it — so opening a thread and backing out leaves no trace, which is
    /// what `VendorChat` does too.
    private func openChat() {
        guard let detail = detail, let company = ChatCompany.current else { return }

        isOpeningChat = true
        GCD.async(.Background) {
            LoginService.shared().getUserDetailsById(userId: detail.userId) { message, success, json in
                let account = json?["user"]
                guard success, let account = account, !account["uuid"].stringValue.isEmpty else {
                    GCD.async(.Main) {
                        isOpeningChat = false
                        errorMessage = message.isEmpty ? "Could not open this conversation" : message
                    }
                    return
                }

                // Android's `fullName` is `name + " " + surname` off the ad; the account carries the
                // same two fields.
                let fullName = [account["name"].stringValue, account["surname"].stringValue]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                let user = ChatUser(id: detail.userId,
                                    uuid: account["uuid"].stringValue,
                                    userName: account["username"].stringValue,
                                    fullName: fullName)

                ChatService.shared.findConnection(companyUUID: company.uuid, userUUID: user.uuid) { existing, error in
                    GCD.async(.Main) {
                        isOpeningChat = false
                        if let error = error {
                            errorMessage = error
                            return
                        }
                        chatThread = existing ?? ChatConnection.pending(company: company, user: user)
                    }
                }
            }
        }
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

                    HStack(spacing: VendorTheme.Space.m) {
                        Text([quotation.date, quotation.time].filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(VendorTheme.Text.meta)
                            .foregroundColor(VendorTheme.textTertiary)

                        Spacer(minLength: 0)

                        // Android exposes this as a lock toggle on each quotation row
                        // (WorkshopAdDetail + WorkshopAdQuotationAdapter).
                        Button(action: { toggleLock(quotation) }) {
                            Label(quotation.isLocked ? "Unlock" : "Lock",
                                  systemImage: quotation.isLocked ? "lock.open" : "lock")
                                .font(VendorTheme.Text.meta)
                                .foregroundColor(VendorTheme.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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

    private func toggleLock(_ quotation: VendorWorkshopQuotation) {
        isSubmitting = true
        GCD.async(.Background) {
            LoginService.shared().setWorkshopQuotationLock(quotationId: quotation.id,
                                                           locked: !quotation.isLocked) { message, success in
                GCD.async(.Main) {
                    isSubmitting = false
                    if success {
                        noticeMessage = message.isEmpty
                            ? (quotation.isLocked ? "Quotation unlocked." : "Quotation locked.")
                            : message
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
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
    /// Who posted the ad. The response carries no `uuid` for them — chat resolves that separately
    /// through `Account/get_user_details_by_id`.
    let userId: String
    let userType: String
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
        self.userId = json["user_id"].stringValue
        self.userType = json["user_type"].stringValue
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
