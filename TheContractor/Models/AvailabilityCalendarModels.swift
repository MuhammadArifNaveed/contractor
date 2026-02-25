//
//  AvailabilityCalendarModels.swift
//  TheContractor
//

import Foundation

struct CompanyAvailability: Codable, Identifiable {
    let id: String
    let companyId: String
    let date: String
    let availabilityType: String
    let startTime: String?
    let endTime: String?
    let maxBookings: Int?
    let currentBookings: Int
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, notes
        case companyId = "company_id"
        case availabilityType = "availability_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case maxBookings = "max_bookings"
        case currentBookings = "current_bookings"
    }
}

struct BookingSlot: Codable, Identifiable {
    let id: String
    let companyId: String
    let date: String
    let timeSlot: String
    let duration: String
    let isAvailable: Bool
    let price: String?
    let serviceType: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, duration, price
        case companyId = "company_id"
        case timeSlot = "time_slot"
        case isAvailable = "is_available"
        case serviceType = "service_type"
    }
}

struct Appointment: Codable, Identifiable {
    let id: String
    let userId: String
    let companyId: String
    let slotId: String
    let appointmentDate: String
    let appointmentTime: String
    let serviceType: String
    let status: String
    let notes: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, status, notes
        case userId = "user_id"
        case companyId = "company_id"
        case slotId = "slot_id"
        case appointmentDate = "appointment_date"
        case appointmentTime = "appointment_time"
        case serviceType = "service_type"
        case createdAt = "created_at"
    }
}
