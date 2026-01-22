//
//  UserDefaultsManager.swift
//  OrderAte
//
//  Created by Gulfam Khan on 12/09/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import Foundation

fileprivate struct UserDefaultsKeys {
    static let isUserLoggedIn = "isUserLoggedIn"
    static let loggedInUserInfo = "loggedInUserInfo"
    /// True when a company (vendor) is logged in
    static let isCompanyLoggedIn = "isCompanyLoggedIn"
    /// Stored company/vendor info (encoded CompanyVendor)
    static let loggedInCompanyInfo = "loggedInCompanyInfo"
    /// "user" or "company" – last successful login type
    static let loginType = "loginType"
    static let configurationUrl = "configurationUrl"
    static let verificationID = "authVerificationID"
    static let token = "token"
}

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let manager = UserDefaults.standard
    
    private init() {}
    
    var currentLocale:String {
        set {
            manager.set(newValue, forKey:"locale")
            manager.synchronize()
        }
        get {
            return manager.string(forKey: "locale") ?? "ar"
        }
    }
    
    var isUserLoggedIn:Bool {
        set {
            manager.set(newValue, forKey:UserDefaultsKeys.isUserLoggedIn)
            manager.synchronize()
        }
        get {
            return manager.bool(forKey: UserDefaultsKeys.isUserLoggedIn)
        }
    }

    /// Company (vendor) login flag
    var isCompanyLoggedIn: Bool {
        set {
            manager.set(newValue, forKey: UserDefaultsKeys.isCompanyLoggedIn)
            manager.synchronize()
        }
        get {
            return manager.bool(forKey: UserDefaultsKeys.isCompanyLoggedIn)
        }
    }

    /// "user" or "company" – last successful login type
    var loginType: String {
        set {
            manager.set(newValue, forKey: UserDefaultsKeys.loginType)
            manager.synchronize()
        }
        get {
            return manager.string(forKey: UserDefaultsKeys.loginType) ?? ""
        }
    }

    
    
    var configurationUrl: String? {
        set{
            manager.set(newValue, forKey:UserDefaultsKeys.configurationUrl)
            manager.synchronize()
        }get{
            return manager.value(forKey: UserDefaultsKeys.configurationUrl) as? String
        }
    }
    
    var token: String? {
           set{
               manager.set(newValue, forKey:UserDefaultsKeys.token)
               manager.synchronize()
           }get{
               return manager.value(forKey: UserDefaultsKeys.token) as? String
           }
       }
    
    
    var userInfo: UserViewModel? {
        set {
            manager.set(codable: newValue, forKey: UserDefaultsKeys.loggedInUserInfo)
            manager.synchronize()
        }
        get {
            return manager.codable(UserViewModel.self, forKey: UserDefaultsKeys.loggedInUserInfo)
        }
    }

    /// Stored company/vendor info using Codable support
    var companyInfo: CompanyVendor? {
        set {
            manager.set(codable: newValue, forKey: UserDefaultsKeys.loggedInCompanyInfo)
            manager.synchronize()
        }
        get {
            return manager.codable(CompanyVendor.self, forKey: UserDefaultsKeys.loggedInCompanyInfo)
        }
    }
 
   
    func clearUserData() {
        manager.removeObject(forKey: UserDefaultsKeys.loggedInUserInfo)
        manager.set(false, forKey: UserDefaultsKeys.isUserLoggedIn)
        manager.synchronize()
    }

    /// Clears both user and company login state (used on full logout)
    func clearAllLoginData() {
        manager.removeObject(forKey: UserDefaultsKeys.loggedInUserInfo)
        manager.removeObject(forKey: UserDefaultsKeys.loggedInCompanyInfo)
        manager.set(false, forKey: UserDefaultsKeys.isUserLoggedIn)
        manager.set(false, forKey: UserDefaultsKeys.isCompanyLoggedIn)
        manager.set("", forKey: UserDefaultsKeys.loginType)
        manager.synchronize()
    }
    var verificationID: String? {
          set{
              manager.set(newValue, forKey:UserDefaultsKeys.verificationID)
              manager.synchronize()
          }get{
              return manager.value(forKey: UserDefaultsKeys.verificationID) as? String
          }
      }
    func clearVerificationID() {
        manager.removeObject(forKey: UserDefaultsKeys.verificationID)
        manager.synchronize()
    }
    
    func clearToken(){
        manager.removeObject(forKey: UserDefaultsKeys.token)
        manager.synchronize()
    }
    
}
