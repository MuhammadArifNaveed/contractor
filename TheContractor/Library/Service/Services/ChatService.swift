//
//  ChatService.swift
//  TheContractor
//
//  Chat, replicating Android's Firestore usage exactly.
//
//  Android holds two collections and no chat endpoint of any kind — `Home/get_chats`, which iOS used to
//  call, has never existed:
//
//  * **`user_connections`** — one document per company/user pair, carrying both sides' names and ids, the
//    `chat_uuid` that ties the thread together, and `last_message` / `message_time` for the inbox row.
//    Connections are created elsewhere (a thread is opened from a company or an enquiry), so both inboxes
//    only ever read this collection.
//  * **`chat`** — one document per message, tied to the thread by `chat_uuid`.
//
//  Two details are load-bearing:
//
//  1. Timestamps are `yyyy-dd-MM HH:mm:ss` — day and month **swapped**, which is Android's own quirk in
//     `getCurrentDateTime()`. Messages are ordered by `country_time` as a *string*, so writing the
//     sensible `yyyy-MM-dd` here would interleave iOS and Android messages wrongly. It is copied, not
//     corrected.
//  2. `country_time` is the same format in Asia/Dubai, while `time` is the device's own zone.
//

import Foundation
import FirebaseFirestore

/// Which side of a conversation the signed-in account is on. Android keys this off which activity is
/// running — `Chat` for a user, `VendorChat` for a company — and stamps `sent_by` accordingly.
enum ChatRole: String {
    case user
    case company

    /// The `user_connections` field to filter the inbox on.
    var connectionField: String {
        self == .user ? "user_uuid" : "company_uuid"
    }

    /// The read flag this side owns on a message.
    var viewedField: String {
        self == .user ? "user_is_view" : "company_is_view"
    }
}

/// One row in the inbox. Field names are Android's, read off `ChatConnection`'s snapshot handler.
struct ChatConnection: Identifiable, Equatable {
    let id: String              // the Firestore document id, needed to update last_message
    let chatUUID: String
    let companyId: String
    let companyUUID: String
    let companySerialNo: String
    let companyName: String
    let userId: String
    let userUUID: String
    let userName: String
    let fullName: String
    let lastMessage: String
    let messageTime: String
    let createdAt: String

    /// Whoever the signed-in side is talking *to*.
    func counterpartName(for role: ChatRole) -> String {
        let name = role == .user ? companyName : (fullName.isEmpty ? userName : fullName)
        return name.isEmpty ? "Conversation" : name
    }

    init(id: String, data: [String: Any]) {
        func string(_ key: String) -> String { data[key] as? String ?? "" }
        self.id = id
        self.chatUUID = string("chat_uuid")
        self.companyId = string("company_id")
        self.companyUUID = string("company_uuid")
        self.companySerialNo = string("company_serial_no")
        self.companyName = string("company_name")
        self.userId = string("user_id")
        self.userUUID = string("user_uuid")
        self.userName = string("user_name")
        self.fullName = string("full_name")
        self.lastMessage = string("last_message")
        self.messageTime = string("message_time")
        self.createdAt = string("created_at")
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let chatUUID: String
    let message: String
    let sentBy: String
    let time: String
    let countryTime: String

    /// True when this side wrote it, which decides which way the bubble sits.
    func isMine(role: ChatRole) -> Bool { sentBy == role.rawValue }

    init(id: String, data: [String: Any]) {
        func string(_ key: String) -> String { data[key] as? String ?? "" }
        self.id = id
        self.chatUUID = string("chat_uuid")
        self.message = string("message")
        self.sentBy = string("sent_by")
        self.time = string("time")
        self.countryTime = string("country_time")
    }
}

final class ChatService {
    static let shared = ChatService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Identity

    /// The uuid Firestore keys everything on, for whichever account is signed in.
    static func currentUUID(for role: ChatRole) -> String? {
        switch role {
        case .user:
            guard let uuid = UserDefaultsManager.shared.userInfo?.uuid, !uuid.isEmpty else { return nil }
            return uuid
        case .company:
            guard let uuid = VendorSession.current?.uuid, !uuid.isEmpty else { return nil }
            return uuid
        }
    }

