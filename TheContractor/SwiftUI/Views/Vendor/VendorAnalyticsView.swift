//  VendorAnalyticsView.swift
import SwiftUI
struct VendorAnalyticsView: View {
    @StateObject private var viewModel = VendorAnalyticsViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Performance Analytics").font(AppTheme.Fonts.bold(20))
                VStack(alignment: .leading, spacing: 12) {
                    AnalyticsRow(title: "Total Views", value: viewModel.analytics.totalViews, icon: "eye", color: .blue)
                    AnalyticsRow(title: "Conversion Rate", value: viewModel.analytics.conversionRate, icon: "chart.line.uptrend.xyaxis", color: .green)
                    AnalyticsRow(title: "Average Rating", value: viewModel.analytics.avgRating, icon: "star", color: .orange)
                    AnalyticsRow(title: "Response Time", value: viewModel.analytics.responseTime, icon: "clock", color: .purple)
                }
                .padding(16).background(Color.white).cornerRadius(12).shadow(color: Color.black.opacity(0.05), radius: 4)
            }
            .padding(16)
        }
        .navigationTitle("Analytics")
        .onAppear { viewModel.loadAnalytics() }
    }
}
struct AnalyticsRow: View {
    let title, value, icon: String
    let color: Color
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(color).frame(width: 24)
            Text(title).font(AppTheme.Fonts.regular(14))
            Spacer()
            Text(value).font(AppTheme.Fonts.bold(16)).foregroundColor(color)
        }
    }
}
class VendorAnalyticsViewModel: ObservableObject {
    @Published var analytics = VendorAnalytics()
    func loadAnalytics() {
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_analytics", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                if success, let json = json {
                    self?.analytics = VendorAnalytics(totalViews: json["total_views"].stringValue, conversionRate: json["conversion_rate"].stringValue, avgRating: json["avg_rating"].stringValue, responseTime: json["response_time"].stringValue)
                }
            }
        }
    }
}
struct VendorAnalytics { var totalViews = "0", conversionRate = "0%", avgRating = "0.0", responseTime = "0h" }
