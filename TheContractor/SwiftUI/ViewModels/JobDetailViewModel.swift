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
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            errorMessage = "User not logged in"
            showErrorAlert = true
            return
        }
        
        isApplying = true
        
        let params = [
            "user_id": userId,
            "job_id": job.id
        ]
        
        let completeURL = "https://contractor.bidcont.com/rest/Home/apply_for_job"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, _, _ in
            DispatchQueue.main.async {
                self?.isApplying = false
                
                if success {
                    self?.showSuccessAlert = true
                } else {
                    self?.errorMessage = message ?? "Failed to apply for job"
                    self?.showErrorAlert = true
                }
            }
        }
    }
}
