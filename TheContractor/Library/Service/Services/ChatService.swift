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
//    **Only the company side creates one**, and only on the first message it actually sends: Android's
//    `VendorChat` checks for an existing document on open and writes one in `createUserConnectionOnFireStore()`
//    when the send button is pressed with none found. The consumer's `Chat.java` never writes to this
//    collection, so a user cannot start a thread — they can only answer one.
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

    /// True until Firestore has the document. Android carries the same state as a `userConnection`
    /// boolean plus an empty `documentID`, and branches on it when the send button is pressed.
    var isPending: Bool { id.isEmpty }

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

    private init(id: String, chatUUID: String, company: ChatCompany, user: ChatUser,
                 lastMessage: String, messageTime: String, createdAt: String) {
        self.id = id
        self.chatUUID = chatUUID
        self.companyId = company.id
        self.companyUUID = company.uuid
        self.companySerialNo = company.serialNo
        self.companyName = company.name
        self.userId = user.id
        self.userUUID = user.uuid
        self.userName = user.userName
        self.fullName = user.fullName
        self.lastMessage = lastMessage
        self.messageTime = messageTime
        self.createdAt = createdAt
    }

    /// A thread the company has opened but not yet sent anything on. Android generates the `chat_uuid`
    /// the moment `VendorChat` starts (`getUUID()`), before it knows whether a connection exists, and
    /// throws it away if the lookup finds one — so it is minted here for the same reason.
    static func pending(company: ChatCompany, user: ChatUser) -> ChatConnection {
        ChatConnection(id: "", chatUUID: UUID().uuidString, company: company, user: user,
                       lastMessage: "", messageTime: "", createdAt: "")
    }

    /// The same row once Firestore has accepted it.
    func stored(id: String) -> ChatConnection {
        ChatConnection(id: id, chatUUID: chatUUID,
                       company: ChatCompany(id: companyId, uuid: companyUUID,
                                            serialNo: companySerialNo, name: companyName),
                       user: ChatUser(id: userId, uuid: userUUID, userName: userName, fullName: fullName),
                       lastMessage: lastMessage, messageTime: messageTime, createdAt: createdAt)
    }
}

/// The company half of a connection — Android reads these four off its stored `VendorSharedPrefModel`.
struct ChatCompany: Equatable {
    let id: String
    let uuid: String
    let serialNo: String
    let name: String

    /// The signed-in company, or `nil` when none is.
    static var current: ChatCompany? {
        guard let session = VendorSession.current, !session.uuid.isEmpty else { return nil }
        return ChatCompany(id: session.id, uuid: session.uuid,
                           serialNo: session.company_serial_number, name: session.company_name)
    }
}

/// The user half. Android takes all four off the workshop ad it was opened from; iOS reads them from
/// `Account/get_user_details_by_id`, because the ad endpoint it can reach carries no uuid.
struct ChatUser: Equatable {
    let id: String
    let uuid: String
    let userName: String
    let fullName: String
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

    // MARK: - Starting a conversation (company only)

