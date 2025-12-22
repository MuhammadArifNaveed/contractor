//
//  AreasListViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON
class AreaListViewModel {
    var areaList = [AreaViewModel]()
    
    init() {
        self.areaList = [AreaViewModel]()
    }
    
    //convenience
    convenience init(list: JSON) {
        self.init()
        if let jsonList = list.array{
            let list = jsonList.map({AreaViewModel($0)})
            self.areaList.append(contentsOf: list)
        }
    }
}
