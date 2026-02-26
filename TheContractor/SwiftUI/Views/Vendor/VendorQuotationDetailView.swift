//  VendorQuotationDetailView.swift
import SwiftUI
struct VendorQuotationDetailView: View {
    let quotation: VendorQuotation
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Request #\(quotation.id)").font(AppTheme.Fonts.bold(20))
                Divider()
                DetailRow(label: "User", value: quotation.userName)
                DetailRow(label: "Description", value: quotation.description)
                DetailRow(label: "Status", value: quotation.status)
            }
            .padding(16)
        }
        .navigationTitle("Quotation Details")
    }
}
