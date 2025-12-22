//
//  UserViewModel.swift
//  GirlsChase
//
//  Created by Rapidzz Macbook on 14/06/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import Foundation
import SwiftyJSON




class UserViewModel{
    //:NSObject, NSCoding {
   
    
    var name: String = kBlankString
    var surname: String =  kBlankString
    var phone : String = kBlankString
//    var deleted: Bool
//    var windowsId : String
//    var firstName: String
//    var middleName: String
//    var lastName: String
//    var loginName: String
//    var email: String
//    var encryptedPassword: String
//    var showTips: Bool
//    var isPersistent: Bool
//    var lastClientUpdate: String
//    var passwordLastChanged: String
//    var isAdmin: Bool
//
    //override init() {
   // override init()
//        self.id = kBlankString
//        self.accountId = kBlankString
//        self.deleted = false
//        self.windowsId = kBlankString
//        self.firstName = kBlankString
//        self.middleName = kBlankString
//        self.lastName = kBlankString
//        self.loginName = kBlankString
//        self.email = kBlankString
//        self.encryptedPassword = kBlankString
//        self.showTips = false
//        self.isPersistent = false
//        self.lastClientUpdate = kBlankString
//        self.passwordLastChanged = kBlankString
//        self.isAdmin = false
        
   // }
//
    convenience init(_ json : JSON){
        self.init()
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.phone = json["phone"].stringValue
//        self.windowsId = operater.windowsId
//        self.firstName = operater.firstName
//        self.middleName = operater.middleName
//        self.lastName = operater.lastName
//        self.loginName = operater.loginName
//        self.email = operater.email
//        self.encryptedPassword = operater.encryptedPassword
//        self.showTips = operater.showTips
//        self.isPersistent = operater.isPersistent
//        self.lastClientUpdate = operater.lastClientUpdate
//        self.passwordLastChanged = operater.passwordLastChanged
//        self.isAdmin = operater.isAdmin

    }
//
//    required convenience init(coder aDecoder: NSCoder) {
//        self.init()
//
//        self.id = aDecoder.decodeObject(forKey: "Id") as! String
//        self.accountId = aDecoder.decodeObject(forKey: "accountId") as! String
//        self.deleted = aDecoder.decodeBool(forKey: "Deleted")
//        self.windowsId = aDecoder.decodeObject(forKey: "WindowsId") as! String
//        self.firstName = aDecoder.decodeObject(forKey: "FirstName") as! String
//        self.middleName = aDecoder.decodeObject(forKey: "MiddleName") as! String
//        self.lastName = aDecoder.decodeObject(forKey: "LastName") as! String
//        self.loginName = aDecoder.decodeObject(forKey: "LoginName") as! String
//        self.email = aDecoder.decodeObject(forKey: "Email") as! String
//        self.encryptedPassword = aDecoder.decodeObject(forKey: "EncryptedPassword") as! String
//        self.showTips = aDecoder.decodeBool(forKey: "ShowTips")
//        self.isPersistent = aDecoder.decodeBool(forKey: "IsPersistent")
//        self.lastClientUpdate = aDecoder.decodeObject(forKey: "LastClientUpdate") as! String
//        self.passwordLastChanged = aDecoder.decodeObject(forKey: "PasswordLastChanged") as! String
//        self.isAdmin = aDecoder.decodeBool(forKey: "IsAdmin")
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(self.id, forKey: "Id")
//        aCoder.encode(self.accountId, forKey: "accountId")
//        aCoder.encode(self.deleted, forKey: "Deleted")
//        aCoder.encode(self.windowsId, forKey: "WindowsId")
//        aCoder.encode(self.firstName, forKey: "FirstName")
//        aCoder.encode(self.middleName, forKey: "MiddleName")
//        aCoder.encode(self.lastName, forKey: "LastName")
//        aCoder.encode(self.loginName, forKey: "LoginName")
//        aCoder.encode(self.email, forKey: "Email")
//        aCoder.encode(self.encryptedPassword, forKey: "EncryptedPassword")
//        aCoder.encode(self.showTips, forKey: "ShowTips")
//        aCoder.encode(self.isPersistent, forKey: "IsPersistent")
//        aCoder.encode(self.lastClientUpdate, forKey: "LastClientUpdate")
//        aCoder.encode(self.passwordLastChanged, forKey: "PasswordLastChanged")
//        aCoder.encode(self.isAdmin, forKey: "IsAdmin")
//
//    }
}


