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
    
    func loadJobs(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            jobs.removeAll()
            canLoadMore = true
        }
        
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let params = ["page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_available_jobs"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success, let json = json {
                    self?.lastPage = json["last_page"].intValue
                    
                    if let jobsArray = json["jobs"].array {
                        let newJobs = jobsArray.map { self?.parseJob($0) ?? JobModel() }
                        
                        if refresh {
                            self?.jobs = newJobs
                        } else {
                            self?.jobs.append(contentsOf: newJobs)
                        }
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                } else {
                    self?.errorMessage = message ?? "Failed to load jobs"
                }
            }
        }
    }
    
    func loadMoreIfNeeded() {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        let params = ["page_no": "\(currentPage)"]
        let completeURL = "https://contractor.bidcont.com/rest/Home/get_available_jobs"
        
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if success, let json = json {
                    if let jobsArray = json["jobs"].array {
                        let newJobs = jobsArray.map { self?.parseJob($0) ?? JobModel() }
                        self?.jobs.append(contentsOf: newJobs)
                    }
                    
                    if let currentPage = self?.currentPage, let lastPage = self?.lastPage {
                        self?.canLoadMore = currentPage < lastPage
                    }
                }
            }
        }
    }
    
    private func parseJob(_ json: JSON) -> JobModel {
        return JobModel(
            id: json["id"].stringValue,
            title: json["title"].stringValue,
            companyName: json["company_name"].stringValue,
            location: json["location"].stringValue,
            jobType: json["job_type"].stringValue,
            salary: json["salary"].stringValue,
            description: json["description"].stringValue,
            requirements: json["requirements"].stringValue,
            postedDate: json["posted_date"].stringValue,
            category: json["category"].stringValue
        )
    }
    
    func selectJob(_ job: JobModel) {
        // Navigate to job details
        print("Selected job: \(job.title)")
    }
}