    /// Android's `checkUserConnectionFromFireStore()`: is there already a thread between these two?
    /// Hands back the stored connection when there is, so its `chat_uuid` and document id are reused
    /// rather than a second thread being opened over the top of the first.
    func findConnection(companyUUID: String, userUUID: String,
                        completion: @escaping (_ connection: ChatConnection?, _ error: String?) -> Void) {
        db.collection("user_connections")
            .whereField("company_uuid", isEqualTo: companyUUID)
            .whereField("user_uuid", isEqualTo: userUUID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                    return
                }
                guard let document = snapshot?.documents.first else {
                    completion(nil, nil)
                    return
                }
                completion(ChatConnection(id: document.documentID, data: document.data()), nil)
            }
    }

    /// Android's `createUserConnectionOnFireStore()`, field for field and in the same order.
    ///
    /// `created_at` is the device-zone timestamp in the swapped `yyyy-dd-MM` format; `last_message` and
    /// `message_time` start empty, and all three `is_active` flags start `"1"`. Android calls this only
    /// from the send button, never on open, so a company browsing a thread it never replies to leaves
    /// nothing behind.
    func createConnection(_ connection: ChatConnection,
                          completion: @escaping (_ connection: ChatConnection?, _ error: String?) -> Void) {
        let document: [String: Any] = [
            "company_id": connection.companyId,
            "company_uuid": connection.companyUUID,
            "company_serial_no": connection.companySerialNo,
            "company_name": connection.companyName,
            "company_is_active": "1",
            "user_id": connection.userId,
            "user_uuid": connection.userUUID,
            "user_name": connection.userName,
            "full_name": connection.fullName,
            "user_is_active": "1",
            "is_active": "1",
            "chat_uuid": connection.chatUUID,
            "created_at": ChatService.currentDateTime(),
            "last_message": "",
            "message_time": ""
        ]

        var reference: DocumentReference?
        reference = db.collection("user_connections").addDocument(data: document) { error in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            guard let id = reference?.documentID else {
                completion(nil, "Could not start this conversation")
                return
            }
            completion(connection.stored(id: id), nil)
        }
    }

    // MARK: - Thread

    /// Live message list for one thread, ordered the way Android orders it.
    ///
    /// The sort is done here rather than with `.order(by: "country_time")`, because pairing that with the
    /// `chat_uuid` equality filter is a composite query, and Firestore rejects it until someone creates a
    /// matching index by hand — which a freshly created project has none of. Android's project only works
    /// because that index was added to it at some point. Sorting in Swift gives the identical order (the
    /// same string field, ascending) with nothing to provision, and matches what `observeConnections`
    /// already does one method up.
    func observeMessages(chatUUID: String,
                         onChange: @escaping ([ChatMessage]) -> Void,
                         onError: @escaping (String) -> Void) -> ListenerRegistration {
        db.collection("chat")
            .whereField("chat_uuid", isEqualTo: chatUUID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onError(error.localizedDescription)
                    return
                }
                let rows = (snapshot?.documents ?? []).map { ChatMessage(id: $0.documentID, data: $0.data()) }
                onChange(rows.sorted { $0.countryTime < $1.countryTime })
            }
    }

    /// Adds the message, then updates the connection's `last_message` / `message_time` so the inbox row
    /// moves — the same two steps, in the same order, as `Chat.sendMessageFirebase()`.
    ///
    /// A pending connection is written first, which is Android's send-button branch: `if(userConnection)
    /// sendMessageFirebase(...) else createUserConnectionOnFireStore()`, where the create's success
    /// handler sends the message that triggered it. The stored connection comes back through the
    /// completion so the caller can keep the document id it now has.
    func send(_ message: String,
              in connection: ChatConnection,
              as role: ChatRole,
              completion: @escaping (_ connection: ChatConnection?, _ error: String?) -> Void) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(connection, nil)
            return
        }

        guard !connection.isPending else {
            createConnection(connection) { [weak self] created, error in
                guard let created = created else {
                    completion(nil, error ?? "Could not start this conversation")
                    return
                }
                self?.send(trimmed, in: created, as: role, completion: completion)
            }
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
                completion(nil, error.localizedDescription)
                return
            }
            // Android's order: the message lands, then `updateLastMessage`, then the push — and it waits
            // for none of them.
            self?.db.collection("user_connections").document(connection.id).updateData([
                "last_message": trimmed,
                "message_time": countryTime
            ]) { updateError in
                completion(connection, updateError?.localizedDescription)
            }
            ChatService.notifyRecipient(of: trimmed, in: connection, as: role)
        }
    }

    /// Asks the backend to push the message to whoever is on the other end.
    private static func notifyRecipient(of message: String, in connection: ChatConnection, as role: ChatRole) {
        GCD.async(.Background) {
            switch role {
            case .user:
                LoginService.shared().notifyCompanyOfChatMessage(message: message,
                                                                 companySerialNo: connection.companySerialNo)
            case .company:
                LoginService.shared().notifyUserOfChatMessage(message: message,
                                                              userName: connection.userName,
                                                              chatUUID: connection.chatUUID,
                                                              companySerialNo: connection.companySerialNo)
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

    /// Reads one of those strings back for display.
    ///
    /// Parsed with the exact written format rather than handed to `VendorTheme.date`, which tries
    /// `yyyy-MM-dd` first and only falls back to the swapped order when that fails. For a chat timestamp
    /// it never fails: `2026-10-08` is the 10th of August here, but it parses cleanly as the 8th of
    /// October, so every message whose day is 12 or lower rendered under the wrong month. Chat always
    /// writes the swapped order, so there is nothing to guess.
    ///
    /// Both timestamps shown in the UI (`country_time`, and `message_time` on the inbox row) are Dubai
    /// wall-clock, so parsing and formatting in that zone displays exactly what was written.
    static func display(_ raw: String) -> String {
        format(raw, as: "d MMM yyyy, h:mm a")
    }

    /// The same, without the time, for dense inbox rows.
    static func shortDisplay(_ raw: String) -> String {
        format(raw, as: "d MMM yyyy")
    }

    private static func format(_ raw: String, as pattern: String) -> String {
        let zone = TimeZone(identifier: "Asia/Dubai") ?? .current
        guard let date = formatter(timeZone: zone).date(from: raw) else { return raw }
        let out = DateFormatter()
        out.locale = .current
        out.timeZone = zone
        out.dateFormat = pattern
        return out.string(from: date)
    }
}
