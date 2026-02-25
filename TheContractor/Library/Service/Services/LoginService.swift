
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
    
    // MARK: - 24/7 Emergency Services
    /// Get emergency companies (24/7 available)
    func getEmergencyCompanies(categoryId: String?, cityId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/emergency_companies"
        var params: [String: String] = ["is_24x7": "1"]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        if let cityId = cityId { params["city_id"] = cityId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit emergency request
    func submitEmergencyRequest(userId: String, companyId: String, description: String, location: String, lat: String, lng: String, urgencyLevel: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/emergency_request"
        let params: [String: String] = ["user_id": userId, "company_id": companyId, "description": description, "location": location, "lat": lat, "lng": lng, "urgency_level": urgencyLevel]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Freelancer Dashboard
    /// Get freelancer dashboard stats
    func getFreelancerDashboard(freelancerId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Freelancer/dashboard"
        let params: [String: String] = ["freelancer_id": freelancerId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get freelancer jobs
    func getFreelancerJobs(freelancerId: String, status: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Freelancer/jobs"
        var params: [String: String] = ["freelancer_id": freelancerId, "page_no": pageNo]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Update freelancer profile with portfolio
    func updateFreelancerProfile(userId: String, skills: String, experience: String, hourlyRate: String, availability: String, bio: String, portfolio: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Freelancer/update_profile"
        var params: [String: String] = ["user_id": userId, "skills": skills, "experience": experience, "hourly_rate": hourlyRate, "availability": availability, "bio": bio]
        var imageDict: [String: Data] = [:]
        if let portfolio = portfolio {
            for (index, imageData) in portfolio.enumerated() {
                imageDict["portfolio\(index + 1)"] = imageData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - App Settings
    /// Get app settings
    func getAppSettings(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/app_settings"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Update app settings
    func updateAppSettings(userId: String, settings: [String: String], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/update_app_settings"
        var params = settings
        params["user_id"] = userId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get available languages
    func getLanguages(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/languages"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Check app version
    func checkAppVersion(currentVersion: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/check_version"
        let params: [String: String] = ["version": currentVersion, "platform": "ios"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Payments
    /// Get payment methods
    func getPaymentMethods(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/payment_methods"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Process payment
    func processPayment(userId: String, amount: String, paymentMethodId: String, purpose: String, relatedId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/process_payment"
        var params: [String: String] = ["user_id": userId, "amount": amount, "payment_method_id": paymentMethodId, "purpose": purpose]
        if let relatedId = relatedId { params["related_id"] = relatedId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get payment history
    func getPaymentHistory(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/payment_history"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Analytics
    /// Get user analytics
    func getUserAnalytics(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_analytics"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get company analytics
    func getCompanyAnalytics(companyId: String, dateFrom: String?, dateTo: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/analytics"
        var params: [String: String] = ["company_id": companyId]
        if let dateFrom = dateFrom { params["date_from"] = dateFrom }
        if let dateTo = dateTo { params["date_to"] = dateTo }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Log activity
    func logActivity(userId: String, activityType: String, description: String, relatedId: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/log_activity"
        var params: [String: String] = ["user_id": userId, "activity_type": activityType, "description": description]
        if let relatedId = relatedId { params["related_id"] = relatedId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Social Features
    /// Get social feed
    func getSocialFeed(pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/social_feed"
        let params: [String: String] = ["page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create social post
    func createSocialPost(userId: String, content: String, images: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/create_post"
        var params: [String: String] = ["user_id": userId, "content": content]
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
    
    /// Like/Unlike post
    func likePost(userId: String, postId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/like_post"
        let params: [String: String] = ["user_id": userId, "post_id": postId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get post comments
    func getPostComments(postId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/post_comments"
        let params: [String: String] = ["post_id": postId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Add comment
    func addComment(userId: String, postId: String, content: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/add_comment"
        let params: [String: String] = ["user_id": userId, "post_id": postId, "content": content]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Help & Support
    /// Get FAQs
    func getFAQs(categoryId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/faqs"
        var params: [String: String] = [:]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create support ticket
    func createSupportTicket(userId: String, subject: String, description: String, category: String, priority: String, attachments: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/create_ticket"
        var params: [String: String] = ["user_id": userId, "subject": subject, "description": description, "category": category, "priority": priority]
        var fileDict: [String: Data] = [:]
        if let attachments = attachments {
            for (index, fileData) in attachments.enumerated() {
                fileDict["attachment\(index + 1)"] = fileData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get support tickets
    func getSupportTickets(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/support_tickets"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get ticket messages
    func getTicketMessages(ticketId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/ticket_messages"
        let params: [String: String] = ["ticket_id": ticketId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Send ticket message
    func sendTicketMessage(ticketId: String, userId: String, message: String, attachments: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_ticket_message"
        var params: [String: String] = ["ticket_id": ticketId, "user_id": userId, "message": message]
        var fileDict: [String: Data] = [:]
        if let attachments = attachments {
            for (index, fileData) in attachments.enumerated() {
                fileDict["attachment\(index + 1)"] = fileData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Company Portfolio
    /// Get company portfolio
    func getCompanyPortfolio(companyId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/portfolio"
        let params: [String: String] = ["company_id": companyId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Add portfolio item
    func addPortfolioItem(companyId: String, title: String, titleArabic: String, description: String, descriptionArabic: String, categoryId: String, location: String, completionDate: String, clientName: String?, projectCost: String?, images: [Data], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/add_portfolio"
        var params: [String: String] = ["company_id": companyId, "title": title, "title_arabic": titleArabic, "description": description, "description_arabic": descriptionArabic, "category_id": categoryId, "location": location, "completion_date": completionDate]
        if let clientName = clientName { params["client_name"] = clientName }
        if let projectCost = projectCost { params["project_cost"] = projectCost }
        var imageDict: [String: Data] = [:]
        for (index, imageData) in images.enumerated() {
            imageDict["image\(index + 1)"] = imageData
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get company gallery
    func getCompanyGallery(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/gallery"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload gallery images
    func uploadGalleryImages(companyId: String, images: [Data], captions: [String]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/upload_gallery"
        var params: [String: String] = ["company_id": companyId]
        if let captions = captions {
            for (index, caption) in captions.enumerated() {
                params["caption\(index + 1)"] = caption
            }
        }
        var imageDict: [String: Data] = [:]
        for (index, imageData) in images.enumerated() {
            imageDict["image\(index + 1)"] = imageData
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Bookmarks/Favorites
    /// Get bookmarked companies
    func getBookmarkedCompanies(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/bookmarked_companies"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Toggle company bookmark
    func toggleCompanyBookmark(userId: String, companyId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/toggle_company_bookmark"
        let params: [String: String] = ["user_id": userId, "company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get bookmarked workshops
    func getBookmarkedWorkshops(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/bookmarked_workshops"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Toggle workshop bookmark
    func toggleWorkshopBookmark(userId: String, workshopId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/toggle_workshop_bookmark"
        let params: [String: String] = ["user_id": userId, "workshop_id": workshopId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get bookmarked freelancers
    func getBookmarkedFreelancers(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/bookmarked_freelancers"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Toggle freelancer bookmark
    func toggleFreelancerBookmark(userId: String, freelancerId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/toggle_freelancer_bookmark"
        let params: [String: String] = ["user_id": userId, "freelancer_id": freelancerId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Recommendations
    /// Get recommended companies
    func getRecommendedCompanies(userId: String, categoryId: String?, limit: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/recommended_companies"
        var params: [String: String] = ["user_id": userId, "limit": limit]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get recommended workshops
    func getRecommendedWorkshops(userId: String, limit: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/recommended_workshops"
        let params: [String: String] = ["user_id": userId, "limit": limit]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get recommended freelancers
    func getRecommendedFreelancers(userId: String, skills: String?, limit: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/recommended_freelancers"
        var params: [String: String] = ["user_id": userId, "limit": limit]
        if let skills = skills { params["skills"] = skills }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Chat System
    /// Get chat conversations
    func getChatConversations(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Chat/conversations"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get chat messages
    func getChatMessages(conversationId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Chat/messages"
        let params: [String: String] = ["conversation_id": conversationId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Send chat message
    func sendChatMessage(conversationId: String, senderId: String, receiverId: String, message: String, messageType: String, attachments: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Chat/send_message"
        var params: [String: String] = ["conversation_id": conversationId, "sender_id": senderId, "receiver_id": receiverId, "message": message, "message_type": messageType]
        var fileDict: [String: Data] = [:]
        if let attachments = attachments {
            for (index, fileData) in attachments.enumerated() {
                fileDict["attachment\(index + 1)"] = fileData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Mark messages as read
    func markMessagesAsRead(conversationId: String, userId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Chat/mark_read"
        let params: [String: String] = ["conversation_id": conversationId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Update typing status
    func updateTypingStatus(conversationId: String, userId: String, isTyping: Bool, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Chat/typing_status"
        let params: [String: String] = ["conversation_id": conversationId, "user_id": userId, "is_typing": isTyping ? "1" : "0"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Promotions
    /// Get active promotions
    func getActivePromotions(companyId: String?, cityId: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/active_promotions"
        var params: [String: String] = ["page_no": pageNo]
        if let companyId = companyId { params["company_id"] = companyId }
        if let cityId = cityId { params["city_id"] = cityId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create promotion
    func createPromotion(companyId: String, title: String, titleArabic: String, description: String, descriptionArabic: String, discountType: String, discountValue: String, startDate: String, endDate: String, termsConditions: String?, banner: Data?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/create_promotion"
        var params: [String: String] = ["company_id": companyId, "title": title, "title_arabic": titleArabic, "description": description, "description_arabic": descriptionArabic, "discount_type": discountType, "discount_value": discountValue, "start_date": startDate, "end_date": endDate]
        if let termsConditions = termsConditions { params["terms_conditions"] = termsConditions }
        var imageDict: [String: Data] = [:]
        if let banner = banner { imageDict["banner"] = banner }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Claim promotion
    func claimPromotion(userId: String, promotionId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/claim_promotion"
        let params: [String: String] = ["user_id": userId, "promotion_id": promotionId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user promotions
    func getUserPromotions(userId: String, status: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_promotions"
        var params: [String: String] = ["user_id": userId]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Certifications & Licenses
    /// Get company certifications
    func getCompanyCertifications(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/certifications"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload certification
    func uploadCertification(companyId: String, certificateName: String, certificateNameArabic: String, issuingAuthority: String, certificateNumber: String, issueDate: String, expiryDate: String?, document: Data, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/upload_certification"
        var params: [String: String] = ["company_id": companyId, "certificate_name": certificateName, "certificate_name_arabic": certificateNameArabic, "issuing_authority": issuingAuthority, "certificate_number": certificateNumber, "issue_date": issueDate]
        if let expiryDate = expiryDate { params["expiry_date"] = expiryDate }
        let fileDict: [String: Data] = ["document": document]
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: true) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get company licenses
    func getCompanyLicenses(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/licenses"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload license
    func uploadLicense(companyId: String, licenseType: String, licenseTypeArabic: String, licenseNumber: String, issuingAuthority: String, issueDate: String, expiryDate: String, document: Data, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/upload_license"
        let params: [String: String] = ["company_id": companyId, "license_type": licenseType, "license_type_arabic": licenseTypeArabic, "license_number": licenseNumber, "issuing_authority": issuingAuthority, "issue_date": issueDate, "expiry_date": expiryDate]
        let fileDict: [String: Data] = ["document": document]
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: true) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Insurance
    /// Get company insurance policies
    func getCompanyInsurance(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/insurance_policies"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload insurance policy
    func uploadInsurancePolicy(companyId: String, policyType: String, policyTypeArabic: String, policyNumber: String, provider: String, coverageAmount: String, startDate: String, endDate: String, document: Data, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/upload_insurance"
        let params: [String: String] = ["company_id": companyId, "policy_type": policyType, "policy_type_arabic": policyTypeArabic, "policy_number": policyNumber, "provider": provider, "coverage_amount": coverageAmount, "start_date": startDate, "end_date": endDate]
        let fileDict: [String: Data] = ["document": document]
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: true) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Submit insurance claim
    func submitInsuranceClaim(policyId: String, userId: String, enquiryId: String?, claimAmount: String, claimDescription: String, documents: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/submit_insurance_claim"
        var params: [String: String] = ["policy_id": policyId, "user_id": userId, "claim_amount": claimAmount, "claim_description": claimDescription]
        if let enquiryId = enquiryId { params["enquiry_id"] = enquiryId }
        var fileDict: [String: Data] = [:]
        if let documents = documents {
            for (index, docData) in documents.enumerated() {
                fileDict["document\(index + 1)"] = docData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Advanced Filtering
    /// Search companies with advanced filters
    func searchCompaniesAdvanced(filters: [String: String], pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_companies_advanced"
        var params = filters
        params["page_no"] = pageNo
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Search workshops with advanced filters
    func searchWorkshopsAdvanced(filters: [String: String], pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_workshops_advanced"
        var params = filters
        params["page_no"] = pageNo
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Search freelancers with advanced filters
    func searchFreelancersAdvanced(filters: [String: String], pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/search_freelancers_advanced"
        var params = filters
        params["page_no"] = pageNo
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Save filter
    func saveFilter(userId: String, filterName: String, filterType: String, filterData: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/save_filter"
        let params: [String: String] = ["user_id": userId, "filter_name": filterName, "filter_type": filterType, "filter_data": filterData]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get saved filters
    func getSavedFilters(userId: String, filterType: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/saved_filters"
        var params: [String: String] = ["user_id": userId]
        if let filterType = filterType { params["filter_type"] = filterType }
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
