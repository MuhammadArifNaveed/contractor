//  VendorJobDetailView.swift
import SwiftUI
struct VendorJobDetailView: View {
    let job: VendorJob
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(job.title).font(AppTheme.Fonts.bold(20))
                Divider()
                DetailRow(label: "Location", value: job.location)
                DetailRow(label: "Posted", value: job.date)
                DetailRow(label: "Applicants", value: job.applicants)
                NavigationLink(destination: Text("Applicants List")) {
                    HStack { Text("View Applicants").font(AppTheme.Fonts.semibold(16)); Spacer(); Image(systemName: "chevron.right") }
                        .padding(16).background(Color.white).cornerRadius(8)
                }
            }
            .padding(16)
        }
        .navigationTitle("Job Details")
    }
}
