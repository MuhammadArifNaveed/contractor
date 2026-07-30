//
//  VendorJobDetailView.swift
//  TheContractor
//
//  Port of Android's `VendorJobDetail` — POST jobs/view_job keyed on `job_uuid`,
//  response key `job_details`.
//

import SwiftUI
import SwiftyJSON

struct VendorJobDetailView: View {
    let jobUuid: String

    @State private var state: VendorLoadState = .loading
    @State private var job: VendorJobRow?
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Job Details", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "doc.text.magnifyingglass",
                                     title: "Job unavailable",
                                     message: "This job could not be loaded.")
                case .loaded:
                    if let job = job {
                        detail(job)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func detail(_ job: VendorJobRow) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(job.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    Text(job.approvalLabel)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(job.approved == "1" ? VendorTheme.positive
                                                             : VendorTheme.negative)
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Category", value: job.categoryName)
                    field(label: "Job Type", value: job.jobType)
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Location", value: job.locationName)
                    field(label: "Vacancies", value: job.vacancies)
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Salary", value: [job.currency, job.salary].filter { !$0.isEmpty }.joined(separator: " "))
                    field(label: "Deadline", value: VendorTheme.date(job.deadline))
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Posted", value: VendorTheme.date(job.createdAt))
                    field(label: "Applications", value: job.applicationCount)
                }

                if !job.description.isEmpty {
                    divider
                    field(label: "Description", value: job.description)
                }

                divider

                NavigationLink(destination: VendorJobApplicantsView(jobUuid: job.jobUuid, jobTitle: job.title)) {
                    HStack {
                        Text("View Applicants")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(VendorTheme.textSecondary)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(10)
        }
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(VendorTheme.textSecondary)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var divider: some View {
        Rectangle()
            .fill(VendorTheme.separator)
            .frame(height: 0.5)
            .padding(.vertical, 10)
    }

    private func load() {
        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorJobDetail(jobUuid: jobUuid) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json, json["job_details"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    job = VendorJobRow(json["job_details"])
                    state = .loaded
                }
            }
        }
    }
}
