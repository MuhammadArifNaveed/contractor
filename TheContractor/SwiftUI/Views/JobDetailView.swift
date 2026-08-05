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
    private let yellow = VendorTheme.accent
    private let logoBase = "https://contractor.bidcont.com/uploads/companies/"

    init(job: JobModel) {
        _viewModel = StateObject(wrappedValue: JobDetailViewModel(job: job))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar
            VendorTopBar(title: "Job Detail", onBack: { presentationMode.wrappedValue.dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Company header
                    HStack(alignment: .center, spacing: 12) {
                        AsyncImage(url: URL(string: logoBase + viewModel.job.companyLogo)) { phase in
                            if let img = phase.image { img.resizable().scaledToFill() }
                            else { Image(systemName: "building.2").foregroundColor(.gray) }
                        }
                        .frame(width: 60, height: 60)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(6)
                        .clipped()
                        VStack(alignment: .leading, spacing: 3) {
                            Text(viewModel.job.companyName).font(.system(size: 16, weight: .bold))
                            Text(viewModel.job.companyCategory).font(.system(size: 13)).foregroundColor(.gray)
                            Text(viewModel.job.cityName).font(.system(size: 13)).foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)

                    Divider()
                    detailRow(label: "Job Title", value: viewModel.job.jobTitle)
                    Divider().padding(.leading, 16)
                    twoColRow(l1: "Job Category", v1: viewModel.job.jobCategory,
                              l2: "Job Type", v2: viewModel.job.jobType)
                    Divider().padding(.leading, 16)
                    twoColRow(l1: "Job Location",
                              v1: viewModel.job.jobLocation.isEmpty ? viewModel.job.cityName : viewModel.job.jobLocation,
                              l2: "Job Salary", v2: viewModel.job.salary)
                    Divider().padding(.leading, 16)
                    detailRow(label: "Deadline", value: viewModel.job.deadline)
                    Divider().padding(.leading, 16)
                    detailRow(label: "Description", value: viewModel.job.jobDescription)

                    // Apply button
                    Button(action: { viewModel.applyForJob() }) {
                        HStack {
                            Spacer()
                            if viewModel.isApplying {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Apply").font(.system(size: 17, weight: .semibold)).foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .frame(height: 52)
                        .background(yellow)
                        .cornerRadius(6)
                    }
                    .disabled(viewModel.isApplying)
                    .padding(16)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { presentationMode.wrappedValue.dismiss() }
        } message: { Text("Application submitted successfully!") }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") {}
        } message: { Text(viewModel.errorMessage ?? "Failed to apply for job") }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12)).foregroundColor(.gray)
            Text(value.isEmpty ? "-" : value).font(.system(size: 15, weight: .medium))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }

    private func twoColRow(l1: String, v1: String, l2: String, v2: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(l1).font(.system(size: 12)).foregroundColor(.gray)
                Text(v1.isEmpty ? "-" : v1).font(.system(size: 15, weight: .medium))
            }.frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text(l2).font(.system(size: 12)).foregroundColor(.gray)
                Text(v2.isEmpty ? "-" : v2).font(.system(size: 15, weight: .medium))
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color.white)
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
