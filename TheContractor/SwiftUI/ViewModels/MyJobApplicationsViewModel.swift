//  MyJobApplicationsViewModel.swift
import SwiftUI

class MyJobApplicationsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var applications: [JobApplication] = []
    
    func loadApplications() {
        isLoading = true
        guard let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        // Android: jobs/user_job_applies, which also takes a page.
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/jobs/user_job_applies", params: ["user_id": userId, "page": "1"]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Live response key is `job_applications`.
                if success, let arr = json?["job_applications"].array {
                    self?.applications = arr.map { JobApplication(id: $0["id"].stringValue, jobTitle: $0["job_title"].stringValue, companyName: $0["company_name"].stringValue, appliedDate: $0["applied_date"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
