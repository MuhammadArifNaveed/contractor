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
    
    
    var userInfo:UserViewModel! {
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue!)
            manager.set(data, forKey: UserDefaultsKeys.loggedInUserInfo)
            manager.synchronize()
        }
        get {
            if let data = manager.data(forKey: UserDefaultsKeys.loggedInUserInfo) {
                let userInfo = NSKeyedUnarchiver.unarchiveObject(with: data) as! UserViewModel
                return userInfo
            }else {
                return nil
            }
            
        }
    }
 
   
    func clearUserData() {
        manager.removeObject(forKey: UserDefaultsKeys.loggedInUserInfo)
        manager.set(false, forKey: UserDefaultsKeys.isUserLoggedIn)
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
