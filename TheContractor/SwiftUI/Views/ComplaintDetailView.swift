//  ComplaintDetailView.swift
import SwiftUI
struct ComplaintDetailView: View {
    let complaint: ComplaintModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Complaint #\(complaint.id)").font(AppTheme.Fonts.bold(20))
                StatusBadge(status: complaint.status)
                Divider()
                DetailRow(label: "Company", value: complaint.companyName)
                DetailRow(label: "Date", value: complaint.date)
                DetailRow(label: "Description", value: complaint.description)
                if !complaint.response.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Response").font(AppTheme.Fonts.semibold(16))
                        Text(complaint.response).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                    }
                    .padding(12).background(AppTheme.Colors.secondaryBackground).cornerRadius(8)
                }
            }
            .padding(16)
        }
        .navigationTitle("Complaint Details")
    }
}
