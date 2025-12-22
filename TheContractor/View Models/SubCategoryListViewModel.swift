//
//  SubCategoryListViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//



import Foundation
import SwiftyJSON

class SubCategoryListViewModel {
    var subCategoryList = [SubCategoryViewModel]()
    
    init() {
        self.subCategoryList = [SubCategoryViewModel]()
    }
    
    //convenience
    convenience init(list: JSON) {
        self.init()
        if let jsonList = list.array{
            let list = jsonList.map({SubCategoryViewModel($0)})
            self.subCategoryList.append(contentsOf: list)
        }
    }
    
}
