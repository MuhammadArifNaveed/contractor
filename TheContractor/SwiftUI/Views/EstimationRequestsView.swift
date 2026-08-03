//
//  EstimationRequestsView.swift
//  TheContractor
//
//  The signed-in user's own estimate requests — Android's `Estimations` list and `EstimationsDetail`.
//
//  Reached from the side menu and from the profile screen, both of which previously opened the
//  calculator instead, so a submitted request could never be looked at again.
//
//  `Home/estimation_requests` is paged (`current_page`, `total_page`) and answers under `requests`;
//  `Home/estimation_request` answers under `estimation_request_detail`. Both verified live.
//

import SwiftUI
import SwiftyJSON

struct EstimationRequestsView: View {
    @State private var state: VendorLoadState = .loading
    @State private var requests: [EstimationRequest] = []
    @State private var currentPage = 1
    @State private var totalPages = 1
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var selectedRequestId: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Estimations")

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 4) }
                case .noData:
                    VendorEmptyState(icon: "function",
                                     title: "No estimate requests",
                                     message: "Work out an estimate on the Estimation tab and ask for a free consultation — your requests will show up here.",
                                     actionTitle: "Try again",
                                     action: { load(page: 1) })
                case .loaded:
                    list
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(item: $selectedRequestId) { id in
            EstimationRequestDetailView(requestId: id)
        }
        .onAppear { if requests.isEmpty { load(page: 1) } }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.m) {
                ForEach(requests) { request in
                    Button(action: { selectedRequestId = request.id }) {
                        row(request)
                    }
                    .buttonStyle(VendorPressStyle())
                }

                if currentPage < totalPages {
                    Button(action: { load(page: currentPage + 1) }) {
                        if isLoadingMore {
                            VendorBusyIndicator()
                        } else {
                            Text("Load more")
                                .font(VendorTheme.Text.label)
                                .foregroundColor(VendorTheme.textPrimary)
                                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                                .background(
                                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                        .fill(VendorTheme.surface)
                                )
                        }
                    }
                    .buttonStyle(VendorPressStyle())
                    .disabled(isLoadingMore)
                }
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    private func row(_ request: EstimationRequest) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
            HStack(alignment: .top) {
                Text(request.number.isEmpty ? "Estimate" : request.number)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: VendorTheme.Space.s)
                if !request.statusName.isEmpty {
                    VendorBadge(name: request.statusName, colorHex: request.statusColor)
                }
            }

            Text([request.lookingFor, request.categoryName].filter { !$0.isEmpty }.joined(separator: " · "))
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: VendorTheme.Space.xs) {
                Text(request.breakdown)
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textPrimary)
                Spacer(minLength: 0)
                Text(VendorTheme.shortDate(request.createdAt))
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Data

    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch(page: 1) { continuation.resume() }
        }
    }

    private func load(page: Int) {
        if page == 1 {
            if requests.isEmpty { state = .loading }
        } else {
            isLoadingMore = true
        }
        fetch(page: page)
    }

    private func fetch(page: Int, then finished: (() -> Void)? = nil) {
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            state = .noData
            finished?()
            return
        }

        GCD.async(.Background) {
            LoginService.shared().getEstimationRequests(userId: userId, page: page) { message, success, json in
                GCD.async(.Main) {
                    defer {
                        isLoadingMore = false
                        finished?()
                    }
                    guard success, let json = json else {
                        if requests.isEmpty { state = .noData }
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }

                    // The response echoes `current_page`; fall back to what was asked for.
                    let responsePage = json["current_page"].exists() ? json["current_page"].intValue : page
                    let incoming = json["requests"].arrayValue.map(EstimationRequest.init)
                    if responsePage <= 1 {
                        requests = incoming
                    } else {
                        // The backend can repeat a row across pages; keep the first copy.
                        let known = Set(requests.map { $0.id })
                        requests.append(contentsOf: incoming.filter { !known.contains($0.id) })
                    }
                    currentPage = max(1, responsePage)
                    totalPages = max(1, json["total_page"].intValue)
                    state = requests.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Detail

struct EstimationRequestDetailView: View {
    let requestId: String

    @State private var state: VendorLoadState = .loading
    @State private var request: EstimationRequest?
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Estimate", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 3) }
                case .noData:
                    VendorEmptyState(icon: "function",
                                     title: "Estimate unavailable",
                                     message: "This request could not be loaded.",
                                     actionTitle: "Try again",
                                     action: load)
                case .loaded:
                    if let request = request {
                        content(request)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func content(_ request: EstimationRequest) -> some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.m) {
                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    Text(request.number.isEmpty ? "Estimate" : request.number)
                        .font(VendorTheme.Text.screenTitle)
                        .foregroundColor(VendorTheme.textPrimary)

                    if !request.statusName.isEmpty {
                        VendorBadge(name: request.statusName, colorHex: request.statusColor)
                    }

                    Text(request.formattedBudget)
                        .font(VendorTheme.Text.metric)
                        .foregroundColor(VendorTheme.textPrimary)

                    VendorField(label: "Requested", value: VendorTheme.date(request.createdAt))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "What was estimated")
                    VendorField(label: "Looking for", value: request.lookingFor)
                    VendorField(label: "Type of space", value: request.categoryName)
                    HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                        VendorField(label: "Total area", value: "\(request.enteredSqft) Sqft")
                        VendorField(label: "Rate", value: request.sqftPrice.isEmpty ? "—" : "\(request.sqftPrice) AED / Sqft")
                    }
                    if !request.note.isEmpty {
                        VendorField(label: "Your note", value: request.note)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                if !request.reply.isEmpty {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                        VendorSectionHeader(title: "Response")
                        Text(request.reply)
                            .font(VendorTheme.Text.body)
                            .foregroundColor(VendorTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        if !request.handledBy.isEmpty {
                            VendorField(label: "Handled by", value: request.handledBy)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()
                }

                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "Your details")
                    HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                        VendorField(label: "Name", value: request.name)
                        VendorField(label: "Phone", value: request.phone)
                    }
                    VendorField(label: "Email", value: request.email)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()
            }
            .padding(VendorTheme.Space.l)
        }
    }

    private func load() {
        if request == nil { state = .loading }
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            state = .noData
            return
        }

        GCD.async(.Background) {
            LoginService.shared().getEstimationRequestDetail(requestId: requestId, userId: userId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json, json["estimation_request_detail"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    request = EstimationRequest(json["estimation_request_detail"])
                    state = .loaded
                }
            }
        }
    }
}

