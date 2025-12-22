//
//  CategoryListViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON

class CategoryListViewModel {
    var categoryList = [CategoryViewModel]()
    
    init() {
        self.categoryList = [CategoryViewModel]()
    }
    
    //convenience
    convenience init(list: JSON) {
        self.init()
        if let jsonList = list.array{
            let list = jsonList.map({CategoryViewModel($0)})
            self.categoryList.append(contentsOf: list)
        }
    }
    
}
