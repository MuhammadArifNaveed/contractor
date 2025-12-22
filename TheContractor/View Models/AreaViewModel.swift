//
//  CategoryViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//
import Foundation
import SwiftyJSON


class AreaViewModel{

    //MARK:- data members
    var area_name : String = kBlankString
    var arabic_name: String = kBlankString
    var area_id : String = kBlankString
 
    
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        area_name = json["area_name"].stringValue
        arabic_name = json["arabic_name"].stringValue
        area_id = json["area_id"].stringValue
    }
}
