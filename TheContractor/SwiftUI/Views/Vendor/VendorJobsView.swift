//  VendorJobsView.swift
import SwiftUI
struct VendorJobsView: View {
    @StateObject private var viewModel = VendorJobsViewModel()
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                Text("My Jobs").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Button(action: { viewModel.showPostJob() }) {
                    Image(systemName: "plus").font(.system(size: 18, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal, 4).frame(height: 56).background(yellow)
            ZStack {
                if viewModel.isLoading && viewModel.jobs.isEmpty { LoadingView(message: "Loading...") }
                else if viewModel.jobs.isEmpty { EmptyStateView(icon: "briefcase", title: "No Jobs", message: "No jobs posted yet") }
                else {
                    List(viewModel.jobs.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.jobs[i].title).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.jobs[i].location).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                            HStack { Text(viewModel.jobs[i].date).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray); Spacer(); Text("\(viewModel.jobs[i].applicants) applicants").font(AppTheme.Fonts.medium(12)).foregroundColor(.blue) }
                        }
                    }
                }
            }
            .onAppear { viewModel.loadJobs() }
        }
        .navigationBarHidden(true)
    }
}
class VendorJobsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var jobs: [VendorJob] = []
    func loadJobs() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_jobs", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["jobs"].array {
                    self?.jobs = arr.map { VendorJob(id: $0["id"].stringValue, title: $0["title"].stringValue, location: $0["location"].stringValue, date: $0["date"].stringValue, applicants: $0["applicants"].stringValue) }
                }
            }
        }
    }
    func showPostJob() { print("Show post job") }
}
struct VendorJob: Identifiable { let id, title, location, date, applicants: String }
