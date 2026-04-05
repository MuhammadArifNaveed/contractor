//
//  JobDetailViewModel.swift
//  TheContractor
//
//  ViewModel for Job Details screen
//

import SwiftUI
import Combine

class JobDetailViewModel: ObservableObject {
    @Published var job: JobModel
    @Published var isApplying = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    init(job: JobModel) {
        self.job = job
    }
    
    func applyForJob() {
        guard Global.shared.isLogedIn, let userId = Global.shared.user?.id, !userId.isEmpty else {
            errorMessage = "Please login to apply for jobs."
            showErrorAlert = true
            return
        }
        guard !job.jobUuid.isEmpty else {
            errorMessage = "Invalid job."
            showErrorAlert = true
            return
        }
        isApplying = true
        let params: [String: Any] = ["user_id": userId, "job_uuid": job.jobUuid]
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/jobs/job_apply", params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isApplying = false
                if success, let j = json, j["error"].stringValue == "false" {
                    self.showSuccessAlert = true
                } else {
                    self.errorMessage = json?["message"].stringValue ?? message ?? "Failed to apply for job"
                    self.showErrorAlert = true
                }
            }
        }
    }
}
