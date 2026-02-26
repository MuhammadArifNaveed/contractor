//  ChatListViewModel.swift
import SwiftUI

class ChatListViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var chats: [ChatItem] = []
    func loadChats() {
        isLoading = true
        guard let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_chats", params: ["user_id": userId]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["chats"].array {
                    self?.chats = arr.map { ChatItem(id: $0["id"].stringValue, name: $0["name"].stringValue, lastMessage: $0["last_message"].stringValue, time: $0["time"].stringValue) }
                }
            }
        }
    }
    func openChat(_ chat: ChatItem) { print("Open chat: \(chat.name)") }
}
