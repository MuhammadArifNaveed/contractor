
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
    
    // MARK: - Video Content
    /// Get company videos
    func getCompanyVideos(companyId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/videos"
        let params: [String: String] = ["company_id": companyId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Upload video
    func uploadVideo(companyId: String, title: String, titleArabic: String, description: String, descriptionArabic: String, categoryId: String, videoUrl: String, thumbnailUrl: String, duration: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/upload_video"
        let params: [String: String] = ["company_id": companyId, "title": title, "title_arabic": titleArabic, "description": description, "description_arabic": descriptionArabic, "category_id": categoryId, "video_url": videoUrl, "thumbnail_url": thumbnailUrl, "duration": duration]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Like video
    func likeVideo(userId: String, videoId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/like_video"
        let params: [String: String] = ["user_id": userId, "video_id": videoId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Track video view
    func trackVideoView(userId: String, videoId: String, watchTime: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/track_video_view"
        let params: [String: String] = ["user_id": userId, "video_id": videoId, "watch_time": watchTime]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Subscriptions
    /// Get subscription plans
    func getSubscriptionPlans(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/subscription_plans"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Subscribe to plan
    func subscribeToPlan(userId: String, planId: String, paymentMethodId: String, autoRenew: Bool, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/subscribe"
        let params: [String: String] = ["user_id": userId, "plan_id": planId, "payment_method_id": paymentMethodId, "auto_renew": autoRenew ? "1" : "0"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user subscription
    func getUserSubscription(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_subscription"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Cancel subscription
    func cancelSubscription(subscriptionId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/cancel_subscription"
        let params: [String: String] = ["subscription_id": subscriptionId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get subscription usage
    func getSubscriptionUsage(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/subscription_usage"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Referrals
    /// Get referral program details
    func getReferralProgram(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/referral_program"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user referral code
    func getUserReferralCode(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_referral_code"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Apply referral code
    func applyReferralCode(userId: String, referralCode: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/apply_referral_code"
        let params: [String: String] = ["user_id": userId, "referral_code": referralCode]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get referral transactions
    func getReferralTransactions(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/referral_transactions"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get referral leaderboard
    func getReferralLeaderboard(limit: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/referral_leaderboard"
        let params: [String: String] = ["limit": limit]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Geolocation
    /// Get nearby companies
    func getNearbyCompanies(latitude: String, longitude: String, radius: String, categoryId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/nearby_companies"
        var params: [String: String] = ["latitude": latitude, "longitude": longitude, "radius": radius]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get company service areas
    func getCompanyServiceAreas(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/service_areas"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Add service area
    func addServiceArea(companyId: String, cityId: String, areaName: String, areaNameArabic: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/add_service_area"
        let params: [String: String] = ["company_id": companyId, "city_id": cityId, "area_name": areaName, "area_name_arabic": areaNameArabic]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Track user location
    func trackUserLocation(userId: String, latitude: String, longitude: String, accuracy: String, activityType: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/track_location"
        var params: [String: String] = ["user_id": userId, "latitude": latitude, "longitude": longitude, "accuracy": accuracy]
        if let activityType = activityType { params["activity_type"] = activityType }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Check geofence
    func checkGeofence(userId: String, latitude: String, longitude: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/check_geofence"
        let params: [String: String] = ["user_id": userId, "latitude": latitude, "longitude": longitude]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Push Notifications
    /// Register device for push notifications
    func registerPushDevice(userId: String, deviceToken: String, platform: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/register_push_device"
        let params: [String: String] = ["user_id": userId, "device_token": deviceToken, "platform": platform]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Update push notification settings
    func updatePushSettings(userId: String, settings: [String: String], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/update_push_settings"
        var params = settings
        params["user_id"] = userId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get push notification history
    func getPushNotifications(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/push_notifications"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Send push notification
    func sendPushNotification(userId: String, title: String, body: String, notificationType: String, data: [String: String]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/send_push_notification"
        var params: [String: String] = ["user_id": userId, "title": title, "body": body, "notification_type": notificationType]
        if let data = data {
            for (key, value) in data {
                params["data_\(key)"] = value
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - QR Codes
    /// Generate QR code
    func generateQRCode(companyId: String, qrType: String, data: [String: String], expiryHours: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/generate_qr_code"
        var params: [String: String] = ["company_id": companyId, "qr_type": qrType]
        if let expiryHours = expiryHours { params["expiry_hours"] = expiryHours }
        for (key, value) in data {
            params["data_\(key)"] = value
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Scan QR code
    func scanQRCode(qrData: String, userId: String?, latitude: String?, longitude: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/scan_qr_code"
        var params: [String: String] = ["qr_data": qrData]
        if let userId = userId { params["user_id"] = userId }
        if let latitude = latitude { params["latitude"] = latitude }
        if let longitude = longitude { params["longitude"] = longitude }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get company QR codes
    func getCompanyQRCodes(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/qr_codes"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get QR scan analytics
    func getQRScanAnalytics(qrId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/qr_scan_analytics"
        let params: [String: String] = ["qr_id": qrId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Barcode Scanner
    /// Scan barcode
    func scanBarcode(barcode: String, barcodeType: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/scan_barcode"
        let params: [String: String] = ["barcode": barcode, "barcode_type": barcodeType]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Add product with barcode
    func addBarcodeProduct(barcode: String, productName: String, productNameArabic: String, categoryId: String, manufacturer: String, price: String, description: String, descriptionArabic: String, image: Data?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/add_barcode_product"
        let params: [String: String] = ["barcode": barcode, "product_name": productName, "product_name_arabic": productNameArabic, "category_id": categoryId, "manufacturer": manufacturer, "price": price, "description": description, "description_arabic": descriptionArabic]
        var imageDict: [String: Data] = [:]
        if let image = image { imageDict["image"] = image }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Order material by barcode
    func orderMaterialByBarcode(userId: String, companyId: String, barcode: String, quantity: String, deliveryAddress: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/order_material"
        let params: [String: String] = ["user_id": userId, "company_id": companyId, "barcode": barcode, "quantity": quantity, "delivery_address": deliveryAddress]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get material orders
    func getMaterialOrders(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/material_orders"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Export & Reports
    /// Request export
    func requestExport(userId: String, exportType: String, format: String, dateFrom: String, dateTo: String, filters: [String: String]?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/request_export"
        var params: [String: String] = ["user_id": userId, "export_type": exportType, "format": format, "date_from": dateFrom, "date_to": dateTo]
        if let filters = filters {
            for (key, value) in filters {
                params["filter_\(key)"] = value
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get export requests
    func getExportRequests(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/export_requests"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get report templates
    func getReportTemplates(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/report_templates"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Generate dashboard report
    func generateDashboardReport(userId: String, reportType: String, dateFrom: String, dateTo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/generate_dashboard_report"
        let params: [String: String] = ["user_id": userId, "report_type": reportType, "date_from": dateFrom, "date_to": dateTo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Download report
    func downloadReport(exportId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/download_report"
        let params: [String: String] = ["export_id": exportId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Loyalty Program
    /// Get loyalty program details
    func getLoyaltyProgram(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/loyalty_program"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user loyalty account
    func getUserLoyaltyAccount(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_loyalty_account"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get loyalty transactions
    func getLoyaltyTransactions(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/loyalty_transactions"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get loyalty rewards
    func getLoyaltyRewards(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/loyalty_rewards"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Redeem loyalty reward
    func redeemLoyaltyReward(userId: String, rewardId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/redeem_loyalty_reward"
        let params: [String: String] = ["user_id": userId, "reward_id": rewardId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Vendor Ratings
    /// Get rating criteria
    func getRatingCriteria(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/rating_criteria"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get detailed vendor rating
    func getDetailedVendorRating(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/detailed_vendor_rating"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit detailed rating
    func submitDetailedRating(userId: String, companyId: String, criteriaRatings: [String: String], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/submit_detailed_rating"
        var params: [String: String] = ["user_id": userId, "company_id": companyId]
        for (criteriaId, rating) in criteriaRatings {
            params["criteria_\(criteriaId)"] = rating
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get vendor badges
    func getVendorBadges(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/badges"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Service Requests
    /// Create service request
    func createServiceRequest(userId: String, serviceType: String, categoryId: String, title: String, description: String, location: String, latitude: String, longitude: String, preferredDate: String, budgetRange: String, urgency: String, images: [Data]?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/create_service_request"
        let params: [String: String] = ["user_id": userId, "service_type": serviceType, "category_id": categoryId, "title": title, "description": description, "location": location, "latitude": latitude, "longitude": longitude, "preferred_date": preferredDate, "budget_range": budgetRange, "urgency": urgency]
        var imageDict: [String: Data] = [:]
        if let images = images {
            for (index, imageData) in images.enumerated() {
                imageDict["image\(index + 1)"] = imageData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: imageDict, params: params, isImageData: !imageDict.isEmpty) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get service requests
    func getServiceRequests(userId: String, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/service_requests"
        let params: [String: String] = ["user_id": userId, "page_no": pageNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get service proposals
    func getServiceProposals(requestId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/service_proposals"
        let params: [String: String] = ["request_id": requestId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit service proposal
    func submitServiceProposal(requestId: String, companyId: String, proposedAmount: String, estimatedDuration: String, description: String, includedServices: [String], validUntil: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/submit_service_proposal"
        var params: [String: String] = ["request_id": requestId, "company_id": companyId, "proposed_amount": proposedAmount, "estimated_duration": estimatedDuration, "description": description, "valid_until": validUntil]
        for (index, service) in includedServices.enumerated() {
            params["service\(index + 1)"] = service
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Accept service proposal
    func acceptServiceProposal(proposalId: String, userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/accept_service_proposal"
        let params: [String: String] = ["proposal_id": proposalId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Admin Dashboard
    /// Get admin dashboard stats
    func getAdminDashboardStats(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/dashboard_stats"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user activity logs
    func getUserActivityLogs(pageNo: String, userId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/user_activity_logs"
        var params: [String: String] = ["page_no": pageNo]
        if let userId = userId { params["user_id"] = userId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get pending approvals
    func getPendingApprovals(itemType: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/pending_approvals"
        var params: [String: String] = ["page_no": pageNo]
        if let itemType = itemType { params["item_type"] = itemType }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Approve/Reject item
    func approveRejectItem(itemId: String, itemType: String, action: String, reason: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/approve_reject_item"
        var params: [String: String] = ["item_id": itemId, "item_type": itemType, "action": action]
        if let reason = reason { params["reason"] = reason }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get system health metrics
    func getSystemHealthMetrics(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/system_health"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get revenue metrics
    func getRevenueMetrics(dateFrom: String, dateTo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/revenue_metrics"
        let params: [String: String] = ["date_from": dateFrom, "date_to": dateTo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Availability Calendar
    /// Get company availability
    func getCompanyAvailability(companyId: String, dateFrom: String, dateTo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/availability"
        let params: [String: String] = ["company_id": companyId, "date_from": dateFrom, "date_to": dateTo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Set company availability
    func setCompanyAvailability(companyId: String, date: String, availabilityType: String, startTime: String?, endTime: String?, maxBookings: String?, notes: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/set_availability"
        var params: [String: String] = ["company_id": companyId, "date": date, "availability_type": availabilityType]
        if let startTime = startTime { params["start_time"] = startTime }
        if let endTime = endTime { params["end_time"] = endTime }
        if let maxBookings = maxBookings { params["max_bookings"] = maxBookings }
        if let notes = notes { params["notes"] = notes }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get booking slots
    func getBookingSlots(companyId: String, date: String, serviceType: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/booking_slots"
        var params: [String: String] = ["company_id": companyId, "date": date]
        if let serviceType = serviceType { params["service_type"] = serviceType }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Book appointment
    func bookAppointment(userId: String, companyId: String, slotId: String, serviceType: String, notes: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/book_appointment"
        var params: [String: String] = ["user_id": userId, "company_id": companyId, "slot_id": slotId, "service_type": serviceType]
        if let notes = notes { params["notes"] = notes }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user appointments
    func getUserAppointments(userId: String, status: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_appointments"
        var params: [String: String] = ["user_id": userId]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Multi-Currency
    /// Get supported currencies
    func getSupportedCurrencies(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/supported_currencies"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Convert currency
    func convertCurrency(amount: String, fromCurrency: String, toCurrency: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/convert_currency"
        let params: [String: String] = ["amount": amount, "from_currency": fromCurrency, "to_currency": toCurrency]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Set user currency preference
    func setUserCurrencyPreference(userId: String, preferredCurrency: String, autoConvert: Bool, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/set_currency_preference"
        let params: [String: String] = ["user_id": userId, "preferred_currency": preferredCurrency, "auto_convert": autoConvert ? "1" : "0"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get exchange rates
    func getExchangeRates(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/exchange_rates"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Dispute Resolution
    /// File dispute
    func fileDispute(enquiryId: String, userId: String, companyId: String, disputeType: String, subject: String, description: String, priority: String, evidence: [Data]?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/file_dispute"
        let params: [String: String] = ["enquiry_id": enquiryId, "user_id": userId, "company_id": companyId, "dispute_type": disputeType, "subject": subject, "description": description, "priority": priority]
        var fileDict: [String: Data] = [:]
        if let evidence = evidence {
            for (index, fileData) in evidence.enumerated() {
                fileDict["evidence\(index + 1)"] = fileData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get user disputes
    func getUserDisputes(userId: String, status: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/user_disputes"
        var params: [String: String] = ["user_id": userId]
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get dispute messages
    func getDisputeMessages(disputeId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/dispute_messages"
        let params: [String: String] = ["dispute_id": disputeId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Send dispute message
    func sendDisputeMessage(disputeId: String, senderId: String, message: String, attachments: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/send_dispute_message"
        var params: [String: String] = ["dispute_id": disputeId, "sender_id": senderId, "message": message]
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
    
    /// Resolve dispute
    func resolveDispute(disputeId: String, resolution: String, compensationAmount: String?, actionTaken: String, closureNotes: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/resolve_dispute"
        var params: [String: String] = ["dispute_id": disputeId, "resolution": resolution, "action_taken": actionTaken, "closure_notes": closureNotes]
        if let compensationAmount = compensationAmount { params["compensation_amount"] = compensationAmount }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Tender Management
    /// Get active tenders
    func getActiveTenders(categoryId: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/active_tenders"
        var params: [String: String] = ["page_no": pageNo]
        if let categoryId = categoryId { params["category_id"] = categoryId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get tender details
    func getTenderDetails(tenderId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/tender_details"
        let params: [String: String] = ["tender_id": tenderId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit tender bid
    func submitTenderBid(tenderId: String, companyId: String, bidAmount: String, proposedTimeline: String, technicalProposal: String, financialProposal: String, documents: [Data]?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/submit_tender_bid"
        let params: [String: String] = ["tender_id": tenderId, "company_id": companyId, "bid_amount": bidAmount, "proposed_timeline": proposedTimeline, "technical_proposal": technicalProposal, "financial_proposal": financialProposal]
        var fileDict: [String: Data] = [:]
        if let documents = documents {
            for (index, docData) in documents.enumerated() {
                fileDict["document\(index + 1)"] = docData
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: fileDict, params: params, isImageData: !fileDict.isEmpty) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get tender bids
    func getTenderBids(tenderId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/tender_bids"
        let params: [String: String] = ["tender_id": tenderId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Evaluate tender bid
    func evaluateTenderBid(bidId: String, technicalScore: String, financialScore: String, complianceScore: String, comments: String, recommendation: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/evaluate_tender_bid"
        let params: [String: String] = ["bid_id": bidId, "technical_score": technicalScore, "financial_score": financialScore, "compliance_score": complianceScore, "comments": comments, "recommendation": recommendation]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Award tender
    func awardTender(tenderId: String, winningBidId: String, contractDuration: String, contractStartDate: String, contractEndDate: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/award_tender"
        let params: [String: String] = ["tender_id": tenderId, "winning_bid_id": winningBidId, "contract_duration": contractDuration, "contract_start_date": contractStartDate, "contract_end_date": contractEndDate]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Contract Management
    /// Get contracts
    func getContracts(userId: String?, companyId: String?, status: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/contracts"
        var params: [String: String] = [:]
        if let userId = userId { params["user_id"] = userId }
        if let companyId = companyId { params["company_id"] = companyId }
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get contract details
    func getContractDetails(contractId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/contract_details"
        let params: [String: String] = ["contract_id": contractId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get contract milestones
    func getContractMilestones(contractId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/contract_milestones"
        let params: [String: String] = ["contract_id": contractId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Update milestone status
    func updateMilestoneStatus(milestoneId: String, status: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/update_milestone_status"
        let params: [String: String] = ["milestone_id": milestoneId, "status": status]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Request contract amendment
    func requestContractAmendment(contractId: String, amendmentType: String, description: String, previousValue: String, newValue: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/request_contract_amendment"
        let params: [String: String] = ["contract_id": contractId, "amendment_type": amendmentType, "description": description, "previous_value": previousValue, "new_value": newValue]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Performance Tracking
    /// Get company performance metrics
    func getCompanyPerformanceMetrics(companyId: String, period: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/performance_metrics"
        let params: [String: String] = ["company_id": companyId, "period": period]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get KPI targets
    func getKPITargets(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/kpi_targets"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Set KPI target
    func setKPITarget(companyId: String, kpiName: String, targetValue: String, period: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/set_kpi_target"
        let params: [String: String] = ["company_id": companyId, "kpi_name": kpiName, "target_value": targetValue, "period": period]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get project performance
    func getProjectPerformance(companyId: String, projectId: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/project_performance"
        var params: [String: String] = ["company_id": companyId]
        if let projectId = projectId { params["project_id"] = projectId }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get employee performance
    func getEmployeePerformance(companyId: String, period: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/employee_performance"
        let params: [String: String] = ["company_id": companyId, "period": period]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Inventory Management
    /// Get inventory items
    func getInventoryItems(companyId: String, category: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/inventory_items"
        var params: [String: String] = ["company_id": companyId]
        if let category = category { params["category"] = category }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Add inventory item
    func addInventoryItem(companyId: String, itemName: String, itemNameArabic: String, sku: String, category: String, quantity: String, unit: String, reorderLevel: String, unitPrice: String, location: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/add_inventory_item"
        let params: [String: String] = ["company_id": companyId, "item_name": itemName, "item_name_arabic": itemNameArabic, "sku": sku, "category": category, "quantity": quantity, "unit": unit, "reorder_level": reorderLevel, "unit_price": unitPrice, "location": location]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Record inventory transaction
    func recordInventoryTransaction(itemId: String, companyId: String, transactionType: String, quantity: String, unitPrice: String, reference: String?, notes: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/record_inventory_transaction"
        var params: [String: String] = ["item_id": itemId, "company_id": companyId, "transaction_type": transactionType, "quantity": quantity, "unit_price": unitPrice]
        if let reference = reference { params["reference"] = reference }
        if let notes = notes { params["notes"] = notes }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get stock alerts
    func getStockAlerts(companyId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/stock_alerts"
        let params: [String: String] = ["company_id": companyId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create purchase order
    func createPurchaseOrder(companyId: String, supplierId: String, expectedDelivery: String, items: [[String: String]], completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/create_purchase_order"
        var params: [String: String] = ["company_id": companyId, "supplier_id": supplierId, "expected_delivery": expectedDelivery]
        for (index, item) in items.enumerated() {
            for (key, value) in item {
                params["item\(index + 1)_\(key)"] = value
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Audit Logs
    /// Get audit logs
    func getAuditLogs(userId: String?, entityType: String?, dateFrom: String?, dateTo: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/audit_logs"
        var params: [String: String] = ["page_no": pageNo]
        if let userId = userId { params["user_id"] = userId }
        if let entityType = entityType { params["entity_type"] = entityType }
        if let dateFrom = dateFrom { params["date_from"] = dateFrom }
        if let dateTo = dateTo { params["date_to"] = dateTo }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get security events
    func getSecurityEvents(severity: String?, resolved: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/security_events"
        var params: [String: String] = ["page_no": pageNo]
        if let severity = severity { params["severity"] = severity }
        if let resolved = resolved { params["resolved"] = resolved }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get data changes
    func getDataChanges(auditLogId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/data_changes"
        let params: [String: String] = ["audit_log_id": auditLogId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Generate compliance report
    func generateComplianceReport(reportType: String, period: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/generate_compliance_report"
        let params: [String: String] = ["report_type": reportType, "period": period]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Resolve security event
    func resolveSecurityEvent(eventId: String, resolution: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Admin/resolve_security_event"
        let params: [String: String] = ["event_id": eventId, "resolution": resolution]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Equipment Rental
    /// Get available equipment
    func getAvailableEquipment(companyId: String?, category: String?, location: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/available_equipment"
        var params: [String: String] = [:]
        if let companyId = companyId { params["company_id"] = companyId }
        if let category = category { params["category"] = category }
        if let location = location { params["location"] = location }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Rent equipment
    func rentEquipment(userId: String, equipmentId: String, rentalType: String, startDate: String, endDate: String, deliveryAddress: String, notes: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/rent_equipment"
        var params: [String: String] = ["user_id": userId, "equipment_id": equipmentId, "rental_type": rentalType, "start_date": startDate, "end_date": endDate, "delivery_address": deliveryAddress]
        if let notes = notes { params["notes"] = notes }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get equipment rentals
    func getEquipmentRentals(userId: String?, companyId: String?, status: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/equipment_rentals"
        var params: [String: String] = [:]
        if let userId = userId { params["user_id"] = userId }
        if let companyId = companyId { params["company_id"] = companyId }
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Schedule equipment maintenance
    func scheduleEquipmentMaintenance(equipmentId: String, maintenanceType: String, scheduledDate: String, notes: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/schedule_equipment_maintenance"
        let params: [String: String] = ["equipment_id": equipmentId, "maintenance_type": maintenanceType, "scheduled_date": scheduledDate, "notes": notes]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Task Management
    /// Get project tasks
    func getProjectTasks(projectId: String, status: String?, assignedTo: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/project_tasks"
        var params: [String: String] = ["project_id": projectId]
        if let status = status { params["status"] = status }
        if let assignedTo = assignedTo { params["assigned_to"] = assignedTo }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create task
    func createTask(projectId: String, title: String, description: String, assignedTo: String, priority: String, dueDate: String, estimatedHours: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/create_task"
        let params: [String: String] = ["project_id": projectId, "title": title, "description": description, "assigned_to": assignedTo, "priority": priority, "due_date": dueDate, "estimated_hours": estimatedHours]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Update task status
    func updateTaskStatus(taskId: String, status: String, completionPercentage: String?, actualHours: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/update_task_status"
        var params: [String: String] = ["task_id": taskId, "status": status]
        if let completionPercentage = completionPercentage { params["completion_percentage"] = completionPercentage }
        if let actualHours = actualHours { params["actual_hours"] = actualHours }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Add task comment
    func addTaskComment(taskId: String, userId: String, comment: String, attachments: [Data]?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/add_task_comment"
        var params: [String: String] = ["task_id": taskId, "user_id": userId, "comment": comment]
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
    
    /// Get task comments
    func getTaskComments(taskId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/task_comments"
        let params: [String: String] = ["task_id": taskId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Invoicing
    /// Get invoices
    func getInvoices(userId: String?, companyId: String?, status: String?, pageNo: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/invoices"
        var params: [String: String] = ["page_no": pageNo]
        if let userId = userId { params["user_id"] = userId }
        if let companyId = companyId { params["company_id"] = companyId }
        if let status = status { params["status"] = status }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get invoice details
    func getInvoiceDetails(invoiceId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/invoice_details"
        let params: [String: String] = ["invoice_id": invoiceId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Create invoice
    func createInvoice(companyId: String, userId: String, dueDate: String, items: [[String: String]], taxRate: String?, discountAmount: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/create_invoice"
        var params: [String: String] = ["company_id": companyId, "user_id": userId, "due_date": dueDate]
        if let taxRate = taxRate { params["tax_rate"] = taxRate }
        if let discountAmount = discountAmount { params["discount_amount"] = discountAmount }
        for (index, item) in items.enumerated() {
            for (key, value) in item {
                params["item\(index + 1)_\(key)"] = value
            }
        }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Record invoice payment
    func recordInvoicePayment(invoiceId: String, amount: String, paymentMethod: String, transactionId: String?, notes: String?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/record_invoice_payment"
        var params: [String: String] = ["invoice_id": invoiceId, "amount": amount, "payment_method": paymentMethod]
        if let transactionId = transactionId { params["transaction_id"] = transactionId }
        if let notes = notes { params["notes"] = notes }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Send payment reminder
    func sendPaymentReminder(invoiceId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Vendor/send_payment_reminder"
        let params: [String: String] = ["invoice_id": invoiceId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Customer Portal
    /// Get customer dashboard
    func getCustomerDashboard(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/customer_dashboard"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get customer project status
    func getCustomerProjectStatus(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/customer_project_status"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Get customer documents
    func getCustomerDocuments(userId: String, documentType: String?, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/customer_documents"
        var params: [String: String] = ["user_id": userId]
        if let documentType = documentType { params["document_type"] = documentType }
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Update customer preferences
    func updateCustomerPreferences(userId: String, preferences: [String: String], completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/update_customer_preferences"
        var params = preferences
        params["user_id"] = userId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get customer preferences
    func getCustomerPreferences(userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/customer_preferences"
        let params: [String: String] = ["user_id": userId]
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
