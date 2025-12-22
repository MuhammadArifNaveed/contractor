////
////  RealmOperations.swift
////  OrderAte
////
////  Created by Gulfam Khan on 19/09/2019.
////  Copyright © 2019 Rapidzz. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//class RealmOperations {
//    private init() {
//        let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//        Realm.Configuration.defaultConfiguration = realmConfig
//    }
//
//    class func shared() -> RealmOperations {
//        return RealmOperations()
//    }
//
//    func clearDatabase(completion: @escaping (_ message:String, _ success:Bool)->Void) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                realm.deleteAll()
//            }
//            completion("cleared", true)
//        }catch let error {
//            completion(error.localizedDescription, false)
//        }
//    }
//
//    func getCount<T:Object>(type:T.Type, completion: @escaping (_ count:Int)->Void) {
//        do {
//            let realm = try Realm()
//            let count = realm.objects(type.self).count
//            completion(count)
//
//        }catch let error {
//            print(error.localizedDescription)
//            completion(kInt0)
//        }
//    }
//
//    func addObject<T:Object>(_ object:T, isUpdate:Bool = true, completion: @escaping (_ message: String, _ success: Bool)->Void) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                if isUpdate {
//                    realm.add(object, update: .modified)
//                }else {
//                    realm.add(object)
//                }
//            }
//            completion("added to db", true)
//        }catch let error {
//            completion(error.localizedDescription, false)
//        }
//    }
//
//    func addObjectList<T:Object>(_ objectList:[T], completion: @escaping (_ message: String, _ success: Bool)->Void) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                realm.add(objectList, update: .modified)
//            }
//            completion("added to db", true)
//        }catch let error {
//            completion(error.localizedDescription, false)
//        }
//    }
//
//    func getObject<T:Object>(forPrimaryKey id:String, type:T.Type, completion: @escaping (_ message:String, _ success:Bool, _ object:T?)->Void) {
//        do {
//            let realm = try Realm()
//
//            let object = realm.object(ofType: type, forPrimaryKey: id)
//            if(object != nil){
//                completion(kBlankString, true, object)
//            }
//            else{
//                completion(kBlankString, false, object)
//            }
//
//        }catch let error {
//            completion(error.localizedDescription, false, nil)
//        }
//    }
//
//    func getAllObjects<T:Object>(ofType type:T.Type, completion:@escaping (_ message:String, _ success:Bool, _ object:Results<T>? )->Void) {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(type)
//
//            if objects.count > 0 {
//                completion("object found",true,objects)
//            }else {
//                completion(kBlankString,false,nil)
//            }
//
//        }catch let error {
//            completion(error.localizedDescription,false,nil)
//        }
//    }
//
//    func removeObject<T:Object>(forPrimaryKey id:String, type:T.Type, completion: @escaping (_ message:String, _ success:Bool)->Void) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                if let object = realm.object(ofType: type, forPrimaryKey: id) {
//                    realm.delete(object)
//                }
//            }
//            completion(kBlankString, true)
//        }catch let error {
//            completion(error.localizedDescription, false)
//        }
//    }
//
//    func removeAllObjects<T:Object>(ofType type:T.Type, completion:@escaping (_ message:String, _ success:Bool)->Void) {
//        do {
//            let realm = try Realm()
//            try realm.write {
//                let objects = realm.objects(type)
//                realm.delete(objects)
//            }
//            completion(kBlankString,true)
//        }catch let error {
//            completion(error.localizedDescription,false)
//        }
//    }
//
//}
