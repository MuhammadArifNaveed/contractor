
import Foundation
import Alamofire
import SwiftyJSON

class LoginService: BaseService {
    
    //MARK:- Shared Instance
    private override init() {}
    static func shared() -> LoginService {
        return LoginService()
    }
    
    fileprivate func saveUserInfo(_ userInfo:UserViewModel) {
        Global.shared.user = userInfo
        UserDefaultsManager.shared.isUserLoggedIn = true
        UserDefaultsManager.shared.userInfo = userInfo
    }
    
    //MARK:- Verify Url API
    func verifyUrl(params:Parameters?,completion: @escaping (_ error: String, _ success: Bool)->Void) {
        
//        let completeURL = EndPoints.BASE_URL
//        self.makePostAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
//            if success {
//                let data = json![KEY_RESPONSE_DATA]
//                Global.shared.url = data["url"].stringValue
//                UserDefaultsManager.shared.configurationUrl = data["url"].stringValue
//            }
//            completion(message,success)
//        }
    }
    func getUserLogin(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.login
        self.makePostAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = UserViewModel( json!["user"])
                Global.shared.user = data
                Global.shared.isLogedIn = true
                   
                completion(message,true)
            }
            else{
              completion(message,false)
            }
        }
    }
    
    func getHomeData(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool , _ home : HomeViewModel?)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.home
        self.makeGetAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = HomeViewModel(json!)
                completion(message,true,data)
            }
            else{
              completion(message,false,nil)
            }
        }
    }
    
    func getEsstimationData(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool , _ home : CategoryListViewModel?)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.homeEsstimation
        self.makeGetAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = CategoryListViewModel(list: json!["estimation_categories"])
                completion(message,true,data)
            }
            else{
              completion(message,false,nil)
            }
        }
    }
    
    func getSearchData(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool , _ home : SearchViewModel?)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.getSearch
        self.makeGetAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = SearchViewModel(json!)
                completion(message,true,data)
            }
            else{
              completion(message,false,nil)
            }
        }
    }
    
    func getSearchedCompanies(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool , _ home : CompanyListViewModel?)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.searchedData
        print(params)
        self.makePostAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = CompanyListViewModel(list: json!["companies_list"])
                completion(message,true,data)
            }
            else{
              completion(message,false,nil)
            }
        }
    }
}
