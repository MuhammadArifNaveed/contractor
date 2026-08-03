//
//  CompanyDetailViewModel.swift
//  TheContractor
//
//  ViewModel for Company Details screen - matches Android CompanyDetails activity
//

import SwiftUI
import Combine
import SwiftyJSON

struct OpeningHourItem: Identifiable {
    let id = UUID()
    let day: String
    let openTime: String
    let closeTime: String
}

struct CompanySubCategoryItem: Identifiable {
    let id: String
    let name: String
}

struct CompanyReviewItem: Identifiable {
    let id: String
    let userName: String
    let rating: String
    let comment: String
    let date: String
}

class CompanyDetailViewModel: ObservableObject {
    @Published var company: CompanyViewModel
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var companyPhone = ""
    @Published var companyWhatsapp = ""
    @Published var companyEmail = ""
    @Published var companyAddress = ""
    @Published var cityName = ""
    @Published var areaName = ""
    @Published var companySince = ""
    @Published var companyEmployees = ""
    @Published var isVerified = false
    @Published var is24Hours = false
    @Published var isTrusted = false
    @Published var isVip = false

    @Published var openingHours: [OpeningHourItem] = []
    @Published var subCategories: [CompanySubCategoryItem] = []
    @Published var reviews: [CompanyReviewItem] = []

    init(company: CompanyViewModel) {
        self.company = company
    }

    func loadDetails() {
        guard !company.id.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let url = "https://contractor.bidcont.com/rest/Home/company_detail"
        let params: [String: String] = ["company_id": company.id]

        LoginService.shared().makePostAPICall(with: url, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let self = self else { return }
                if success, let json = json {
                    let c = json["company"]
                    self.companyPhone      = c["company_phone"].stringValue
                    self.companyWhatsapp   = c["company_whatsapp"].stringValue
                    self.companyEmail      = c["company_email"].stringValue
                    self.companyAddress    = c["company_address"].stringValue
                    self.cityName          = c["city_name"].stringValue
                    self.areaName          = c["area_name"].stringValue
                    self.companySince      = c["company_since"].stringValue
                    self.companyEmployees  = c["company_employees"].stringValue
                    self.isVerified        = c["is_verified"].stringValue == "1"
                    self.is24Hours         = c["company_for_24_hours"].stringValue == "1"
                    self.isTrusted         = c["is_trusted"].stringValue == "1"
                    self.isVip             = c["is_vip"].stringValue == "1"

                    self.company.company_discription = c["company_discription"].stringValue
                    let rating = c["avg_rating"].stringValue
                    if !rating.isEmpty { self.company.total_rating = rating }
                    self.company.review_count = c["review_count"].stringValue

                    let logoFile = c["company_logo"].stringValue
                    if !logoFile.isEmpty {
                        self.company.company_logo = "https://contractor.bidcont.com/uploads/companies/" + logoFile
                    }

                    self.openingHours = c["timing"].arrayValue.map {
                        OpeningHourItem(day: $0["name"].stringValue,
                                        openTime: $0["open_time"].stringValue,
                                        closeTime: $0["close_time"].stringValue)
                    }

                    self.subCategories = c["categories"].arrayValue.map {
                        CompanySubCategoryItem(id: $0["id"].stringValue,
                                               name: $0["sub_category_title"].stringValue)
                    }

                    self.reviews = c["reviews"].arrayValue.map {
                        CompanyReviewItem(id: $0["id"].stringValue,
                                          userName: $0["user_name"].stringValue,
                                          rating: $0["rating"].stringValue,
                                          comment: $0["comment"].stringValue,
                                          date: $0["date"].stringValue)
                    }
                }
            }
        }
    }

    func callCompany() {
        let phone = companyPhone.isEmpty ? companyWhatsapp : companyPhone
        guard !phone.isEmpty, let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") else { return }
        UIApplication.shared.open(url)
    }

    func emailCompany() {
        let email = companyEmail.isEmpty ? company.login_email : companyEmail
        guard !email.isEmpty, let url = URL(string: "mailto:\(email)") else { return }
        UIApplication.shared.open(url)
    }

    func submitComplaint(text: String, userId: String) {
        let url = "https://contractor.bidcont.com/rest/Home/submit_complaint"
        // Android's part is `complaint`; `text` was never read.
        let params: [String: String] = ["company_id": company.id, "user_id": userId, "complaint": text]
        LoginService.shared().makePostAPICall(with: url, params: params) { _, _, _, _ in }
    }
}
