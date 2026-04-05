//  AdvertiseCompanyView.swift
import SwiftUI
import SwiftyJSON

// MARK: - Area Model
struct AdvertisementArea: Identifiable {
    let id: String
    let title: String
    let perDayRate: Int
}

// MARK: - AdvertiseCompanyView (matches Android AdvertiseCompany.java)
struct AdvertiseCompanyView: View {
    @StateObject private var vm = AdvertiseCompanyVM()
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)

    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Advertise Company")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 56)
            .background(yellow)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Section title with yellow underline
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Advertise Company")
                            .font(.system(size: 16, weight: .bold))
                        Rectangle().fill(yellow).frame(width: 60, height: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Company Serial Number field
                    VStack(spacing: 0) {
                        TextField("Enter 9 Digit Valid Company Serial No", text: $vm.serialNo)
                            .keyboardType(.numberPad)
                            .padding(14)
                            .onChange(of: vm.serialNo) { val in
                                let digits = val.filter { $0.isNumber }
                                if digits.count > 9 { vm.serialNo = String(digits.prefix(9)) }
                                else { vm.serialNo = digits }
                                if vm.serialNo.count == 9 { vm.lookupCompany() }
                                else { vm.companyId = ""; vm.companyName = "" }
                            }
                        Divider()
                    }
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    if !vm.companyName.isEmpty {
                        Text("✓ \(vm.companyName)")
                            .font(.system(size: 13))
                            .foregroundColor(.green)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                    if vm.isLookingUp {
                        HStack { Spacer(); ProgressView(); Spacer() }.padding(.bottom, 8)
                    }

                    // Area selector
                    Button(action: { vm.loadAreasIfNeeded() }) {
                        HStack {
                            Text(vm.selectedAreasText)
                                .foregroundColor(vm.selectedAreas.isEmpty ? Color(UIColor.placeholderText) : .primary)
                                .font(.system(size: 15))
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.gray)
                        }
                        .padding(14)
                    }
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Days picker
                    HStack {
                        Text(vm.selectedDay)
                            .font(.system(size: 15))
                        Spacer()
                        Menu {
                            ForEach(["1 Day", "2 Day", "3 Day"], id: \.self) { day in
                                Button(day) { vm.selectedDay = day; vm.calculateTotal() }
                            }
                        } label: {
                            Image(systemName: "chevron.down").foregroundColor(yellow)
                        }
                    }
                    .padding(14)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Total Amount row
                    HStack {
                        Text("Total Amount")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text("\(vm.totalAmount) AED")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Error
                    if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }

                    // Submit button
                    Button(action: { vm.submit() }) {
                        HStack {
                            Spacer()
                            if vm.isSubmitting {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Submit").font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .frame(height: 50)
                        .background(yellow)
                        .cornerRadius(6)
                    }
                    .disabled(vm.isSubmitting || !vm.canSubmit)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $vm.showAreaPicker) {
            AreaPickerSheet(areas: vm.allAreas, selected: $vm.selectedAreas, onDone: {
                vm.showAreaPicker = false
                vm.calculateTotal()
            })
        }
        .alert("Success", isPresented: $vm.showSuccess) {
            Button("OK") {}
        } message: {
            Text("Advertisement submitted successfully.")
        }
    }
}

// MARK: - Area Picker Sheet
private struct AreaPickerSheet: View {
    let areas: [AdvertisementArea]
    @Binding var selected: [AdvertisementArea]
    let onDone: () -> Void
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)

    var body: some View {
        NavigationView {
            List(areas) { area in
                let isSelected = selected.contains(where: { $0.id == area.id })
                Button(action: {
                    if isSelected { selected.removeAll { $0.id == area.id } }
                    else { selected.append(area) }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(area.title).foregroundColor(.primary).font(.system(size: 15))
                            Text("\(area.perDayRate) AED / day").font(.system(size: 12)).foregroundColor(.gray)
                        }
                        Spacer()
                        if isSelected { Image(systemName: "checkmark").foregroundColor(yellow) }
                    }
                }
            }
            .navigationTitle("Select Area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onDone)
                }
            }
        }
    }
}

// MARK: - ViewModel
class AdvertiseCompanyVM: ObservableObject {
    @Published var serialNo = ""
    @Published var companyId = ""
    @Published var companyName = ""
    @Published var isLookingUp = false
    @Published var allAreas: [AdvertisementArea] = []
    @Published var selectedAreas: [AdvertisementArea] = []
    @Published var selectedDay = "1 Day"
    @Published var totalAmount = 0
    @Published var isSubmitting = false
    @Published var errorMessage = ""
    @Published var showAreaPicker = false
    @Published var showSuccess = false

    private let base = "https://contractor.bidcont.com/rest/"

    var selectedAreasText: String {
        selectedAreas.isEmpty ? "Please Select Area" : selectedAreas.map { $0.title }.joined(separator: ", ")
    }

    var canSubmit: Bool { !companyId.isEmpty && !selectedAreas.isEmpty }

    // MARK: Lookup company by 9-digit serial
    func lookupCompany() {
        guard serialNo.count == 9 else { return }
        isLookingUp = true
        companyId = ""; companyName = ""
        LoginService.shared().makePostAPICall(with: "\(base)Home/company_by_serial_no", params: ["s_no": serialNo]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLookingUp = false
                if success, let j = json, j["error"].stringValue == "false" {
                    self.companyId = j["company"]["id"].stringValue
                    self.companyName = j["company"]["company_name"].stringValue
                    if self.allAreas.isEmpty { self.loadAreasIfNeeded() }
                }
            }
        }
    }

    // MARK: Load areas from API
    func loadAreasIfNeeded() {
        if !allAreas.isEmpty { showAreaPicker = true; return }
        LoginService.shared().makePostAPICall(with: "\(base)Home/get_all_advertisement_areas", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                if success, let j = json {
                    self.allAreas = j["areas"].arrayValue.map {
                        AdvertisementArea(id: $0["id"].stringValue, title: $0["title"].stringValue, perDayRate: $0["per_day_rate"].intValue)
                    }
                }
                self.showAreaPicker = true
            }
        }
    }

    // MARK: Calculate total = sum(per_day_rate) * days
    func calculateTotal() {
        let days = Int(selectedDay.filter { $0.isNumber }) ?? 1
        totalAmount = selectedAreas.reduce(0) { $0 + $1.perDayRate } * days
    }

    // MARK: Submit advertisement
    func submit() {
        guard canSubmit else { return }
        let days = String(Int(selectedDay.filter { $0.isNumber }) ?? 1)
        let areaIds = selectedAreas.map { "{\"id\":\"\($0.id)\"}" }.joined(separator: ",")
        let areaJson = "[\(areaIds)]"
        isSubmitting = true; errorMessage = ""
        LoginService.shared().makePostAPICall(with: "\(base)Home/advertise_company_mobile", params: ["company_id": companyId, "area_ids": areaJson, "days": days]) { [weak self] msg, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isSubmitting = false
                if success, let j = json, j["error"].stringValue == "false" {
                    self.showSuccess = true
                    self.serialNo = ""; self.companyId = ""; self.companyName = ""
                    self.selectedAreas = []; self.totalAmount = 0; self.selectedDay = "1 Day"
                } else {
                    self.errorMessage = json?["message"].stringValue ?? msg
                }
            }
        }
    }
}

// Legacy alias to avoid breaking AdvertiseCompanyHostingController
typealias AdvertiseCompanyViewModel = AdvertiseCompanyVM
