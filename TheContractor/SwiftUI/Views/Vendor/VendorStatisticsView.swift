//  VendorStatisticsView.swift
import SwiftUI
struct VendorStatisticsView: View {
    @StateObject private var viewModel = VendorStatisticsViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Monthly Overview").font(AppTheme.Fonts.bold(20))
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(title: "Total Enquiries", count: viewModel.stats.totalEnquiries, icon: "envelope", color: .blue)
                    StatCard(title: "Completed", count: viewModel.stats.completed, icon: "checkmark.circle", color: .green)
                    StatCard(title: "Pending", count: viewModel.stats.pending, icon: "clock", color: .orange)
                    StatCard(title: "Revenue", count: viewModel.stats.revenue, icon: "dollarsign.circle", color: .purple)
                }
            }
            .padding(16)
        }
        .navigationTitle("Statistics")
        .onAppear { viewModel.loadStats() }
    }
}
class VendorStatisticsViewModel: ObservableObject {
    @Published var stats = VendorStats()
    func loadStats() {
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_statistics", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                if success, let json = json {
                    self?.stats = VendorStats(totalEnquiries: json["total_enquiries"].stringValue, completed: json["completed"].stringValue, pending: json["pending"].stringValue, revenue: json["revenue"].stringValue)
                }
            }
        }
    }
}
struct VendorStats { var totalEnquiries = "0", completed = "0", pending = "0", revenue = "$0" }
