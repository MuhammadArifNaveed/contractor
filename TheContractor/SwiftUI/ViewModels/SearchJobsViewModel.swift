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
            
            let params = ["search_query": self.searchQuery]
            let completeURL = "https://contractor.bidcont.com/rest/Home/search_jobs"
            
            LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
                DispatchQueue.main.async {
                    self?.isSearching = false
                    
                    if success, let json = json {
                        if let jobsArray = json["jobs"].array {
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
