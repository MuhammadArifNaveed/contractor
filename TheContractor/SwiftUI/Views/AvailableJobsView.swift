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
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.jobs.isEmpty {
                LoadingView(message: "Loading jobs...")
            } else if let error = viewModel.errorMessage, viewModel.jobs.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadJobs()
                }
            } else if viewModel.jobs.isEmpty {
                EmptyStateView(
                    icon: "briefcase",
                    title: "No Jobs Available",
                    message: "There are no job postings at the moment."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.jobs.indices, id: \.self) { index in
                            JobCard(job: viewModel.jobs[index]) {
                                viewModel.selectJob(viewModel.jobs[index])
                            }
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            
                            if index == viewModel.jobs.count - 2 {
                                Color.clear
                                    .frame(height: 1)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded()
                                    }
                            }
                        }
                        
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top, AppTheme.Spacing.medium)
                }
                .background(AppTheme.Colors.background)
            }
        }
        .navigationTitle("Available Jobs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchJobsView()
        }
        .onAppear {
            if viewModel.jobs.isEmpty {
                viewModel.loadJobs()
            }
        }
    }
}

// MARK: - Job Card
struct JobCard: View {
    let job: JobModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text(job.title)
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                if !job.companyName.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text(job.companyName)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                HStack(spacing: 12) {
                    if !job.location.isEmpty {
                        Label(job.location, systemImage: "location")
                            .font(AppTheme.Fonts.regular(13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    if !job.jobType.isEmpty {
                        Label(job.jobType, systemImage: "briefcase")
                            .font(AppTheme.Fonts.regular(13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                if !job.salary.isEmpty {
                    Text(job.salary)
                        .font(AppTheme.Fonts.semibold(14))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                HStack {
                    Label(job.postedDate, systemImage: "calendar")
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.gray)
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Job Model
struct JobModel: Identifiable {
    let id: String
    let title: String
    let companyName: String
    let location: String
    let jobType: String
    let salary: String
    let description: String
    let requirements: String
    let postedDate: String
    let category: String
    
    init() {
        self.id = ""
        self.title = ""
        self.companyName = ""
        self.location = ""
        self.jobType = ""
        self.salary = ""
        self.description = ""
        self.requirements = ""
        self.postedDate = ""
        self.category = ""
    }
    
    init(id: String, title: String, companyName: String, location: String, jobType: String, salary: String, description: String, requirements: String, postedDate: String, category: String) {
        self.id = id
        self.title = title
        self.companyName = companyName
        self.location = location
        self.jobType = jobType
        self.salary = salary
        self.description = description
        self.requirements = requirements
        self.postedDate = postedDate
        self.category = category
    }
}

// MARK: - Preview
struct AvailableJobsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AvailableJobsView()
        }
    }
}
