//
//  CompanyViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON


class CompanyViewModel{

    //MARK:- data members
    var id : String = kBlankString
    var login_email: String = kBlankString
    var category_id : String = kBlankString
    var company_name : String = kBlankString
    var company_logo : String = kBlankString
    var company_discription : String = kBlankString
    var total_rating : String = kBlankString
    var category_name : String = kBlankString
    var review_count : String = kBlankString
   
    
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        id = json["id"].stringValue
        login_email = json["login_email"].stringValue
        category_id = json["category_id"].stringValue
        company_name = json["company_name"].stringValue
        company_logo = json["company_logo"].stringValue
        company_logo = "https://contractor.thecontractor.ae/uploads/companies/" + company_logo
        company_discription = json["company_discription"].stringValue
        total_rating = json["total_rating"].stringValue
        category_name = json["category_name"].stringValue
        review_count = json["review_count"].stringValue
   }
}
