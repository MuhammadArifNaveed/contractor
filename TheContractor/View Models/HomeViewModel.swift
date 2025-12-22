import Foundation
import SwiftyJSON

class HomeViewModel{

    //MARK:- data members
    var categoryList : CategoryListViewModel = CategoryListViewModel()
    var companyList: CompanyListViewModel = CompanyListViewModel()
    var titiniumCompanyList : CompanyListViewModel = CompanyListViewModel()
  
    //MARK:- Init methods
    required convenience init(_ json: JSON){
        self.init()
        categoryList = CategoryListViewModel(list: json["categories"])
        companyList = CompanyListViewModel(list: json["companies_list"])
        titiniumCompanyList = CompanyListViewModel(list:  json["titanium_companies"])
    }
}
