//  ChatListView.swift
import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.chats.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.chats.isEmpty { EmptyStateView(icon: "message", title: "No Chats", message: "No conversations yet") }
            else {
                List(viewModel.chats.indices, id: \.self) { i in
                    Button(action: { viewModel.openChat(viewModel.chats[i]) }) {
                        HStack(spacing: 12) {
                            Circle().fill(AppTheme.Colors.primary.opacity(0.2)).frame(width: 50, height: 50).overlay(Image(systemName: "person.fill").foregroundColor(AppTheme.Colors.primary))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.chats[i].name).font(AppTheme.Fonts.semibold(16))
                                Text(viewModel.chats[i].lastMessage).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray).lineLimit(1)
                            }
                            Spacer()
                            Text(viewModel.chats[i].time).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Messages")
        .onAppear { viewModel.loadChats() }
    }
}

struct ChatItem: Identifiable { let id, name, lastMessage, time: String }
