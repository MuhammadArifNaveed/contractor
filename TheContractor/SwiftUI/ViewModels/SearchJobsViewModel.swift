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
        print("Selected job: \(job.title)")
    }
}
