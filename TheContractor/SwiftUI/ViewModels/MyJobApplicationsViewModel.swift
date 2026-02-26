//  MyJobApplicationsViewModel.swift
import SwiftUI

class MyJobApplicationsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var applications: [JobApplication] = []
    
    func loadApplications() {
        isLoading = true
        guard let userId = UserDefaultsManager.shared.userInfo?.id else { return }
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_my_job_applications", params: ["user_id": userId]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["applications"].array {
                    self?.applications = arr.map { JobApplication(id: $0["id"].stringValue, jobTitle: $0["job_title"].stringValue, companyName: $0["company_name"].stringValue, appliedDate: $0["applied_date"].stringValue, status: $0["status"].stringValue) }
                }
            }
        }
    }
}
