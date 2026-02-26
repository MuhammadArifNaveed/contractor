//  VendorFreelancerDetailView.swift
import SwiftUI
struct VendorFreelancerDetailView: View {
    let freelancer: VendorFreelancer
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle().fill(Color.blue.opacity(0.2)).frame(width: 80, height: 80).overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.blue))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(freelancer.name).font(AppTheme.Fonts.bold(20))
                        Text(freelancer.category).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                        RatingView(rating: Double(freelancer.rating) ?? 0, size: 16)
                    }
                }
                Divider()
                PrimaryButton(title: "Hire Freelancer") { print("Hire") }
            }
            .padding(16)
        }
        .navigationTitle("Freelancer Details")
    }
}
