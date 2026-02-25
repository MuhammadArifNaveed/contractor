
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
        Global.shared.loginType = "user"
        Global.shared.isLogedIn = true
        UserDefaultsManager.shared.isUserLoggedIn = true
        UserDefaultsManager.shared.isCompanyLoggedIn = false
        UserDefaultsManager.shared.loginType = "user"
        UserDefaultsManager.shared.userInfo = userInfo
    }
    
    fileprivate func saveCompanyInfo(_ vendor: CompanyVendor) {
        Global.shared.companyVendor = vendor
        Global.shared.loginType = "company"
        Global.shared.isLogedIn = true
        UserDefaultsManager.shared.isUserLoggedIn = false
        UserDefaultsManager.shared.isCompanyLoggedIn = true
        UserDefaultsManager.shared.loginType = "company"
        UserDefaultsManager.shared.companyInfo = vendor
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
        
        // Create a custom session manager to intercept cookies
        let manager = Alamofire.Session.default
        
        manager.request(completeURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: getHeaders())
            .validate(statusCode: 200...501)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    // Extract and save session cookie from response headers
                    if let responseHeaders = response.response?.allHeaderFields as? [String: Any],
                       let cookies = responseHeaders["Set-Cookie"] as? String {
                        // Extract ci_session from cookie string
                        let cookieParts = cookies.components(separatedBy: ";")
                        for part in cookieParts {
                            let trimmedPart = part.trimmingCharacters(in: .whitespaces)
                            if trimmedPart.hasPrefix("ci_session=") {
                                let sessionValue = trimmedPart.replacingOccurrences(of: "ci_session=", with: "")
                                UserDefaultsManager.shared.token = sessionValue
                                break
                            }
                        }
                    }
                    
                    let json = JSON(value)
                    let parsedResponse = ResponseHandler.handleResponse(json)
                    
                if parsedResponse.serviceResponseType == .Success {
                    let data = UserViewModel(json["user"])
                    self.saveUserInfo(data)
                    
                    completion(parsedResponse.message,true)
                }
                    else{
                      completion(parsedResponse.message,false)
                    }
                    
                case .failure(let error):
                    let errorMessage:String = error.localizedDescription
                    print(errorMessage)
                    completion(PopupMessages.SomethingWentWrong, false)
                }
            }
    }
    
    // MARK: - Company (Vendor) Login
    /// Logs in a company using email + 4-digit pin code.
    func loginCompany(email: String,
                      pinCode: String,
                      firebaseToken: String,
                      completion: @escaping (_ error: String, _ success: Bool, _ vendor: CompanyVendor?) -> Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.loginCompany
        let params: [String: String] = [
            "login_email": email,
            "login_password": pinCode,
            "device_type": "ios",
            "firebase_token": firebaseToken
        ]

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let vendorJSON = json["Vendor"]
                let vendor = CompanyVendor(json: vendorJSON)
                self.saveCompanyInfo(vendor)
                completion(message, true, vendor)
            } else {
                completion(message, false, nil)
            }
        }
    }
    
    // MARK: - Company (Vendor) Registration
    /// Registers a new company/vendor account.
    func registerCompany(params: [String: String],
                        completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/register_company"
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Company (Vendor) Forgot Password
    /// Step 1: Send reset pin to vendor email
    func vendorForgotPasswordSendPin(email: String,
                                    completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/send_reset_password_pin"
        let params: [String: String] = ["email": email]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Step 2: Verify reset pin code
    func vendorForgotPasswordVerifyPin(email: String, pin: String,
                                       completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/reset_pin_check"
        let params: [String: String] = ["email": email, "pin": pin]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Step 3: Update vendor password
    func vendorUpdatePassword(email: String, password: String,
                            completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/update_password"
        let params: [String: String] = ["password": password, "email": email]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Cart System
    /// Check cart limit for current user
    func checkCartLimit(userId: String,
                       completion: @escaping (_ message: String, _ success: Bool, _ cartLimit: Int, _ availableLimit: Int) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/check_cart_limit"
        let params: [String: String] = ["user_id": userId]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let cartLimit = json["cart_limit"].intValue
                let availableLimit = json["available_cart_limit"].intValue
                completion(message, true, cartLimit, availableLimit)
            } else {
                completion(message, false, 0, 0)
            }
        }
    }
    
    // MARK: - Enquiries
    /// Submit enquiry to selected companies
    func submitEnquiry(userId: String,
                      firstName: String,
                      lastName: String,
                      phone: String,
                      email: String,
                      companiesJSON: String,
                      completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_enquiries"
        let params: [String: String] = [
            "user_id": userId,
            "first_name": firstName,
            "last_name": lastName,
            "phone": phone,
            "email": email,
            "companies": companiesJSON
        ]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
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
