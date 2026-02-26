//  VendorNotificationsView.swift
import SwiftUI
struct VendorNotificationsView: View {
    @StateObject private var viewModel = VendorNotificationsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.notifications.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.notifications.isEmpty { EmptyStateView(icon: "bell", title: "No Notifications", message: "No notifications yet") }
            else {
                List(viewModel.notifications.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.notifications[i].title).font(AppTheme.Fonts.semibold(16))
                        Text(viewModel.notifications[i].message).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        Text(viewModel.notifications[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Notifications")
        .onAppear { viewModel.loadNotifications() }
    }
}
class VendorNotificationsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var notifications: [VendorNotification] = []
    func loadNotifications() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_notifications", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["notifications"].array {
                    self?.notifications = arr.map { VendorNotification(id: $0["id"].stringValue, title: $0["title"].stringValue, message: $0["message"].stringValue, date: $0["date"].stringValue) }
                }
            }
        }
    }
}
struct VendorNotification: Identifiable { let id, title, message, date: String }
