//
//  AvailableJobsViewModel.swift
//  TheContractor
//
//  ViewModel for Available Jobs list
//

import SwiftUI
import Combine
import SwiftyJSON

class AvailableJobsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var jobs: [JobModel] = []
    
    private var currentPage = 1
    private var lastPage = 1
    private var canLoadMore = true

    private let jobsURL = "https://contractor.bidcont.com/rest/jobs/search_jobs"

    func loadJobs(refresh: Bool = false) {
        if refresh { currentPage = 1; jobs.removeAll(); canLoadMore = true }
        guard !isLoading else { return }
        isLoading = true; errorMessage = nil
        let params: [String: Any] = ["page": "\(currentPage)", "jobs": "", "job_category": "", "job_city": ""]
        LoginService.shared().makePostAPICall(with: jobsURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json = json {
                    self.lastPage = json["total_page"].intValue
                    let newJobs = json["available_jobs"].arrayValue.map { self.parseJob($0) }
                    if refresh { self.jobs = newJobs } else { self.jobs.append(contentsOf: newJobs) }
                    self.canLoadMore = self.currentPage < self.lastPage
                } else {
                    self.errorMessage = message ?? "Failed to load jobs"
                }
            }
        }
    }

    func loadMoreIfNeeded() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        isLoadingMore = true; currentPage += 1
        let params: [String: Any] = ["page": "\(currentPage)", "jobs": "", "job_category": "", "job_city": ""]
        LoginService.shared().makePostAPICall(with: jobsURL, params: params) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoadingMore = false
                if success, let json = json {
                    self.jobs.append(contentsOf: json["available_jobs"].arrayValue.map { self.parseJob($0) })
                    self.canLoadMore = self.currentPage < self.lastPage
                }
            }
        }
    }

    private func parseJob(_ json: JSON) -> JobModel {
        return JobModel(
            companyId: json["id"].stringValue,
            companyName: json["company_name"].stringValue,
            companyLogo: json["company_logo"].stringValue,
            companyCategory: json["category_name"].stringValue,
            cityName: json["city_name"].stringValue,
            jobUuid: json["job_uuid"].stringValue,
            jobTitle: json["job_title"].stringValue,
            jobDescription: json["job_description"].stringValue,
            jobType: json["job_type"].stringValue,
            salary: json["salary"].stringValue,
            deadline: json["deadline"].stringValue,
            jobLocation: json["job_location_name"].stringValue,
            jobCategory: json["job_category_title"].stringValue
        )
    }

    func selectJob(_ job: JobModel) {}
}