    /// Which side the app is currently acting as.
    static var currentRole: ChatRole {
        Global.shared.isVendor ? .company : .user
    }

    // MARK: - Inbox

    /// Live list of conversations. Android attaches a snapshot listener and folds ADDED and MODIFIED
    /// changes into its array; a listener over the whole query gives the same result more simply.
    ///
    /// The query is not ordered: Android's `orderBy("message_time")` is commented out, and adding one
    /// would need a Firestore composite index that the project may not have.
    func observeConnections(role: ChatRole,
                            onChange: @escaping ([ChatConnection]) -> Void,
                            onError: @escaping (String) -> Void) -> ListenerRegistration? {
        guard let uuid = ChatService.currentUUID(for: role) else {
            onError("Sign in again to see your messages")
            return nil
        }

        return db.collection("user_connections")
            .whereField(role.connectionField, isEqualTo: uuid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                let rows = (snapshot?.documents ?? []).map { ChatConnection(id: $0.documentID, data: $0.data()) }
                // Newest first, by the same string the messages are ordered on.
                onChange(rows.sorted { $0.messageTime > $1.messageTime })
            }
    }

    // MARK: - Thread

    /// Live message list for one thread, ordered the way Android orders it.
    func observeMessages(chatUUID: String,
                         onChange: @escaping ([ChatMessage]) -> Void,
                         onError: @escaping (String) -> Void) -> ListenerRegistration {
        db.collection("chat")
            .whereField("chat_uuid", isEqualTo: chatUUID)
            .order(by: "country_time")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                onChange((snapshot?.documents ?? []).map { ChatMessage(id: $0.documentID, data: $0.data()) })
            }
    }

    /// Adds the message, then updates the connection's `last_message` / `message_time` so the inbox row
    /// moves — the same two steps, in the same order, as `Chat.sendMessageFirebase()`.
    func send(_ message: String,
              in connection: ChatConnection,
              as role: ChatRole,
              completion: @escaping (_ error: String?) -> Void) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(nil)
            return
        }

        let countryTime = ChatService.countryDateTime()
        let document: [String: Any] = [
            "company_uuid": connection.companyUUID,
            "user_uuid": connection.userUUID,
            "chat_uuid": connection.chatUUID,
            "time": ChatService.currentDateTime(),
            "country_time": countryTime,
            "company_is_view": "0",
            "user_is_view": "0",
            "message": trimmed,
            "sent_by": role.rawValue
        ]

        db.collection("chat").addDocument(data: document) { [weak self] error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            self?.db.collection("user_connections").document(connection.id).updateData([
                "last_message": trimmed,
                "message_time": countryTime
            ]) { updateError in
                completion(updateError?.localizedDescription)
            }
        }
    }

    /// Marks the other side's messages in this thread as seen. Android sets the flag per message as it
    /// renders them; doing it in one pass on open is the same outcome with one write per unread message.
    func markThreadViewed(chatUUID: String, as role: ChatRole) {
        db.collection("chat")
            .whereField("chat_uuid", isEqualTo: chatUUID)
            .whereField(role.viewedField, isEqualTo: "0")
            .getDocuments { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents, !documents.isEmpty else { return }
                let batch = self.db.batch()
                for document in documents where (document.data()["sent_by"] as? String) != role.rawValue {
                    batch.updateData([role.viewedField: "1"], forDocument: document.reference)
                }
                batch.commit(completion: nil)
            }
    }

    // MARK: - Timestamps

    /// `yyyy-dd-MM HH:mm:ss` in the device's zone — Android's `getCurrentDateTime()`, day and month
    /// swapped included.
    static func currentDateTime() -> String {
        formatter(timeZone: .current).string(from: Date())
    }

    /// The same, fixed to Asia/Dubai, which is what messages are ordered by.
    static func countryDateTime() -> String {
        formatter(timeZone: TimeZone(identifier: "Asia/Dubai") ?? .current).string(from: Date())
    }

    private static func formatter(timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-dd-MM HH:mm:ss"
        formatter.timeZone = timeZone
        return formatter
    }

    /// Reads one of those strings back for display. `VendorTheme.date` already tries both orders, so this
    /// hands it over rather than repeating the guesswork.
    static func display(_ raw: String) -> String {
        VendorTheme.date(raw)
    }
}
