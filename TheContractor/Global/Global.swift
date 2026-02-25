import Foundation
import UIKit
import StoreKit

class Global {
    class var shared : Global {
        
        struct Static {
            static let instance : Global = Global()
        }
        return Static.instance
    }

    // MARK: - Session State
    /// Logged-in user (app user login)
    var user: UserViewModel!
    /// Logged-in company (vendor/company login)
    var companyVendor: CompanyVendor?
    /// True if either a user or a company is logged in
    var isLogedIn: Bool = false
    /// True if logged in as vendor/company
    var isVendor: Bool = false
    /// Last known login type ("user" or "company")
    var loginType: String = ""

    // MARK: - Device / Misc
    var fcmToken: String = ""
    var systemVersion = UIDevice.current.systemVersion
    var deviceModel = UIDevice.modelName
    var controllerTitle = ""
    var currentNavigationController = ""
    var currentStoryBoard = ""
}

