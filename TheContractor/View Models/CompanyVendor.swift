//
//  CompanyVendor.swift
//  TheContractor
//
//  Created by Warp AI
//

import Foundation
import SwiftyJSON

/// Represents a logged-in company/vendor returned from `vendor/login_company`.
struct CompanyVendor: Codable {
    let id: String
    let userId: String
    let userType: String
    let companyName: String
    let loginEmail: String
    let companyPhone: String
    let companyEmail: String
    let companyLogo: String

    init(id: String,
         userId: String,
         userType: String,
         companyName: String,
         loginEmail: String,
         companyPhone: String,
         companyEmail: String,
         companyLogo: String) {
        self.id = id
        self.userId = userId
        self.userType = userType
        self.companyName = companyName
        self.loginEmail = loginEmail
        self.companyPhone = companyPhone
        self.companyEmail = companyEmail
        self.companyLogo = companyLogo
    }

    init(json: JSON) {
        self.id = json["id"].stringValue
        self.userId = json["user_id"].stringValue
        self.userType = json["user_type"].stringValue
        self.companyName = json["company_name"].stringValue
        self.loginEmail = json["login_email"].stringValue
        self.companyPhone = json["company_phone"].stringValue
        self.companyEmail = json["company_email"].stringValue
        self.companyLogo = json["company_logo"].stringValue
    }
}
