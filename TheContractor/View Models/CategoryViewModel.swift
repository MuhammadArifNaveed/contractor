//
//  CategoryViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//
import Foundation
import SwiftyJSON


class CategoryViewModel{

    //MARK:- data members
    var id : String = kBlankString
    var name: String = kBlankString
    var arabic_name : String = kBlankString
    var icon : String = kBlankString
    var isSelected : Bool = false
    var sub_categories : SubCategoryListViewModel = SubCategoryListViewModel()
   
    
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        id = json["id"].stringValue
        name = json["name"].stringValue
        arabic_name = json["arabic_name"].stringValue
        icon = json["icon"].stringValue
        sub_categories = SubCategoryListViewModel(list: json["sub_categories"])
    }
}
