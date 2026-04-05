//  DirectHiringView.swift
import SwiftUI
struct DirectHiringView: View {
    @StateObject private var viewModel = DirectHiringViewModel()
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                Text("Direct Hiring").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4).frame(height: 56).background(yellow)
            ZStack {
                if viewModel.isLoading && viewModel.items.isEmpty { LoadingView(message: "Loading...") }
                else if viewModel.items.isEmpty { EmptyStateView(icon: "person.2", title: "No Direct Hiring", message: "No direct hiring requests") }
                else {
                    List(viewModel.items.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.items[i].title).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.items[i].company).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                            HStack { Text(viewModel.items[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray); Spacer(); Text(viewModel.items[i].status).font(AppTheme.Fonts.medium(12)).foregroundColor(.blue) }
                        }
                    }
                }
            }
            .onAppear { viewModel.loadItems() }
        }
        .navigationBarHidden(true)
    }
}
class DirectHiringViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var items: [DirectHiringItem] = []
    func loadItems() {
        isLoading = true
        guard let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_direct_hiring", params: ["user_id": userId]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["items"].array {
                    self?.items = arr.map { DirectHiringItem(id: $0["id"].stringValue, title: $0["title"].stringValue, company: $0["company"].stringValue, date: $0["date"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
struct DirectHiringItem: Identifiable { let id, title, company, date, status: String }
