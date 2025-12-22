//
//  CompanyListViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON
class CompanyListViewModel {
    var companyList = [CompanyViewModel]()
    
    init() {
        self.companyList = [CompanyViewModel]()
    }
    
    //convenience
    convenience init(list: JSON) {
        self.init()
        if let jsonList = list.array{
            let list = jsonList.map({CompanyViewModel($0)})
            self.companyList.append(contentsOf: list)
        }
    }
    
}
