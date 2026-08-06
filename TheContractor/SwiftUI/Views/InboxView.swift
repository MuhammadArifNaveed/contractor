//
//  InboxView.swift
//  TheContractor
//
//  Chat — Android's `ChatConnection` + `Chat` for a user, `VendorChatConnection` + `VendorChat` for a
//  company. One screen serves both: the collections, the documents and the queries are identical, and
//  only which uuid the inbox filters on and what `sent_by` says differ.
//
//  This replaces the two "not available yet" screens. The consumer one used to call `Home/get_chats`,
//  which the backend has never served — chat was always Firestore.
//
//  Conversations are not created here. Android's chat activities receive a `chat_uuid` from the
//  connection list, so `user_connections` is only ever read by the app; a connection appears when a
//  thread is started elsewhere.
//

import SwiftUI
import FirebaseFirestore

struct InboxView: View {
    let role: ChatRole
    /// Drawer-rooted on the consumer side, where back means "restore the tab bar".
    var onBack: (() -> Void)? = nil

    @State private var connections: [ChatConnection] = []
    @State private var state: VendorLoadState = .loading
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?
    @State private var openThread: ChatConnection?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Inbox", onBack: onBack)

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 5) }
                case .noData:
                    VendorEmptyState(icon: "bubble.left.and.bubble.right",
                                     title: "No conversations",
                                     message: role == .user
                                        ? "Message a company from its page and the conversation will appear here."
                                        : "Conversations started by customers will appear here.")
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
        .sheet(item: $openThread) { connection in
            ChatThreadView(connection: connection, role: role)
        }
        .onAppear(perform: observe)
        .onDisappear {
            listener?.remove()
            listener = nil
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.m) {
                ForEach(connections) { connection in
                    Button(action: { openThread = connection }) {
                        row(connection)
                    }
                    .buttonStyle(VendorPressStyle())
                }
            }
            .padding(VendorTheme.Space.l)
        }
    }

    private func row(_ connection: ChatConnection) -> some View {
        HStack(alignment: .top, spacing: VendorTheme.Space.m) {
            ZStack {
                Circle().fill(VendorTheme.surfaceRaised)
                Text(initials(connection.counterpartName(for: role)))
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textSecondary)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(connection.counterpartName(for: role))
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                    .lineLimit(1)

                Text(connection.lastMessage.isEmpty ? "No messages yet" : connection.lastMessage)
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if !connection.messageTime.isEmpty {
                Text(VendorTheme.shortDate(connection.messageTime))
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    private func observe() {
        guard listener == nil else { return }
        listener = ChatService.shared.observeConnections(role: role, onChange: { rows in
            connections = rows
            state = rows.isEmpty ? .noData : .loaded
        }, onError: { message in
            state = connections.isEmpty ? .noData : .loaded
            errorMessage = message
        })
        if listener == nil { state = .noData }
    }
}

// MARK: - One conversation

struct ChatThreadView: View {
    let connection: ChatConnection
    let role: ChatRole

    @State private var messages: [ChatMessage] = []
    @State private var draft = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var listener: ListenerRegistration?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: connection.counterpartName(for: role), onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                if messages.isEmpty {
                    VendorEmptyState(icon: "bubble.left",
                                     title: "No messages yet",
                                     message: "Say hello.")
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: VendorTheme.Space.s) {
                                ForEach(messages) { message in
                                    bubble(message).id(message.id)
                                }
                            }
                            .padding(VendorTheme.Space.l)
                        }
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }
                }
            }

            composer
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            observe()
            ChatService.shared.markThreadViewed(chatUUID: connection.chatUUID, as: role)
        }
        .onDisappear {
            listener?.remove()
            listener = nil
        }
    }

    private func bubble(_ message: ChatMessage) -> some View {
        let mine = message.isMine(role: role)
        return HStack {
            if mine { Spacer(minLength: 40) }

            VStack(alignment: mine ? .trailing : .leading, spacing: 3) {
                Text(message.message)
                    .font(VendorTheme.Text.body)
                    .foregroundColor(mine ? VendorTheme.onAccent : VendorTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(ChatService.display(message.countryTime))
                    .font(VendorTheme.Text.badge)
                    .foregroundColor(mine ? VendorTheme.onAccent.opacity(0.7) : VendorTheme.textTertiary)
            }
            .padding(.horizontal, VendorTheme.Space.m)
            .padding(.vertical, VendorTheme.Space.s)
            .background(
                RoundedRectangle(cornerRadius: VendorTheme.Radius.card, style: .continuous)
                    .fill(mine ? VendorTheme.accent : VendorTheme.surface)
            )

            if !mine { Spacer(minLength: 40) }
        }
    }

    private var composer: some View {
        HStack(spacing: VendorTheme.Space.s) {
            TextField("Message", text: $draft)
                .font(VendorTheme.Text.body)
                .padding(.horizontal, VendorTheme.Space.m)
                .frame(minHeight: VendorTheme.minTapTarget)
                .background(
                    Capsule().fill(VendorTheme.surfaceRaised)
                )

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(VendorTheme.onAccent)
                    .frame(width: VendorTheme.minTapTarget, height: VendorTheme.minTapTarget)
                    .background(Circle().fill(draft.isEmpty ? VendorTheme.surfaceRaised : VendorTheme.accent))
            }
            .buttonStyle(VendorPressStyle())
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding(VendorTheme.Space.m)
        .background(VendorTheme.surface.ignoresSafeArea(edges: .bottom))
        .overlay(Rectangle().fill(VendorTheme.separator).frame(height: 0.5), alignment: .top)
    }

    private func observe() {
        guard listener == nil else { return }
        listener = ChatService.shared.observeMessages(chatUUID: connection.chatUUID, onChange: { rows in
            messages = rows
        }, onError: { message in
            errorMessage = message
        })
    }

    private func send() {
        let message = draft
        isSending = true
        ChatService.shared.send(message, in: connection, as: role) { error in
            isSending = false
            if let error = error {
                errorMessage = error
            } else {
                draft = ""
            }
        }
    }
}
