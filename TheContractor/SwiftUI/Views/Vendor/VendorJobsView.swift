//
//  VendorJobsView.swift
//  TheContractor
//
//  Two screens from Android's vendor drawer item "Jobs Portal":
//    • `VendorDashboardJobs` — job counts per status (POST jobs/app_jobs_dashboard)
//    • `VendorJobListing`    — the jobs in one status (POST jobs/jobs_listing)
//
//  Android reuses `vendor_dashboard_row.xml` for the grid, so the cards are the same ones the
//  enquiry and quotation dashboards use.
//

import SwiftUI
import SwiftyJSON

// MARK: - Jobs dashboard

struct VendorJobsView: View {
    @State private var state: VendorLoadState = .loading
    @State private var counts: [VendorDashboardCount] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Jobs Portal")

                ZStack {
                    VendorHomeStyle.background
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                    case .noData:
                        Text("Data Not Found")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    case .loaded:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                                      spacing: 4) {
                                ForEach(counts) { count in
                                    NavigationLink(destination: VendorJobListingView(status: count)) {
                                        VendorDashboardCountCard(count: count)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorJobsDashboard(vendorId: session.id,
                                                         userId: session.user_id,
                                                         userType: session.user_type) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    counts = json["vendor_dashboard_counts"].arrayValue.map(VendorDashboardCount.init)
                    state = counts.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Jobs in one status

struct VendorJobListingView: View {
    let status: VendorDashboardCount

    @State private var state: VendorLoadState = .loading
    @State private var jobs: [VendorJobRow] = []
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var isMutating = false
    @State private var pendingDelete: VendorJobRow?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: status.name, onBack: { dismiss() })

            ZStack {
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                case .noData:
                    Text("Data Not Found")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(jobs) { job in
                                VendorJobRowCard(job: job,
                                                 onTogglePublish: { togglePublish(job) },
                                                 onDelete: { pendingDelete = job })
                            }
                        }
                        .padding(10)
                    }
                }

                if isMutating {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .alert("Delete this job?", isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } })) {
            Button("Delete", role: .destructive) {
                if let job = pendingDelete { pendingDelete = nil; delete(job) }
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        }
        .onAppear(perform: load)
    }

    private func load() {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorJobListing(statusId: status.id,
                                                      vendorId: session.id,
                                                      userId: session.user_id,
                                                      userType: session.user_type) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    jobs = json["jobs_list"].arrayValue.map(VendorJobRow.init)
                    state = jobs.isEmpty ? .noData : .loaded
                }
            }
        }
    }

    private func togglePublish(_ job: VendorJobRow) {
        isMutating = true
        GCD.async(.Background) {
            LoginService.shared().setVendorJobPublished(jobId: job.id, published: !job.isPublished) { message, success in
                GCD.async(.Main) {
                    isMutating = false
                    if success {
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }

    private func delete(_ job: VendorJobRow) {
        isMutating = true
        GCD.async(.Background) {
            LoginService.shared().deleteVendorJob(jobId: job.id) { message, success in
                GCD.async(.Main) {
                    isMutating = false
                    if success {
                        noticeMessage = message.isEmpty ? "Job deleted." : message
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Model

/// Android's jobs row reduced to what `VendorJobListingAdapter` binds, plus the fields the detail
/// screen shows. `approved` and `status` arrive as strings on some rows and numbers on others, so
/// everything is read through `stringValue`.
struct VendorJobRow: Identifiable {
    let id: String
    let jobUuid: String
    let title: String
    let jobType: String
    let createdAt: String
    let approved: String
    let status: String
    let applicationCount: String
    let categoryName: String
    let locationName: String
    let salary: String
    let currency: String
    let vacancies: String
    let deadline: String
    let description: String

    /// Android shows "Pending" until the job is approved, then "Approved".
    var approvalLabel: String { approved == "1" ? "Approved" : "Pending" }
    var isPublished: Bool { status == "1" }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.jobUuid = json["job_uuid"].stringValue
        self.title = json["title"].stringValue
        self.jobType = json["job_type"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.approved = json["approved"].stringValue
        self.status = json["status"].stringValue
        self.applicationCount = json["application_count"].stringValue
        self.categoryName = json["job_category_name"].stringValue
        self.locationName = json["loaction_name"].stringValue
        self.salary = json["salary"].stringValue
        self.currency = json["currency"].stringValue
        self.vacancies = json["vaccancies"].stringValue
        self.deadline = json["deadline"].stringValue
        self.description = json["description"].stringValue
    }
}

// MARK: - Card

/// Android `vendor_job_listing_custom_row.xml`, including its publish toggle and delete action.
struct VendorJobRowCard: View {
    let job: VendorJobRow
    let onTogglePublish: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            NavigationLink(destination: VendorJobDetailView(jobUuid: job.jobUuid)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(job.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        Text(job.approvalLabel)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(job.approved == "1" ? Color(red: 0.00, green: 0.61, blue: 0.33)
                                                                 : Color(red: 0.84, green: 0.12, blue: 0.12))
                    }

                    Text(job.jobType)
                        .font(.system(size: 13))
                        .foregroundColor(.black)

                    Text(VendorHomeStyle.formatWorkshopDate(job.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())

            Divider()

            HStack(spacing: 16) {
                Button(action: onTogglePublish) {
                    Label(job.isPublished ? "Unpublish" : "Publish",
                          systemImage: job.isPublished ? "eye.slash" : "eye")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.84, green: 0.12, blue: 0.12))
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Text("\(job.applicationCount) applied")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.4))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}
