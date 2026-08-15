//
//  FreelancerOrderChatView.swift
//  TheContractor
//
//  Chat on a freelancer order — Android's `VendorFreelancersChatConnection` (the two-tab list) and
//  `VendorFreelancerChat` (the thread), reached from the freelancer dashboard.
//
//  **This is not the Firestore chat.** It has no Firebase in it at all: the thread lives on the REST
//  backend, keyed on an order rather than on a company/user pair, and it is polled rather than streamed
//  because the backend offers no live channel. An earlier note in `PARITY_STATUS.md` filed this under the
//  Firebase blocker, which was wrong — it was never blocked on anything.
//
//  Two response quirks, both Android's:
//
//  1. An order nobody has written on answers `error:true` with "No chats found". That is an empty thread,
//     not a failure, and it must not surface as an error.
//  2. `sending` is separate from `error`. When it reads `"false"` the composer is hidden and the thread
//     is read-only — Android labels that "Order Expired / Rejected". A past-dated order does this, which
//     is the state both orders on the QA account are in.
//

import SwiftUI
import SwiftyJSON

// MARK: - List

struct FreelancerOrderChatsView: View {
    var onBack: (() -> Void)?

    /// Android runs the same screen twice off one `from` extra, one tab per direction.
    private enum Direction: String, CaseIterable {
        case placed = "Placed"
        case received = "Received"
    }

    @State private var direction: Direction = .placed
    @State private var state: VendorLoadState = .loading
    @State private var rows: [FreelancerOrderChatRow] = []
    @State private var errorMessage: String?
    @State private var openOrder: FreelancerOrderChatRow?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Order chats", onBack: onBack)

