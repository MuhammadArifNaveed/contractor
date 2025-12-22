//
//  CitiesListViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON
class CitiesListViewModel {
    
    var cityList = [CityViewModel]()
    
    init() {
        self.cityList = [CityViewModel]()
    }
    
    //convenience
    convenience init(list: JSON) {
        self.init()
        if let jsonList = list.array{
            let list = jsonList.map({CityViewModel($0)})
            self.cityList.append(contentsOf: list)
        }
    }
}

