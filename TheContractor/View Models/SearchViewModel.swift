//
//  SearchViewModel.swift
//  TheContractor
//
//  Created by Rana Faheem on 9/21/21.
//
import Foundation
import SwiftyJSON
class SearchViewModel{

    //MARK:- data members
    var cities : CitiesListViewModel = CitiesListViewModel()
    var categories: CategoryListViewModel = CategoryListViewModel()
  
    
   
    
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        cities = CitiesListViewModel(list: json["cities"])
        categories = CategoryListViewModel(list: json["categories"])
    }
}
