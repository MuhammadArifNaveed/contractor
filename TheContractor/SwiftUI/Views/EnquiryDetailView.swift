//  EnquiryDetailView.swift
import SwiftUI
struct EnquiryDetailView: View {
    let enquiry: EnquiryModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enquiry #\(enquiry.id)").font(AppTheme.Fonts.bold(20))
                    StatusBadge(status: enquiry.status)
                }
                Divider()
                DetailRow(label: "Company", value: enquiry.companyName)
                DetailRow(label: "Date", value: enquiry.date)
                DetailRow(label: "Description", value: enquiry.description)
                if !enquiry.response.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response").font(AppTheme.Fonts.semibold(16))
                        Text(enquiry.response).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                    }
                    .padding(12).background(AppTheme.Colors.secondaryBackground).cornerRadius(8)
                }
            }
            .padding(16)
        }
        .navigationTitle("Enquiry Details")
    }
}
struct DetailRow: View {
    let label, value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(AppTheme.Fonts.medium(12)).foregroundColor(.gray)
            Text(value).font(AppTheme.Fonts.regular(14))
        }
    }
}
