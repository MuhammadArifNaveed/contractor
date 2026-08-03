//
//  SearchJobsViewModel.swift
//  TheContractor
//
//  ViewModel for Job Search
//

import SwiftUI
import Combine
import SwiftyJSON

class SearchJobsViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var selectedFilter = ""
    @Published var searchResults: [JobModel] = []
    @Published var isSearching = false
    
    private var searchTask: DispatchWorkItem?
    
    func performSearch() {
        searchTask?.cancel()
        
        guard !searchQuery.isEmpty else {
            searchResults.removeAll()
            return
        }
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSearching = true
            }
            
            // Android: jobs/search_jobs. The search term's part is named `jobs`; category and city
            // are optional filters this screen does not collect yet.
            let params = [
                "page": "1",
                "jobs": self.searchQuery,
                "job_category": "",
                "job_city": ""
            ]
            let completeURL = "https://contractor.bidcont.com/rest/jobs/search_jobs"
            
            LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
                DispatchQueue.main.async {
                    self?.isSearching = false
                    
                    if success, let json = json {
                        // Live response key is `available_jobs`.
                        if let jobsArray = json["available_jobs"].array {
                            self?.searchResults = jobsArray.map { self?.parseJob($0) ?? JobModel() }
                        }
                    }
                }
            }
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
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
