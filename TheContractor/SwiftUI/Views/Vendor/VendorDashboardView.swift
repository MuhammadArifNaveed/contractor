//  VendorDashboardView.swift
import SwiftUI
struct VendorDashboardView: View {
    @StateObject private var viewModel = VendorDashboardViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: "Enquiries", count: viewModel.stats.enquiries, icon: "envelope", color: .blue)
                    StatCard(title: "Quotations", count: viewModel.stats.quotations, icon: "doc.text", color: .green)
                    StatCard(title: "Jobs", count: viewModel.stats.jobs, icon: "briefcase", color: .orange)
                    StatCard(title: "Freelancers", count: viewModel.stats.freelancers, icon: "person.2", color: .purple)
                }
            }
            .padding(16)
        }
        .navigationTitle("Dashboard")
        .onAppear { viewModel.loadStats() }
    }
}
struct StatCard: View {
    let title, count, icon: String
    let color: Color
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 40)).foregroundColor(color)
            Text(count).font(AppTheme.Fonts.bold(24))
            Text(title).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4)
    }
}
class VendorDashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats()
    func loadStats() {
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_dashboard", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                if success, let json = json {
                    self?.stats = DashboardStats(enquiries: json["enquiries"].stringValue, quotations: json["quotations"].stringValue, jobs: json["jobs"].stringValue, freelancers: json["freelancers"].stringValue)
                }
            }
        }
    }
}
struct DashboardStats { var enquiries = "0", quotations = "0", jobs = "0", freelancers = "0" }
