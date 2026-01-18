//
//  FreelancerViewModel.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import SwiftyJSON

class FreelancerViewModel: ObservableObject {
    var id: String = ""
    var name: String = ""
    var profession: String = ""
    var hourlyRate: String = ""
    var profileImage: String = ""
    var rating: Double = 0.0
    var reviewCount: Int = 0
    var location: String = ""
    var city: String = ""
    var availability: String = ""
    var workingHours: String = ""
    var memberSince: String = ""
    var skills: [String] = []
    
    init() {}
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.profession = json["profession"].stringValue
        self.hourlyRate = json["hourly_rate"].stringValue
        self.profileImage = json["profile_image"].stringValue
        self.rating = json["rating"].doubleValue
        self.reviewCount = json["review_count"].intValue
        self.location = json["location"].stringValue
        self.city = json["city"].stringValue
        self.availability = json["availability"].stringValue
        self.workingHours = json["working_hours"].stringValue
        self.memberSince = json["member_since"].stringValue
        
        if let skillsArray = json["skills"].array {
            self.skills = skillsArray.map { $0.stringValue }
        }
    }
    
    var formattedRate: String {
        return "\(hourlyRate)/hr"
    }
    
    var isAvailableHourly: Bool {
        return availability.lowercased().contains("hourly")
    }
}

class FreelancerListViewModel: ObservableObject {
    @Published var freelancers: [FreelancerViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    init() {}
    
    init(json: JSON) {
        if let freelancersArray = json["freelancers"].array {
            self.freelancers = freelancersArray.map { FreelancerViewModel(json: $0) }
        }
    }
    
    /// Loads freelancers for the "Freelancers" screen (side menu).
    /// - For company login, this uses freelancing/freelancers_list.
    /// - For user login (for now), it falls back to mock data.
    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        if Global.shared.loginType == "company" {
            FreelancingService.shared.fetchCompanyFreelancersList { [weak self] message, success, json in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.isLoading = false
                    if success, let json {
                        let list = json["company_freelancers_list"].arrayValue
                        self.freelancers = list.map { freelancer in
                            let vm = FreelancerViewModel()
                            vm.id = freelancer["id"].stringValue
                            vm.name = freelancer["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                            vm.profession = freelancer["category_name"].stringValue
                            vm.hourlyRate = freelancer["hourly_rate"].stringValue
                            // Image path from API is a filename; keep empty or prepend base URL if needed later.
                            vm.profileImage = ""

                            let ratingJSON = freelancer["rating"]
                            vm.rating = ratingJSON["avg_rating"].doubleValue
                            vm.reviewCount = ratingJSON["total_orders"].intValue

                            let cityName = freelancer["city_name"].stringValue
                            let areaName = freelancer["area_name"].stringValue
                            vm.location = [areaName, cityName].filter { !$0.isEmpty }.joined(separator: " , ")

                            let fromTime = freelancer["from_time"].stringValue
                            let toTime = freelancer["to_time"].stringValue
                            vm.workingHours = formatTimeRange(from: fromTime, to: toTime)

                            let createdAt = freelancer["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                            vm.memberSince = formatMemberSince(createdAt)

                            vm.skills = freelancer["skills"].arrayValue.map { $0["skill_title"].stringValue }

                            let availabilityFlag = freelancer["is_available_as_freelancer"].stringValue
                            let availability = freelancer["availability"].stringValue
                            let isAvailable = availabilityFlag == "1" || availability == "1"
                            vm.availability = isAvailable ? "Available Hourly" : ""

                            return vm
                        }
                    } else {
                        self.errorMessage = message
                        self.freelancers = []
                    }
                }
            }
        } else {
            // TODO: replace with real user-facing freelancers API when available.
            let mock = FreelancerListViewModel.mockData()
            self.freelancers = mock.freelancers
            self.isLoading = false
        }
    }
    
    // Mock data for testing
    static func mockData() -> FreelancerListViewModel {
        let viewModel = FreelancerListViewModel()
        viewModel.freelancers = [
            mockFreelancer(name: "Honorato Galloway", profession: "carpentor", rate: "16.50", 
                          skills: ["wood carpenter"], location: "Al Shahama , Abu Dhabi", 
                          hours: "5:55 AM to 12:49 PM", memberSince: "08 Nov 2025", rating: 3.5, reviews: 39),
            mockFreelancer(name: "Fay Barker", profession: "designer", rate: "22.00", 
                          skills: ["wood carpenter", "general carpenter"], location: "Sakamkam , Fujairah", 
                          hours: "9:00 AM to 5:00 PM", memberSince: "17 Nov 2025", rating: 3.5, reviews: 39),
            mockFreelancer(name: "Ahmad", profession: "designer", rate: "11.00", 
                          skills: ["general carpenter"], location: "Al Sharisha , Ras Al Khaimah", 
                          hours: "9:00 AM to 5:00 PM", memberSince: "19 Nov 2025", rating: 3.5, reviews: 39)
        ]
        return viewModel
    }
    
    private static func mockFreelancer(name: String, profession: String, rate: String, 
                                      skills: [String], location: String, hours: String, 
                                      memberSince: String, rating: Double, reviews: Int) -> FreelancerViewModel {
        let freelancer = FreelancerViewModel()
        freelancer.name = name
        freelancer.profession = profession
        freelancer.hourlyRate = rate
        freelancer.skills = skills
        freelancer.location = location
        freelancer.workingHours = hours
        freelancer.memberSince = memberSince
        freelancer.rating = rating
        freelancer.reviewCount = reviews
        freelancer.availability = "Available Hourly"
        return freelancer
    }
}

// Search filter model
class FreelancerSearchFilter: ObservableObject {
    @Published var skills: String = ""
    @Published var rate: String = ""
    @Published var selectedCategory: String = ""
    @Published var selectedCity: String = ""
    
    var isValid: Bool {
        return !skills.isEmpty || !rate.isEmpty || !selectedCategory.isEmpty || !selectedCity.isEmpty
    }
    
    func reset() {
        skills = ""
        rate = ""
        selectedCategory = ""
        selectedCity = ""
    }
}

// MARK: - Local Formatting Helpers (shared with company freelancers UI)

private func formatTimeRange(from: String, to: String) -> String {
    let fromFormatted = formatTime(from)
    let toFormatted = formatTime(to)
    if fromFormatted.isEmpty || toFormatted.isEmpty {
        return ""
    }
    return "\(fromFormatted) to \(toFormatted)"
}

private func formatTime(_ value: String) -> String {
    guard !value.isEmpty else { return "" }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm:ss"
    if let date = formatter.date(from: value) {
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    return value
}

private func formatMemberSince(_ raw: String) -> String {
    guard !raw.isEmpty else { return "" }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    if let date = formatter.date(from: raw) {
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    return raw
}
