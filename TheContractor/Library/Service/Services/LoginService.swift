
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
    func submitEnquiry(userId: String, firstName: String, lastName: String, phone: String, email: String, companiesJSON: String,
                      completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_enquiries"
        let params: [String: String] = ["user_id": userId, "first_name": firstName, "last_name": lastName, "phone": phone, "email": email, "companies": companiesJSON]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get enquiries list for user
    func getEnquiries(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_enquiries"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get enquiry detail
    func getEnquiryDetail(enquiryId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/enquiry_detail"
        let params: [String: String] = ["enquiry_id": enquiryId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Quotations
    /// Submit quotation request
    func submitQuotationRequest(userId: String, companyId: String, description: String, location: String, dateTime: String,
                               completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_quotation_request"
        let params: [String: String] = ["user_id": userId, "company_id": companyId, "description": description, "location": location, "date_time": dateTime]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get quotations list
    func getQuotations(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_quotations"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get quotation detail
    func getQuotationDetail(quotationId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/quotation_detail"
        let params: [String: String] = ["quotation_id": quotationId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Complaints
    /// Submit complaint with optional images
    func submitComplaint(userId: String, companyId: String, subject: String, description: String, images: [Data]?,
                        completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_complaint"
        var params: [String: String] = ["user_id": userId, "company_id": companyId, "subject": subject, "description": description]
        var imageDict: [String: Data] = [:]
        if let images = images {
            for (index, imageData) in images.enumerated() {
                imageDict["image\(index + 1)"] = imageData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: true) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get complaints list
    func getComplaints(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_complaints"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get complaint detail
    func getComplaintDetail(complaintId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/complaint_detail"
        let params: [String: String] = ["complaint_id": complaintId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Profile Management
    /// Change user password
    func changePassword(userId: String, oldPassword: String, newPassword: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/change_password"
        let params: [String: String] = ["user_id": userId, "old_password": oldPassword, "new_password": newPassword]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Update user profile with optional image
    func updateProfile(userId: String, name: String, surname: String, phone: String, email: String, address: String?, profileImage: Data?,
                      completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/update_profile"
        var params: [String: String] = ["user_id": userId, "name": name, "surname": surname, "phone": phone, "email": email]
        if let address = address { params["address"] = address }
        var imageDict: [String: Data] = [:]
        if let profileImage = profileImage { imageDict["profile_image"] = profileImage }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Estimations
    /// Get estimation categories
    func getEstimationCategories(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_estimation_categories"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get estimation items by category
    func getEstimationItems(categoryId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_estimation_items"
        let params: [String: String] = ["category_id": categoryId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Search & Filter
    /// Search companies with filters
    func searchCompanies(filters: [String: String], completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_companies"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: filters, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Search freelancers with filters
    func searchFreelancers(filters: [String: String], completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_freelancers"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: filters, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Search workshops with filters
    func searchWorkshops(filters: [String: String], completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_workshops"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: filters, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Workshops
    /// Get all workshops
    func getWorkshops(pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_workshops"
        let params: [String: String] = ["page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get workshop detail
    func getWorkshopDetail(workshopId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/workshop_detail"
        let params: [String: String] = ["workshop_id": workshopId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Enroll in workshop
    func enrollWorkshop(userId: String, workshopId: String, paymentMethod: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/enroll_workshop"
        var params: [String: String] = ["user_id": userId, "workshop_id": workshopId]
        if let paymentMethod = paymentMethod { params["payment_method"] = paymentMethod }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get user workshop enrollments
    func getUserWorkshops(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_workshops"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Vendor Dashboard
    /// Get vendor dashboard stats
    func getVendorDashboard(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/dashboard"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get vendor enquiries
    func getVendorEnquiries(vendorId: String, status: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/enquiries"
        var params: [String: String] = ["vendor_id": vendorId, "page_no": pageNo]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get vendor quotations
    func getVendorQuotations(vendorId: String, status: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/quotations"
        var params: [String: String] = ["vendor_id": vendorId, "page_no": pageNo]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit vendor quotation response
    func submitVendorQuotation(quotationId: String, amount: String, notes: String, validUntil: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/submit_quotation"
        let params: [String: String] = ["quotation_id": quotationId, "amount": amount, "notes": notes, "valid_until": validUntil]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Notifications
    /// Get user notifications
    func getNotifications(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_notifications"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Mark notification as read
    func markNotificationRead(notificationId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/mark_notification_read"
        let params: [String: String] = ["notification_id": notificationId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Update notification settings
    func updateNotificationSettings(userId: String, settings: [String: String], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/update_notification_settings"
        var params = settings
        params["user_id"] = userId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Reviews & Ratings
    /// Get company reviews
    func getCompanyReviews(companyId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/company_reviews"
        let params: [String: String] = ["company_id": companyId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit review with optional images
    func submitReview(companyId: String, userId: String, rating: String, comment: String, images: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/submit_review"
        var params: [String: String] = ["company_id": companyId, "user_id": userId, "rating": rating, "comment": comment]
        var imageDict: [String: Data] = [:]
        if let images = images {
            for (index, imageData) in images.enumerated() {
                imageDict["image\(index + 1)"] = imageData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get company rating stats
    func getCompanyRatingStats(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/company_rating_stats"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Memberships
    /// Get membership plans
    func getMembershipPlans(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/membership_plans"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user membership
    func getUserMembership(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_membership"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Purchase membership
    func purchaseMembership(userId: String, planId: String, paymentMethod: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/purchase_membership"
        let params: [String: String] = ["user_id": userId, "plan_id": planId, "payment_method": paymentMethod]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Jobs Portal
    /// Get job listings
    func getJobs(filters: [String: String], completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_jobs"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: filters, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get job detail
    func getJobDetail(jobId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/job_detail"
        let params: [String: String] = ["job_id": jobId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Apply for job with optional resume
    func applyForJob(jobId: String, userId: String, name: String, phone: String, email: String, coverLetter: String, resume: Data?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/apply_job"
        var params: [String: String] = ["job_id": jobId, "user_id": userId, "name": name, "phone": phone, "email": email, "cover_letter": coverLetter]
        var fileDict: [String: Data] = [:]
        if let resume = resume { fileDict["resume"] = resume }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get user job applications
    func getUserJobApplications(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_job_applications"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Vendor Workshops Management
    /// Get vendor workshops
    func getVendorWorkshops(vendorId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/workshops"
        let params: [String: String] = ["vendor_id": vendorId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create workshop with images
    func createWorkshop(vendorId: String, title: String, titleArabic: String, description: String, categoryId: String, location: String, city: String, date: String, startTime: String, endTime: String, price: String, capacity: String, images: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/create_workshop"
        var params: [String: String] = ["vendor_id": vendorId, "title": title, "title_arabic": titleArabic, "description": description, "category_id": categoryId, "location": location, "city": city, "date": date, "start_time": startTime, "end_time": endTime, "price": price, "capacity": capacity]
        var imageDict: [String: Data] = [:]
        if let images = images {
            for (index, imageData) in images.enumerated() {
                imageDict["image\(index + 1)"] = imageData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get workshop enrollments
    func getWorkshopEnrollments(workshopId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/workshop_enrollments"
        let params: [String: String] = ["workshop_id": workshopId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Documents
    /// Get documents
    func getDocuments(categoryId: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_documents"
        var params: [String: String] = ["page_no": pageNo]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload document
    func uploadDocument(title: String, description: String, categoryId: String?, fileData: Data, fileName: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/upload_document"
        var params: [String: String] = ["title": title, "description": description]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        let fileDict: [String: Data] = ["document": fileData]
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: true) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get company documents
    func getCompanyDocuments(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/company_documents"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
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
