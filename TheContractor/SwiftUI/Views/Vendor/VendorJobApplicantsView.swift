//  VendorJobApplicantsView.swift
import SwiftUI
struct VendorJobApplicantsView: View {
    let jobId: String
    @StateObject private var viewModel = VendorJobApplicantsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.applicants.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.applicants.isEmpty { EmptyStateView(icon: "person.2", title: "No Applicants", message: "No one has applied yet") }
            else {
                List(viewModel.applicants.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Circle().fill(Color.blue.opacity(0.2)).frame(width: 50, height: 50).overlay(Image(systemName: "person.fill").foregroundColor(.blue))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.applicants[i].name).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.applicants[i].appliedDate).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                        }
                        Spacer()
                        Button("View") { viewModel.viewApplicant(viewModel.applicants[i]) }.font(AppTheme.Fonts.medium(14)).foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .navigationTitle("Applicants")
        .onAppear { viewModel.loadApplicants(jobId: jobId) }
    }
}
class VendorJobApplicantsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var applicants: [JobApplicant] = []
    func loadApplicants(jobId: String) {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/job_applicants", params: ["job_id": jobId]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["applicants"].array {
                    self?.applicants = arr.map { JobApplicant(id: $0["id"].stringValue, name: $0["name"].stringValue, appliedDate: $0["applied_date"].stringValue) }
                }
            }
        }
    }
    func viewApplicant(_ applicant: JobApplicant) { print("View: \(applicant.name)") }
}
struct JobApplicant: Identifiable { let id, name, appliedDate: String }