// MARK: - Model

/// One estimate request. The list row and the detail response carry the same fields, so both use this
/// — the only difference is that the row also has `status_arabic_name`.
struct EstimationRequest: Identifiable {
    let id: String
    let number: String
    let name: String
    let email: String
    let phone: String
    let lookingFor: String
    let categoryName: String
    let enteredSqft: String
    let sqftPrice: String
    let note: String
    let reply: String
    let createdAt: String
    let statusName: String
    let statusColor: String
    let accName: String
    let accSurname: String

    /// The person at the company who answered, if anyone has.
    var handledBy: String {
        [accName, accSurname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    /// Android prints `sqft * price = total`; this keeps the arithmetic but spells it out.
    var breakdown: String {
        guard let area = Int(enteredSqft), let rate = Int(sqftPrice) else {
            return enteredSqft.isEmpty ? "—" : "\(enteredSqft) Sqft"
        }
        return "\(area) Sqft × \(rate) = \(EstimationRequest.currency(area * rate))"
    }

    var formattedBudget: String {
        guard let area = Int(enteredSqft), let rate = Int(sqftPrice) else { return "—" }
        return EstimationRequest.currency(area * rate)
    }

    private static func currency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "AED " + (formatter.string(from: NSNumber(value: value)) ?? "\(value)")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.number = json["estimation_number"].stringValue
        self.name = json["name"].stringValue
        self.email = json["email"].stringValue
        self.phone = json["phone"].stringValue
        self.lookingFor = json["looking_for"].stringValue
        self.categoryName = json["category_name"].stringValue
        self.enteredSqft = json["entered_sqft"].stringValue
        self.sqftPrice = json["sqft_price"].stringValue
        self.note = json["note"].stringValue
        self.reply = json["reply"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.statusName = json["status_name"].stringValue
        self.statusColor = json["status_color"].stringValue
        self.accName = json["acc_name"].stringValue
        self.accSurname = json["acc_surname"].stringValue
    }
}
