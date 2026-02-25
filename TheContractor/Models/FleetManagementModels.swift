//
//  FleetManagementModels.swift
//  TheContractor
//

import Foundation

struct Vehicle: Codable, Identifiable {
    let id: String
    let companyId: String
    let vehicleType: String
    let make: String
    let model: String
    let year: String
    let registrationNumber: String
    let status: String
    let currentLocation: String?
    let mileage: String
    let lastServiceDate: String?
    let nextServiceDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, make, model, year, status, mileage
        case companyId = "company_id"
        case vehicleType = "vehicle_type"
        case registrationNumber = "registration_number"
        case currentLocation = "current_location"
        case lastServiceDate = "last_service_date"
        case nextServiceDate = "next_service_date"
    }
}

struct VehicleAssignment: Codable, Identifiable {
    let id: String
    let vehicleId: String
    let vehicleNumber: String
    let driverId: String
    let driverName: String
    let projectId: String?
    let assignedDate: String
    let returnDate: String?
    let purpose: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, purpose, status
        case vehicleId = "vehicle_id"
        case vehicleNumber = "vehicle_number"
        case driverId = "driver_id"
        case driverName = "driver_name"
        case projectId = "project_id"
        case assignedDate = "assigned_date"
        case returnDate = "return_date"
    }
}

struct VehicleMaintenance: Codable, Identifiable {
    let id: String
    let vehicleId: String
    let maintenanceType: String
    let description: String
    let cost: String
    let servicedBy: String
    let serviceDate: String
    let nextServiceDue: String?
    let odometer: String
    
    enum CodingKeys: String, CodingKey {
        case id, description, cost, odometer
        case vehicleId = "vehicle_id"
        case maintenanceType = "maintenance_type"
        case servicedBy = "serviced_by"
        case serviceDate = "service_date"
        case nextServiceDue = "next_service_due"
    }
}

struct FuelLog: Codable, Identifiable {
    let id: String
    let vehicleId: String
    let driverId: String
    let fuelType: String
    let quantity: String
    let cost: String
    let odometer: String
    let location: String
    let filledAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, quantity, cost, odometer, location
        case vehicleId = "vehicle_id"
        case driverId = "driver_id"
        case fuelType = "fuel_type"
        case filledAt = "filled_at"
    }
}
