//
//  JobDetailView.swift
//  TheContractor
//
//  Job details screen with apply functionality
//

import SwiftUI

struct JobDetailView: View {
    @StateObject private var viewModel: JobDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(job: JobModel) {
        _viewModel = StateObject(wrappedValue: JobDetailViewModel(job: job))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                // Job Header
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(viewModel.job.title)
                        .font(AppTheme.Fonts.bold(22))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text(viewModel.job.companyName)
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    HStack(spacing: 16) {
                        if !viewModel.job.location.isEmpty {
                            Label(viewModel.job.location, systemImage: "location")
                                .font(AppTheme.Fonts.regular(14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        if !viewModel.job.jobType.isEmpty {
                            Label(viewModel.job.jobType, systemImage: "briefcase")
                                .font(AppTheme.Fonts.regular(14))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    
                    if !viewModel.job.salary.isEmpty {
                        Text(viewModel.job.salary)
                            .font(AppTheme.Fonts.bold(18))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .padding(AppTheme.Spacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(AppTheme.CornerRadius.medium)
                
                // Job Description
                if !viewModel.job.description.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Job Description")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(viewModel.job.description)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(AppTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                // Requirements
                if !viewModel.job.requirements.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Requirements")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(viewModel.job.requirements)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(AppTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(AppTheme.CornerRadius.medium)
                }
                
                Spacer()
            }
            .padding(AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.applyForJob() }) {
                    if viewModel.isApplying {
                        ProgressView()
                    } else {
                        Text("Apply")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isApplying)
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Application submitted successfully!")
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Failed to apply for job")
        }
    }
}

// MARK: - Preview
struct JobDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JobDetailView(job: JobModel())
        }
    }
}
