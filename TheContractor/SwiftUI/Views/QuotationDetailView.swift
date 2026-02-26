//  QuotationDetailView.swift
import SwiftUI
struct QuotationDetailView: View {
    let quotation: QuotationModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quotation #\(quotation.id)").font(AppTheme.Fonts.bold(20))
                    Text(quotation.status).font(AppTheme.Fonts.medium(14)).foregroundColor(quotation.status == "Approved" ? .green : .orange)
                }
                Divider()
                DetailRow(label: "Company", value: quotation.companyName)
                DetailRow(label: "Description", value: quotation.description)
                DetailRow(label: "Location", value: quotation.location)
                DetailRow(label: "Date & Time", value: quotation.dateTime)
                DetailRow(label: "Submitted", value: quotation.date)
            }
            .padding(16)
        }
        .navigationTitle("Quotation Details")
    }
}
