//
//  SearchViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//

import Foundation
import SwiftyJSON

class SearchViewModel {

    var cities: CitiesListViewModel = CitiesListViewModel()
    var categories: CategoryListViewModel = CategoryListViewModel()

    init() {}

    convenience init(_ json: JSON) {
        self.init()
        self.cities = CitiesListViewModel(list: json["cities"])
        self.categories = CategoryListViewModel(list: json["categories"])
    }
}
