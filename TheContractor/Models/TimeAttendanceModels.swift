//
//  TimeAttendanceModels.swift
//  TheContractor
//

import Foundation

struct Attendance: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let projectId: String
    let projectName: String
    let attendanceDate: String
    let checkInTime: String
    let checkOutTime: String?
    let totalHours: Double?
    let status: String
    let location: String?
    
    enum CodingKeys: String, CodingKey {
        case id, status, location
        case userId = "user_id"
        case userName = "user_name"
        case projectId = "project_id"
        case projectName = "project_name"
        case attendanceDate = "attendance_date"
        case checkInTime = "check_in_time"
        case checkOutTime = "check_out_time"
        case totalHours = "total_hours"
    }
}

struct Timesheet: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let weekStartDate: String
    let weekEndDate: String
    let totalHours: Double
    let regularHours: Double
    let overtimeHours: Double
    let status: String
    let approvedBy: String?
    let entries: [TimesheetEntry]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, entries
        case userId = "user_id"
        case userName = "user_name"
        case weekStartDate = "week_start_date"
        case weekEndDate = "week_end_date"
        case totalHours = "total_hours"
        case regularHours = "regular_hours"
        case overtimeHours = "overtime_hours"
        case approvedBy = "approved_by"
    }
}

struct TimesheetEntry: Codable, Identifiable {
    let id: String
    let workDate: String
    let projectId: String
    let projectName: String
    let hours: Double
    let taskDescription: String
    let isOvertime: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, hours
        case workDate = "work_date"
        case projectId = "project_id"
        case projectName = "project_name"
        case taskDescription = "task_description"
        case isOvertime = "is_overtime"
    }
}

struct LeaveRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let leaveType: String
    let startDate: String
    let endDate: String
    let totalDays: Int
    let reason: String
    let status: String
    let approvedBy: String?
    let approvalDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, reason, status
        case userId = "user_id"
        case userName = "user_name"
        case leaveType = "leave_type"
        case startDate = "start_date"
        case endDate = "end_date"
        case totalDays = "total_days"
        case approvedBy = "approved_by"
        case approvalDate = "approval_date"
    }
}

struct OvertimeRequest: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let requestDate: String
    let overtimeDate: String
    let hours: Double
    let reason: String
    let status: String
    let approvedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case id, hours, reason, status
        case userId = "user_id"
        case userName = "user_name"
        case requestDate = "request_date"
        case overtimeDate = "overtime_date"
        case approvedBy = "approved_by"
    }
}
