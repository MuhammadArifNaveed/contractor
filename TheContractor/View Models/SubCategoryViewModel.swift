//
//  SubCategoryViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON

class SubCategoryViewModel{

    //MARK:- data members
    var id : String = kBlankString
    var category_id: String = kBlankString
    var name : String = kBlankString
    var arabic_name : String = kBlankString
    var is_active : String = kBlankString
    var isSelected : Bool = false
    var min_val : String = kBlankString
   
    
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        id = json["id"].stringValue
        category_id = json["category_id"].stringValue
        name = json["name"].stringValue
        arabic_name = json["arabic_name"].stringValue
        is_active = json["is_active"].stringValue
        min_val = json["min_val"].stringValue
      
    }
}
