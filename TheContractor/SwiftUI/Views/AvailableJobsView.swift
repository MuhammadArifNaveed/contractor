//
//  AvailableJobsView.swift
//  TheContractor
//
//  Available jobs list screen matching Android AvailableJobs activity
//

import SwiftUI

struct AvailableJobsView: View {
    @StateObject private var viewModel = AvailableJobsViewModel()
    @State private var showSearch = false
    @State private var selectedJob: JobModel?
    private let yellow = VendorTheme.accent

    var body: some View {
        VStack(spacing: 0) {
            // Custom yellow top bar
            VendorTopBar(title: "Available Jobs", onBack: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) },
                         trailingIcon: "magnifyingglass",
                         trailingAction: { showSearch = true })

            ZStack {
                if viewModel.isLoading && viewModel.jobs.isEmpty {
                    LoadingView(message: "Loading jobs...")
                } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
                    ErrorView(message: error) { viewModel.loadJobs() }
                } else if viewModel.jobs.isEmpty {
                    EmptyStateView(icon: "briefcase", title: "No Jobs Available", message: "There are no job postings at the moment.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.Spacing.small) {
                            ForEach(viewModel.jobs.indices, id: \.self) { index in
                                JobCard(job: viewModel.jobs[index]) {
                                    selectedJob = viewModel.jobs[index]
                                }
                                .padding(.horizontal, AppTheme.Spacing.medium)
                                if index == viewModel.jobs.count - 2 {
                                    Color.clear.frame(height: 1).onAppear { viewModel.loadMoreIfNeeded() }
                                }
                            }
                            if viewModel.isLoadingMore {
                                HStack { Spacer(); ProgressView().padding(); Spacer() }
                            }
                            Spacer(minLength: 20)
                        }
                        .padding(.top, AppTheme.Spacing.medium)
                    }
                    .background(AppTheme.Colors.background)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSearch) { SearchJobsView() }
        .sheet(item: $selectedJob) { job in JobDetailView(job: job) }
        .onAppear { if viewModel.jobs.isEmpty { viewModel.loadJobs() } }
    }
}

// MARK: - Job Model (matches AvailableJobListingModel from Android)
struct JobModel: Identifiable {
    let id = UUID()
    let companyId: String
    let companyName: String
    let companyLogo: String
    let companyCategory: String
    let cityName: String
    let jobUuid: String
    let jobTitle: String
    let jobDescription: String
    let jobType: String
    let salary: String
    let deadline: String
    let jobLocation: String
    let jobCategory: String

    init(companyId: String = "", companyName: String = "", companyLogo: String = "",
         companyCategory: String = "", cityName: String = "", jobUuid: String = "",
         jobTitle: String = "", jobDescription: String = "", jobType: String = "",
         salary: String = "", deadline: String = "", jobLocation: String = "", jobCategory: String = "") {
        self.companyId = companyId; self.companyName = companyName
        self.companyLogo = companyLogo; self.companyCategory = companyCategory
        self.cityName = cityName; self.jobUuid = jobUuid
        self.jobTitle = jobTitle; self.jobDescription = jobDescription
        self.jobType = jobType; self.salary = salary
        self.deadline = deadline; self.jobLocation = jobLocation
        self.jobCategory = jobCategory
    }
}

// MARK: - Job Card (matches Android AvailableJobAdapter layout)
struct JobCard: View {
    let job: JobModel
    let onTap: () -> Void
    private let logoBase = "https://contractor.bidcont.com/uploads/companies/"

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Company row: logo + name + category
                HStack(alignment: .top, spacing: 10) {
                    AsyncImage(url: URL(string: logoBase + job.companyLogo)) { phase in
                        if let img = phase.image { img.resizable().scaledToFill() }
                        else { Image(systemName: "building.2").foregroundColor(.gray) }
                    }
                    .frame(width: 48, height: 48)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(4)
                    .clipped()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(job.companyName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text(job.companyCategory)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                // Job title with category in brackets
                let titleDisplay = job.jobCategory.isEmpty
                    ? job.jobTitle
                    : "\(job.jobTitle) ( \(job.jobCategory) )"
                Text(titleDisplay)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // Pill tags: type | deadline | location
                HStack(spacing: 6) {
                    if !job.jobType.isEmpty { PillTag(text: job.jobType) }
                    if !job.deadline.isEmpty { PillTag(text: job.deadline) }
                    if !job.jobLocation.isEmpty { PillTag(text: job.jobLocation) }
                    else if !job.cityName.isEmpty { PillTag(text: job.cityName) }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Pill Tag
private struct PillTag: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(UIColor.systemGray3), lineWidth: 1))
    }
}

