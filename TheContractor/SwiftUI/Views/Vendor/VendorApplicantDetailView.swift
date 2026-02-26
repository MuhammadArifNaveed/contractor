//  VendorApplicantDetailView.swift
import SwiftUI
struct VendorApplicantDetailView: View {
    let applicant: JobApplicant
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle().fill(Color.blue.opacity(0.2)).frame(width: 80, height: 80).overlay(Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.blue))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(applicant.name).font(AppTheme.Fonts.bold(20))
                        Text("Applied: \(applicant.appliedDate)").font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                    }
                }
                Divider()
                HStack(spacing: 12) {
                    PrimaryButton(title: "Accept") { print("Accept") }
                    Button("Reject") { print("Reject") }
                        .frame(maxWidth: .infinity).padding(14).background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(8).font(AppTheme.Fonts.semibold(16))
                }
            }
            .padding(16)
        }
        .navigationTitle("Applicant Details")
    }
}
