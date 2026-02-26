//  AboutUsView.swift
import SwiftUI
struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About The Contractor").font(AppTheme.Fonts.bold(24))
                Text("The Contractor is your one-stop solution for finding trusted contractors and service providers.").font(AppTheme.Fonts.regular(16)).foregroundColor(.gray)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "envelope", title: "Email", value: "info@contractor.com")
                    InfoRow(icon: "phone", title: "Phone", value: "+1234567890")
                    InfoRow(icon: "location", title: "Address", value: "123 Main St, City")
                }
            }
            .padding(16)
        }
        .navigationTitle("About Us")
    }
}
struct InfoRow: View {
    let icon, title, value: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(AppTheme.Colors.primary).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(AppTheme.Fonts.medium(12)).foregroundColor(.gray)
                Text(value).font(AppTheme.Fonts.regular(14))
            }
        }
    }
}
