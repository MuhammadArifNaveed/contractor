//
//  FreelancerHiringModels.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import SwiftUI

// MARK: - Selected Date Entry
/// Represents a single date selection with calculated hours and total
struct SelectedDateEntry: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let hours: Double
    let rate: Double
    
    var total: Double {
        return hours * rate
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var apiDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Freelancer Selection
/// Represents a freelancer added to the hiring cart with all details
class FreelancerSelection: Identifiable, ObservableObject {
    let id: String
    let freelancerId: String
    let uuid: String
    let name: String
    let profession: String
    let hourlyRate: Double
    let profileImage: String
    let location: String
    let area: String
    let city: String
    let cityId: String
    let commission: String
    let fromTime: String
    let toTime: String
    let isHourly: String
    
    @Published var selectedDates: [SelectedDateEntry] = []
    @Published var transportationCost: Double = 0
    @Published var transportationDiscount: Double = 0
    @Published var isTransportCalculated: Bool = false
    
    var workingHours: String {
        return "\(formatTime(fromTime)) to \(formatTime(toTime))"
    }
    
    var hoursPerDay: Double {
        return calculateHoursBetween(from: fromTime, to: toTime)
    }
    
    var totalAmount: Double {
        return selectedDates.reduce(0) { $0 + $1.total }
    }
    
    var transportCharges: Double {
        return max(0, transportationCost - transportationDiscount)
    }
    
    var payableAmount: Double {
        return totalAmount + transportCharges
    }
    
    init(freelancer: FreelancerViewModel) {
        self.id = UUID().uuidString
        self.freelancerId = freelancer.id
        self.uuid = freelancer.uuid
        self.name = freelancer.name
        self.profession = freelancer.profession
        self.hourlyRate = Double(freelancer.hourlyRate) ?? 0
        self.profileImage = freelancer.profileImage
        self.location = freelancer.location
        self.area = freelancer.area
        self.city = freelancer.city
        self.cityId = freelancer.cityId
        self.commission = freelancer.commission
        self.fromTime = freelancer.fromTime
        self.toTime = freelancer.toTime
        self.isHourly = freelancer.isHourly
    }
    
    func addDate(_ date: Date) {
        // Prevent duplicate dates
        let dateString = SelectedDateEntry(date: date, hours: hoursPerDay, rate: hourlyRate).apiDateString
        if !selectedDates.contains(where: { $0.apiDateString == dateString }) {
            let entry = SelectedDateEntry(date: date, hours: hoursPerDay, rate: hourlyRate)
            selectedDates.append(entry)
            selectedDates.sort { $0.date < $1.date }
        }
    }
    
    func removeDate(_ date: Date) {
        let dateString = SelectedDateEntry(date: date, hours: hoursPerDay, rate: hourlyRate).apiDateString
        selectedDates.removeAll { $0.apiDateString == dateString }
    }
    
    func clearDates() {
        selectedDates.removeAll()
    }
    
    /// Converts selection to JSON format for API
    func toAPIJSON() -> [String: Any] {
        let datesArray: [[String: String]] = selectedDates.map { ["date": $0.apiDateString] }
        
        let detail: [String: Any] = [
            "dates": datesArray,
            "fromTime": fromTime,
            "toTime": toTime,
            "isHourly": isHourly,
            "isPicked": "0"
        ]
        
        return [
            "id": freelancerId,
            "uuid": uuid,
            "name": name,
            "category": profession,
            "hourlyRate": String(hourlyRate),
            "image": profileImage,
            "area": area,
            "city": city,
            "cityId": cityId,
            "commission": commission,
            "transportation_charges": String(transportCharges),
            "detail": detail
        ]
    }
    
    private func formatTime(_ time: String) -> String {
        guard !time.isEmpty else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        // Try without seconds
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        return time
    }
    
    private func calculateHoursBetween(from: String, to: String) -> Double {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        
        guard let fromDate = formatter.date(from: from) ?? parseTimeWithoutSeconds(from),
              let toDate = formatter.date(from: to) ?? parseTimeWithoutSeconds(to) else {
            return 8.0 // Default 8 hours
        }
        
        var diff = toDate.timeIntervalSince(fromDate)
        if diff < 0 {
            // Handle overnight shifts (e.g., 10pm to 6am)
            diff += 24 * 60 * 60
        }
        
        return diff / 3600.0
    }
    
    private func parseTimeWithoutSeconds(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
}

// MARK: - Freelancer Cart Manager
/// Singleton manager for the freelancer hiring cart
class FreelancerCartManager: ObservableObject {
    static let shared = FreelancerCartManager()
    
    @Published var selectedFreelancers: [FreelancerSelection] = []
    @Published var isLoading: Bool = false
    
    private init() {}
    
    var totalFreelancers: Int {
        return selectedFreelancers.count
    }
    
    var freelancersCharges: Double {
        return selectedFreelancers.reduce(0) { $0 + $1.totalAmount }
    }
    
    var transportationCharges: Double {
        return selectedFreelancers.reduce(0) { $0 + $1.transportCharges }
    }
    
    var totalCharges: Double {
        return freelancersCharges + transportationCharges
    }
    
    func isFreelancerSelected(_ freelancerId: String) -> Bool {
        return selectedFreelancers.contains { $0.freelancerId == freelancerId }
    }
    
    func addFreelancer(_ selection: FreelancerSelection) {
        objectWillChange.send()
        // Remove existing selection for the same freelancer if any
        selectedFreelancers.removeAll { $0.freelancerId == selection.freelancerId }
        selectedFreelancers.append(selection)
    }
    
    func removeFreelancer(_ freelancerId: String) {
        objectWillChange.send()
        selectedFreelancers.removeAll { $0.freelancerId == freelancerId }
    }
    
    func getSelection(for freelancerId: String) -> FreelancerSelection? {
        return selectedFreelancers.first { $0.freelancerId == freelancerId }
    }
    
    func clearCart() {
        selectedFreelancers.removeAll()
    }
    
    /// Generates the JSON array string for the hire API
    func generateAPIPayload() -> String {
        let array = selectedFreelancers.map { $0.toAPIJSON() }
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: []),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
}