            Picker("", selection: $direction) {
                ForEach(Direction.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(VendorTheme.Space.m)

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "bubble.left.and.bubble.right",
                                     title: "No order chats",
                                     message: direction == .placed
                                        ? "Orders you place will be listed here."
                                        : "Orders you receive will be listed here.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: VendorTheme.Space.s) {
                            ForEach(rows) { row in
                                Button(action: { openOrder = row }) { rowCard(row) }
                                    .buttonStyle(VendorPressStyle())
                            }
                        }
                        .padding(VendorTheme.Space.m)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: load)
        .onChange(of: direction) { _ in load() }
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(item: $openOrder) { row in
            // The row's `expired` flag is the only thing that knows an empty thread is closed:
            // `fetch_order_chats` answers a bare `{"error":true,"message":"No chats found"}` for an
            // order with no messages, with no `sending` key to read. Verified on order #9.
            FreelancerOrderChatThreadView(orderId: row.orderId,
                                          title: row.freelancerName,
                                          canSendInitially: !row.isExpired)
        }
    }

    private func rowCard(_ row: FreelancerOrderChatRow) -> some View {
        HStack(spacing: VendorTheme.Space.m) {
            AsyncImage(url: URL(string: row.image)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    ZStack {
                        VendorTheme.surfaceRaised
                        Text(row.initials)
                            .font(VendorTheme.Text.label)
                            .foregroundColor(VendorTheme.textSecondary)
                    }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(row.freelancerName)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                    .lineLimit(1)
                Text("Order #\(row.orderId)\(row.dates.isEmpty ? "" : " · \(row.dates)")")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }

            Spacer(minLength: 0)

            if row.isExpired {
                Text("Expired")
                    .font(VendorTheme.Text.badge)
                    .foregroundColor(VendorTheme.textTertiary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func load() {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            return
        }
        state = rows.isEmpty ? .loading : state

        let handler: (String, Bool, JSON?) -> Void = { message, success, json in
            GCD.async(.Main) {
                guard success, let json = json else {
                    rows = []
                    state = .noData
                    return
                }
                rows = json["order_chats"].arrayValue.map(FreelancerOrderChatRow.init)
                state = rows.isEmpty ? .noData : .loaded
            }
        }

        GCD.async(.Background) {
            switch direction {
            case .placed:
                LoginService.shared().getPlacedOrderChats(vendorId: session.id, userId: session.user_id,
                                                          userType: session.user_type, completion: handler)
            case .received:
                LoginService.shared().getReceivedOrderChats(vendorId: session.id, userId: session.user_id,
                                                            userType: session.user_type, completion: handler)
            }
        }
    }
}

// MARK: - Thread

struct FreelancerOrderChatThreadView: View {
    let orderId: String
    let title: String

    @State private var messages: [FreelancerOrderMessage] = []
    @State private var draft = ""

    /// Seeded from the list row's `expired` flag, because the response cannot always be asked. An
    /// order with messages answers with `sending` and that wins; an order with none answers only
    /// `{"error":true,"message":"No chats found"}`, and defaulting to `true` there put a working
    /// composer on an expired order — every send would have come back "Message not sent, Order
    /// Expired". Verified against order #9.
    @State private var canSend: Bool

    init(orderId: String, title: String, canSendInitially: Bool = true) {
        self.orderId = orderId
        self.title = title
        self._canSend = State(initialValue: canSendInitially)
    }

    @State private var isLoading = true
    @State private var isSending = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: title, onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                if isLoading {
                    VendorBusyIndicator()
                } else if messages.isEmpty {
                    VendorEmptyState(icon: "bubble.left.and.bubble.right",
                                     title: "No messages yet",
                                     message: canSend ? "Say hello." : "This order is closed.")
                } else {
                    ScrollView {
                        VStack(spacing: VendorTheme.Space.s) {
                            ForEach(messages) { bubble($0) }
                        }
                        .padding(VendorTheme.Space.m)
                    }
                }
            }

            if canSend {
                composer
            } else {
                // Android replaces the composer with this exact sentiment rather than a disabled field.
                Text("Order Expired / Rejected")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(VendorTheme.Space.m)
                    .background(VendorTheme.surface)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: load)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func bubble(_ message: FreelancerOrderMessage) -> some View {
        HStack {
            if message.isMine { Spacer(minLength: 40) }

            VStack(alignment: .leading, spacing: 4) {
                Text(message.message)
                    .font(VendorTheme.Text.body)
                    .foregroundColor(message.isMine ? VendorTheme.onAccent : VendorTheme.textPrimary)
                HStack(spacing: VendorTheme.Space.xs) {
                    if !message.isMine && !message.senderName.isEmpty {
                        Text(message.senderName)
                    }
                    Text(VendorTheme.date(message.createdAt))
                }
                .font(VendorTheme.Text.meta)
                .foregroundColor(message.isMine ? VendorTheme.onAccent.opacity(0.75) : VendorTheme.textTertiary)
            }
            .padding(VendorTheme.Space.m)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                    .fill(message.isMine ? VendorTheme.accent : VendorTheme.surface)
            )

            if !message.isMine { Spacer(minLength: 40) }
        }
    }

    private var composer: some View {
        HStack(spacing: VendorTheme.Space.s) {
            TextField("Message", text: $draft)
                .font(VendorTheme.Text.body)
                .padding(.horizontal, VendorTheme.Space.m)
                .frame(minHeight: VendorTheme.minTapTarget)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(draft.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? VendorTheme.textTertiary : VendorTheme.onAccent)
                    .frame(width: VendorTheme.minTapTarget, height: VendorTheme.minTapTarget)
                    .background(
                        Circle().fill(draft.trimmingCharacters(in: .whitespaces).isEmpty
                                      ? VendorTheme.surfaceRaised : VendorTheme.accent)
                    )
            }
            .disabled(isSending || draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(VendorTheme.Space.m)
        .background(VendorTheme.surface)
    }

    private func load() {
        guard let session = VendorSession.current else { return }
        GCD.async(.Background) {
            LoginService.shared().getOrderChat(orderId: orderId) { _, _, json in
                GCD.async(.Main) {
                    isLoading = false
                    guard let json = json else { return }
                    // "No chats found" comes back as an error; it means empty, so the rows are read
                    // regardless and only `sending` decides whether the composer stays.
                    messages = json["chats"].arrayValue.map {
                        FreelancerOrderMessage($0, userId: session.user_id, userType: session.user_type)
                    }
                    if json["sending"].exists() {
                        canSend = json["sending"].stringValue != "false"
                    }
                }
            }
        }
    }

    private func send() {
        guard let session = VendorSession.current else { return }
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isSending = true
        GCD.async(.Background) {
            LoginService.shared().sendOrderChatMessage(orderId: orderId, message: text,
                                                       userId: session.user_id,
                                                       userType: session.user_type) { message, success in
                GCD.async(.Main) {
                    isSending = false
                    guard success else {
                        // "Message not sent, Order Expired" lands here; the backend is the authority on
                        // whether an order still accepts messages, not the flag we were handed on load.
                        errorMessage = message.isEmpty ? "Message not sent" : message
                        return
                    }
                    draft = ""
                    load()
                }
            }
        }
    }
}

// MARK: - Models

/// Android `FreelancersChatConnectionModel`. The row carries the order's whole `basic_details` block;
/// only the few fields the list shows are read.
struct FreelancerOrderChatRow: Identifiable {
    var id: String { orderId }
    let orderId: String
    let freelancerName: String
    let image: String
    let dates: String
    private let expired: String

    var isExpired: Bool { expired == "1" }

    var initials: String {
        let parts = freelancerName.split(separator: " ").prefix(2)
        return parts.map { String($0.prefix(1)).uppercased() }.joined()
    }

    init(_ json: JSON) {
        self.orderId = json["order_id"].stringValue
        self.freelancerName = json["freelancer_name"].stringValue
        self.image = json["image"].stringValue
        self.dates = json["basic_details"]["dates"].stringValue
        self.expired = json["basic_details"]["expired"].stringValue
    }
}

/// Android `FreelancerChatModel`.
struct FreelancerOrderMessage: Identifiable {
    let id = UUID()
    let message: String
    let createdAt: String
    let senderName: String
    let isMine: Bool

    /// Android's adapter decides the side with `sender_id == userId && sender_type == userType` — both,
    /// because a company and a user can share a numeric id.
    init(_ json: JSON, userId: String, userType: String) {
        self.message = json["message"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.senderName = json["sender_name"].stringValue
        self.isMine = json["sender_id"].stringValue == userId
            && json["sender_type"].stringValue == userType
    }
}
