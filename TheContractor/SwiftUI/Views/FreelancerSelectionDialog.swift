//
//  FreelancerSelectionDialog.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct FreelancerSelectionDialog: View {
    let freelancer: FreelancerViewModel
    let onAddToList: (FreelancerSelection) -> Void
    let onDismiss: () -> Void
    
    @State private var selectedDates: Set<Date> = []
    @State private var showDatePicker: Bool = false
    @StateObject private var selection: FreelancerSelection
    
    init(freelancer: FreelancerViewModel, onAddToList: @escaping (FreelancerSelection) -> Void, onDismiss: @escaping () -> Void) {
        self.freelancer = freelancer
        self.onAddToList = onAddToList
        self.onDismiss = onDismiss
        _selection = StateObject(wrappedValue: FreelancerSelection(freelancer: freelancer))
    }
    
    private var formattedSelectedDates: String {
        if selection.selectedDates.isEmpty {
            return "Select Date / Dates"
        }
        return selection.selectedDates.map { $0.apiDateString }.joined(separator: ", ")
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Dialog content
            VStack(spacing: 0) {
                // Title
                Text("Freelancer Information")
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Selected Time
                    Text("Selected Time : \(selection.workingHours)")
                        .font(AppTheme.Fonts.semibold(14))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    // Per Hour Rate
                    Text("Per Hour Rate : \(String(format: "%.2f", selection.hourlyRate))")
                        .font(AppTheme.Fonts.semibold(14))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                // Date selection field
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Text(formattedSelectedDates)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(selection.selectedDates.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Calculation table (shown when dates are selected)
                if !selection.selectedDates.isEmpty {
                    VStack(spacing: 0) {
                        // Divider
                        Rectangle()
                            .fill(AppTheme.Colors.primary)
                            .frame(height: 2)
                            .padding(.top, 16)
                        
                        // Table header
                        HStack(spacing: 0) {
                            Text("Date")
                                .font(AppTheme.Fonts.medium(13))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Hours")
                                .font(AppTheme.Fonts.medium(13))
                                .frame(width: 60, alignment: .center)
                            Text("Rate")
                                .font(AppTheme.Fonts.medium(13))
                                .frame(width: 50, alignment: .center)
                            Text("Total")
                                .font(AppTheme.Fonts.medium(13))
                                .frame(width: 70, alignment: .trailing)
                        }
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        // Table rows
                        ForEach(selection.selectedDates) { entry in
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.formattedDate)
                                        .font(AppTheme.Fonts.regular(13))
                                    Text(entry.dayOfWeek)
                                        .font(AppTheme.Fonts.regular(11))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(String(format: "%.2f", entry.hours))
                                    .font(AppTheme.Fonts.regular(13))
                                    .frame(width: 60, alignment: .center)
                                
                                Text(String(format: "%.2f", entry.rate))
                                    .font(AppTheme.Fonts.regular(13))
                                    .frame(width: 50, alignment: .center)
                                
                                Text(String(format: "%.2f", entry.total))
                                    .font(AppTheme.Fonts.semibold(13))
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                        
                        // Grand Total
                        HStack {
                            Text("Grand Total")
                                .font(AppTheme.Fonts.semibold(14))
                            Spacer()
                            Text(String(format: "%.2f", selection.totalAmount))
                                .font(AppTheme.Fonts.semibold(16))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
                
                // Add to List button
                Button(action: {
                    guard !selection.selectedDates.isEmpty else { return }
                    onAddToList(selection)
                    onDismiss()
                }) {
                    Text("Add to List")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(selection.selectedDates.isEmpty ? AppTheme.Colors.textSecondary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selection.selectedDates.isEmpty ? AppTheme.Colors.gray.opacity(0.3) : AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
                .disabled(selection.selectedDates.isEmpty)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showDatePicker) {
            MultiDatePickerSheet(
                selectedDates: Binding(
                    get: { Set(selection.selectedDates.map { $0.date }) },
                    set: { newDates in
                        // Remove dates that are no longer selected
                        let currentDates = Set(selection.selectedDates.map { Calendar.current.startOfDay(for: $0.date) })
                        let newNormalizedDates = Set(newDates.map { Calendar.current.startOfDay(for: $0) })
                        
                        // Remove deselected dates
                        for date in currentDates {
                            if !newNormalizedDates.contains(date) {
                                selection.removeDate(date)
                            }
                        }
                        
                        // Add newly selected dates
                        for date in newNormalizedDates {
                            if !currentDates.contains(date) {
                                selection.addDate(date)
                            }
                        }
                    }
                ),
                onDone: {
                    showDatePicker = false
                }
            )
        }
    }
}

// MARK: - Multi Date Picker Sheet
struct MultiDatePickerSheet: View {
    @Binding var selectedDates: Set<Date>
    let onDone: () -> Void
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Button(action: { previousMonth() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentMonth))
                        .font(AppTheme.Fonts.semibold(18))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { nextMonth() }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Weekday headers
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(AppTheme.Fonts.medium(12))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                
                // Calendar days
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            let isSelected = isDateSelected(date)
                            let isPast = isPastDate(date)
                            
                            Button(action: {
                                if !isPast {
                                    toggleDate(date)
                                }
                            }) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(AppTheme.Fonts.medium(14))
                                    .foregroundColor(isPast ? AppTheme.Colors.textSecondary.opacity(0.5) : (isSelected ? .white : AppTheme.Colors.textPrimary))
                                    .frame(width: 40, height: 40)
                                    .background(isSelected ? AppTheme.Colors.primary : Color.clear)
                                    .cornerRadius(20)
                            }
                            .disabled(isPast)
                        } else {
                            Text("")
                                .frame(width: 40, height: 40)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Selected dates summary
                if !selectedDates.isEmpty {
                    Text("Selected: \(selectedDates.count) date(s)")
                        .font(AppTheme.Fonts.medium(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .padding(.bottom, 8)
                }
                
                // Done button
                Button(action: onDone) {
                    Text("Done")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(AppTheme.CornerRadius.small)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Dates")
                        .font(AppTheme.Fonts.semibold(17))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        selectedDates.removeAll()
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        // Add empty slots for days before the first of the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in the month
        var currentDate = startOfMonth
        while currentDate < endOfMonth {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return selectedDates.contains { calendar.startOfDay(for: $0) == normalizedDate }
    }
    
    private func isPastDate(_ date: Date) -> Bool {
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())
    }
    
    private func toggleDate(_ date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        if isDateSelected(date) {
            selectedDates = selectedDates.filter { calendar.startOfDay(for: $0) != normalizedDate }
        } else {
            selectedDates.insert(normalizedDate)
        }
    }
}

#Preview {
    FreelancerSelectionDialog(
        freelancer: FreelancerListViewModel.mockData().freelancers.first!,
        onAddToList: { _ in },
        onDismiss: {}
    )
}
