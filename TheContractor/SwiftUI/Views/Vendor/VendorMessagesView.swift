//  VendorMessagesView.swift
import SwiftUI
struct VendorMessagesView: View {
    @StateObject private var viewModel = VendorMessagesViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.messages.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.messages.isEmpty { EmptyStateView(icon: "message", title: "No Messages", message: "No messages yet") }
            else {
                List(viewModel.messages.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Circle().fill(Color.blue.opacity(0.2)).frame(width: 50, height: 50).overlay(Image(systemName: "person.fill").foregroundColor(.blue))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.messages[i].from).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.messages[i].message).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray).lineLimit(1)
                        }
                        Spacer()
                        Text(viewModel.messages[i].time).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Messages")
        .onAppear { viewModel.loadMessages() }
    }
}
class VendorMessagesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var messages: [VendorMessage] = []
    func loadMessages() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_messages", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["messages"].array {
                    self?.messages = arr.map { VendorMessage(id: $0["id"].stringValue, from: $0["from"].stringValue, message: $0["message"].stringValue, time: $0["time"].stringValue) }
                }
            }
        }
    }
}
struct VendorMessage: Identifiable { let id, from, message, time: String }
