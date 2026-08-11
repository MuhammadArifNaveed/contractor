
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
    // MARK: - Freelancing, consumer side

    /// Turn "available as a freelancer" on or off for the signed-in user. Android:
    /// `RetrofitApi.updateUserFreelanceStatus()` → `POST freelancing/update_user_freelance_status`.
    ///
    /// The flag part is spelled **`isChecked`**, camelCase, unlike every other part on this backend.
    /// The response carries the resulting state, which is what the checkbox should follow — Android
    /// reverts its checkbox on any failure rather than assuming the tap won.
    func updateUserFreelanceStatus(userId: String, userType: String, isAvailable: Bool,
                                   completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/update_user_freelance_status"
        let params: [String: String] = [
            "user_id": userId,
            "user_type": userType,
            // A consumer sends its own id as `vendor_id` here, as it does on the workshop endpoints.
            "vendor_id": userId,
            "isChecked": isAvailable ? "true" : "false"
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Does this user already have a freelancer record, and what is in it? Android:
    /// `RetrofitApi.userFreelancerData()` → `POST freelancing/register_user_freelancer`, one part
    /// `user_id`.
    ///
    /// The endpoint name reads like a registration but it is a **read**: `UpdateProfile` calls it to
    /// decide whether to open the freelancer form in add or update mode. `status == "false"` means no
    /// record yet; otherwise the record comes back under `user_freelancer_details`. Saving the form is
    /// `freelancing/register_company_freelancer` / `update_company_freelancer`, which are shared with
    /// the company side — Android's `from=user` flag only relaxes validation, since a user's name,
    /// email and phone come from the account.
    func getUserFreelancerRecord(userId: String,
                                 completion: @escaping (_ message: String, _ success: Bool, _ hasRecord: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/register_user_freelancer"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            guard success, let json = json else {
                completion(message, false, false, nil)
                return
            }
            // Android reads `status` as a string here, not a boolean.
            let hasRecord = json["status"].stringValue != "false" && json["user_freelancer_details"].exists()
            completion(message, true, hasRecord, json)
        }
    }

    /// Read one account by id. Android: `RetrofitApi.getUserDetailById()` → `POST
    /// Account/get_user_details_by_id`, one part `user_id`, response key `user`.
    ///
    /// Chat is what needs this. Firestore keys a conversation on the participants' **uuids**, and a
    /// company opening a workshop ad only learns the owner's numeric `user_id` — no workshop endpoint
    /// returns a `uuid`. Android sidesteps that by reading the ad through `Vendor/workshop_ad_detail`,
    /// whose model carries `user_uuid`, `username`, `name` and `surname`; that endpoint is currently
    /// broken on the backend (`Call to undefined method Workshop_model::get_workshop_ad_detail_by_id()`),
    /// so this call supplies the same four values from the account itself.
    func getUserDetailsById(userId: String,
                            completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/get_user_details_by_id"
        let params: [String: String] = ["user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Chat notifications

    // Firestore carries the message; these two tell the backend to push it. Android fires one from each
    // chat screen the moment the `chat` document lands, and ignores the outcome — a failed push must not
    // fail a message that is already delivered — so both are fire-and-forget here too.
    //
    // The endpoint prefix follows the **caller**, not the recipient: the consumer's screen calls
    // `Home/...` to notify the company, the company's screen calls `vendor/...` to notify the user.
    // The message part is spelled **`meesage`** on both, which is the backend's own spelling.

    /// Consumer → company. Android: `Chat.sendNotification()` → `POST Home/send_message_notification`.
    /// `company_id` is misleadingly named: Android passes the company's **serial number**, not its id.
    func notifyCompanyOfChatMessage(message: String, companySerialNo: String) {
        let completeURL = EndPoints.BASE_URL + "Home/send_message_notification"
        let params: [String: String] = ["meesage": message, "company_id": companySerialNo]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { _, _, _ in }
    }

    /// Company → consumer. Android: `VendorChat.sendNotification()` →
    /// `POST vendor/send_message_notification`. Note `chatUDID`, not `chat_uuid`.
    func notifyUserOfChatMessage(message: String, userName: String, chatUUID: String, companySerialNo: String) {
        let completeURL = EndPoints.BASE_URL + "vendor/send_message_notification"
        let params: [String: String] = [
            "meesage": message,
            "username": userName,
            "chatUDID": chatUUID,
            "vendor_serial_no": companySerialNo
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { _, _, _ in }
    }

    // MARK: - Consumer sign-up

    /// Is this number free to register? Android: `POST Account/phone_check`, one part `user_phone`.
    ///
    /// `error:false` means the number is not taken. Android then sends its own SMS code through
    /// Firebase Phone Auth and only opens the details form once the code is confirmed. There is no
    /// server-side OTP endpoint — the SMS gate is entirely client-side, and iOS has no Firebase, so
    /// this check is the only gate before the form. `Account/user_register` accepts the number without
    /// any proof of ownership either way.
    func checkPhoneAvailability(phone: String,
                                completion: @escaping (_ message: String, _ available: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/phone_check"
        let params: [String: String] = ["user_phone": phone]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    /// Create a consumer account. Android: `POST Account/user_register`.
    ///
    /// Two details to keep: the surname part is `sur_name` here and `surname` on every other endpoint,
    /// and `country_id` is hardcoded `"1"` in Android's `Register.register()`.
    ///
    /// The response carries the new `user`, so the account is signed in from the registration response
    /// itself — Android does the same rather than making a second login call.
    func registerUser(username: String, firstName: String, lastName: String,
                      phone: String, email: String, password: String,
                      completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/user_register"
        let params: [String: String] = [
            "username": username,
            "user_name": firstName,
            "sur_name": lastName,
            "user_phone": phone,
            "user_email": email,
            "user_password": password,
            "country_id": "1",
            "device_type": "ios",
            "firebase_token": Global.shared.firebaseTokenForRequest
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json, json["user"].exists() {
                self.saveUserInfo(UserViewModel(json["user"]))
                Global.shared.isLogedIn = true
                Global.shared.isVendor = false
                Global.shared.loginType = "user"
                completion(message, true)
            } else {
                completion(message, false)
            }
        }
    }

    func getUserLogin(params:ParamsAny?,completion: @escaping (_ error: String, _ success: Bool)->Void) {
        let completeURL = EndPoints.BASE_URL + EndPoints.login
        self.makePostAPICall(with: completeURL, params: params) { (message, success, json, responseType) in
            if success {
                let data = UserViewModel( json!["user"])
                self.saveUserInfo(data)
                Global.shared.isLogedIn = true
                Global.shared.isVendor = false
                Global.shared.loginType = "user"

                completion(message,true)
            }
            else{
              completion(message,false)
            }
        }
    }
    
    // MARK: - Company (Vendor) Login
    /// Login for company/vendor accounts.
    ///
    /// Mirrors Android's `VendorLogin.login()`: on `error == false` the `Vendor` object is copied
    /// into a slim session record and the caller navigates to the dashboard. On failure the JSON is
    /// handed back untouched so the caller can read `is_email_verified` — Android only offers the
    /// "resend verification email" dialog on the failure path.
    func loginCompany(email: String, pinCode: String, firebaseToken: String,
                     completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/login_company"
        let params: [String: String] = [
            "login_email": email,
            "login_password": pinCode,
            "device_type": "ios",
            "firebase_token": firebaseToken
        ]

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            guard success, let json = json, json["Vendor"].exists() else {
                completion(message, false, json)
                return
            }

            self.saveVendorSession(VendorSession(json["Vendor"]))
            completion(message, true, json)
        }
    }

    /// Persists the vendor session the way Android's `SharedPrefManager.vendorLogin()` does — only
    /// the handful of fields the app actually reads, never the password hash or verification tokens
    /// that `vendor/login_company` also returns.
    fileprivate func saveVendorSession(_ vendor: VendorSession) {
        if let data = try? JSONEncoder().encode(vendor) {
            UserDefaults.standard.set(data, forKey: "vendor")
        }
        UserDefaults.standard.set(true, forKey: "isLogedIn")
        UserDefaults.standard.set(true, forKey: "isVendor")
        UserDefaults.standard.set("company", forKey: "loginType")

        // SceneDelegate gates session restoration on this flag, so a company that skips it would
        // come back as a guest on the next cold launch.
        UserDefaultsManager.shared.isCompanyLoggedIn = true
        UserDefaultsManager.shared.loginType = "company"

        Global.shared.isLogedIn = true
        Global.shared.isVendor = true
        Global.shared.loginType = "company"

        // The drawer header and other shared UI read Global.shared.user, so mirror the company
        // into it the way Android reuses its nav header for both account types.
        var user = UserViewModel()
        user.id = vendor.id
        user.name = vendor.company_name
        user.phone = vendor.company_phone
        user.userType = vendor.user_type.isEmpty ? "companies" : vendor.user_type
        Global.shared.user = user
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
        // Android's part is `login_email`; `email` was silently ignored, so no pin was ever sent.
        let params: [String: String] = ["login_email": email]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Step 2: Verify reset pin code
    func vendorForgotPasswordVerifyPin(email: String, pin: String,
                                       completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/reset_pin_check"
        let params: [String: String] = ["login_email": email, "pin": pin]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Step 3: Update vendor password
    func vendorUpdatePassword(email: String, password: String,
                            completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/update_password"
        let params: [String: String] = ["password": password, "login_email": email]

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    /// Resend vendor verification email
    func resendVendorVerificationEmail(email: String,
                                      completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/resent_company_email_verification_mail"
        let params: [String: String] = ["email": email]

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
        // Android's parts are user_name / surname / user_phone / user_email; the previous
        // first_name / last_name / phone / email were all silently discarded, so every enquiry
        // arrived with a user id and a company list and nothing else.
        let params: [String: String] = [
            "user_id": userId,
            "user_name": firstName,
            "surname": lastName,
            "user_phone": phone,
            "user_email": email,
            "companies": companiesJSON
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Get enquiries list for user
    
    /// Get enquiry detail
    /// Android: `RetrofitApi.enquiryDetail()` — the parts are `id` and `user_id`, not `enquiry_id`.
    func getEnquiryDetail(enquiryId: String, userId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/enquiry_detail"
        let params: [String: String] = ["id": enquiryId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Quotations
    /// Submit quotation request
    
    /// Get quotations list
    
    /// Get quotation detail
    
    // MARK: - Quotation By Photo
    /// Fetch all categories with their sub-categories
    func getCategoriesWithSubCategories(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/categories_with_sub_categories"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    /// Submit quotation by photo with optional images.
    ///
    /// Android: `RetrofitApi.requestQuotation()` → `POST Home/request_a_quotation`. This previously
    /// posted to `Home/request_quotation` with invented part names (`firstName`, `detail`,
    /// `category_id` …), none of which the backend declares, so every submission 404'd.
    func requestQuotationByPhoto(userId: String, firstName: String, lastName: String, phone: String,
                                  email: String, detail: String, categoryId: String, subCategoryId: String,
                                  images: [Data]?,
                                  completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/request_a_quotation"
        let params: [String: String] = [
            "user_id": userId,
            "user_name": firstName,
            "surname": lastName,
            "user_phone": phone,
            "user_email": email,
            "message": detail,
            "category": categoryId,
            "sub_category": subCategoryId
        ]
        var imageDict: [String: Data] = [:]
        if let images = images {
            for (index, imageData) in images.enumerated() {
                imageDict["images[\(index)]"] = imageData
            }
        }
        let hasImages = !imageDict.isEmpty
        self.makePostAPICallWithMultipart(with: completeURL, dict: hasImages ? imageDict : nil, params: params, isImageData: hasImages) { message, success, json in
            completion(message, success)
        }
    }
    
    // MARK: - Complaints
    /// Submit complaint with optional images
    
    /// Get complaints list
    
    /// Get complaint detail
    
    // MARK: - Profile Management
    /// Change user password
    /// Android: `RetrofitApi.changePassword()` — keyed on `user_email`, not `user_id`.
    func changePassword(userEmail: String, oldPassword: String, newPassword: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/change_password"
        let params: [String: String] = ["user_email": userEmail, "old_password": oldPassword, "new_password": newPassword]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }
    
    /// Set a new password after a forgotten-password phone verification. Android:
    /// `RetrofitApi.newPassword()` → `POST Account/update_password`, parts `new_password` and
    /// `user_phone`.
    ///
    /// **The endpoint asks for no proof of anything** — a phone number and a new password is the whole
    /// request, so whoever calls it can take over any account whose number they know. Android's gate is
    /// Firebase phone verification in `ForgotPassword`, entirely client-side, and `ForgotPasswordView`
    /// is the same gate here. Nothing stops the endpoint being called directly on either platform; this
    /// closes the app's door only.
    func resetPassword(phone: String, newPassword: String,
                       completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Account/update_password"
        let params: [String: String] = ["new_password": newPassword, "user_phone": phone]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    /// Update user profile with optional image
    
    // MARK: - Estimations
    /// The categories the estimate calculator is built from. Android: `POST
    /// Home/get_estimation_categories`, no parts. Responds under `estimation_categories`, each with a
    /// nested `sub_categories` array whose `min_val` is the price per square foot.
    func getEstimationCategories(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/get_estimation_categories"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Ask for a free consultation on a calculated estimate. Android: `POST
    /// Home/submit_estimate_request`.
    ///
    /// The two id parts read backwards: `look_id` is the **top-level** category (what the user is
    /// "looking for") and `cate_id` is the sub-category chosen underneath it. That is how
    /// `EstimationFragment.requestEstimation()` passes them, and it matches the response, which names
    /// them `looking_for` and `category_name`. The calculated budget is not sent — the server holds
    /// the per-sqft price and works it out again.
    func submitEstimateRequest(userId: String, fullName: String, phone: String, email: String,
                               note: String, squareFeet: String, lookId: String, categoryId: String,
                               completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/submit_estimate_request"
        let params: [String: String] = [
            "user_id": userId,
            "full_name": fullName,
            "phone_number": phone,
            "email_address": email,
            "note": note,
            "est_enter_sqft": squareFeet,
            "look_id": lookId,
            "cate_id": categoryId
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    /// The signed-in user's own estimate requests, paged. Android: `POST Home/estimation_requests`,
    /// responding under `requests` with `total_page`.
    func getEstimationRequests(userId: String, page: Int,
                               completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/estimation_requests"
        let params: [String: String] = ["user_id": userId, "page": "\(page)"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One estimate request. Android: `POST Home/estimation_request`, responding under
    /// `estimation_request_detail`.
    func getEstimationRequestDetail(requestId: String, userId: String,
                                    completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/estimation_request"
        let params: [String: String] = ["id": requestId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }


    // MARK: - Search & Filter
    /// Search companies with filters
    
    /// Search freelancers with filters
    
    /// Search workshops with filters
    
    // MARK: - Workshops
    /// Get all workshops
    
    /// Get workshop detail
    
    /// Enroll in workshop
    
    /// Get user workshop enrollments
    
    // MARK: - Vendor Dashboard
    /// Get vendor dashboard stats
    func getVendorDashboard(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        // Matches Android's RetrofitApi.vendorDashboard(): POST vendor/dashboard, vendor_id part.
        let completeURL = EndPoints.BASE_URL + "vendor/dashboard"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }
    
    // MARK: - Vendor Enquiries
    /// Every enquiry status with its count — the "Enquiries" drawer screen.
    /// Android: `RetrofitApi.vendorEnquiriesStatus()`, response key `vendor_dashboard_counts`.
    func getVendorEnquiryStatuses(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/enquiries_status"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The enquiries sitting in one status. `id` is the status id, not an enquiry id.
    /// Android: `RetrofitApi.vendorParticularEnquiries()` → `POST vendor/view`, key `vendor_enquiries`.
    func getVendorParticularEnquiries(statusId: String, vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/view"
        let params: [String: String] = ["id": statusId, "vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One enquiry in full. Android: `RetrofitApi.vendorParticularEnquiryDetail()` → `POST vendor/enquiry`.
    func getVendorEnquiryDetail(enquiryId: String, vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/enquiry"
        let params: [String: String] = ["id": enquiryId, "vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Accept / progress an enquiry. Android: `RetrofitApi.updateEnquiryStatus()`.
    /// The response's `status` field comes back as `"reject"` when the chosen status needs a
    /// rejection reason, which is what drives Android's follow-up dialog.
    func updateVendorEnquiryStatus(enquiryId: String, vendorId: String, statusId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/update_enquiry_status"
        let params: [String: String] = ["enquiry_id": enquiryId, "vendor_id": vendorId, "status_id": statusId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Reject an enquiry with a reason. Android: `RetrofitApi.updateEnquiryRejectionStatus()`.
    func rejectVendorEnquiry(enquiryId: String, vendorId: String, statusId: String, reason: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/enquiry_rejection_reason"
        let params: [String: String] = ["enquiry_id": enquiryId, "vendor_id": vendorId, "status_id": statusId, "reason": reason]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    // MARK: - Vendor Quotations
    /// Every quotation status with its count — the "Quotations" drawer screen.
    /// Android: `RetrofitApi.vendorQuotationsStatus()`. The endpoint really is spelled
    /// `quotations_dashnoard` server-side; do not "fix" it.
    func getVendorQuotationStatuses(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/quotations_dashnoard"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The quotations sitting in one status. Android: `RetrofitApi.vendorParticularQuotations()`.
    func getVendorParticularQuotations(statusId: String, vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/quotations"
        let params: [String: String] = ["id": statusId, "vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One quotation in full. Android: `RetrofitApi.vendorParticularQuotationDetail()` — this one
    /// takes only `id`, no `vendor_id`.
    func getVendorQuotationDetail(quotationId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/quotation"
        let params: [String: String] = ["id": quotationId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Android: `RetrofitApi.updateQuotationStatus()`. Like the enquiry version, a `"reject"`
    /// response means the backend wants a reason first.
    func updateVendorQuotationStatus(quotationId: String, vendorId: String, statusId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/update_quotation_status"
        let params: [String: String] = ["quotation_id": quotationId, "vendor_id": vendorId, "status_id": statusId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Android: `RetrofitApi.updateQuotationRejectionStatus()`.
    func rejectVendorQuotation(quotationId: String, vendorId: String, statusId: String, reason: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/quotation_rejection_reason"
        let params: [String: String] = ["quotation_id": quotationId, "vendor_id": vendorId, "status_id": statusId, "reason": reason]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    /// Attach a document to a quotation. Android: `RetrofitApi.uploadDocument()` →
    /// `POST vendor/upload_document`, offered when the quotation is at status 2 or 5.
    func uploadQuotationDocument(quotationId: String, vendorId: String,
                                 fileData: Data, fileName: String, mimeType: String,
                                 completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/upload_document"
        let params: [String: String] = ["quotation_id": quotationId, "vendor_id": vendorId]
        self.makePostAPICallWithDocument(with: completeURL, params: params,
                                         fileData: fileData, fileName: fileName, mimeType: mimeType) { message, success, _ in
            completion(message, success)
        }
    }

    /// The category / city / type lists behind Android's applicant and job filters.
    /// Android: `RetrofitApi.jobDataAPI()` → `POST jobs/get_job_search_fields`.
    func getJobSearchFields(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/get_job_search_fields"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Lock or unlock a quotation on a workshop ad.
    /// Android: `RetrofitApi.updateWorkshopQuotationLock()` → `POST workshop/quotation_toggle_lock`.
    ///
    /// `chatEntryId` is the quotation's own id, and `action` is the literal `"lock"` / `"unlock"`
    /// — Android sends the word, not a flag (`WorkshopAdDetail.updateLockAPI`).
    func setWorkshopQuotationLock(quotationId: String, locked: Bool,
                                  completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/quotation_toggle_lock"
        let params: [String: String] = ["chatEntryId": quotationId, "action": locked ? "lock" : "unlock"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    // MARK: - Freelancers (vendor mode)
    /// Browse freelancers. Android: `RetrofitApi.freelancerApi()` →
    /// `POST freelancing/freelancers_frontend`, response key `freelancers`. Every filter may be
    /// empty; Android's vendor mode passes the company as both `vendor_id` and `user_id`.
    func getFreelancers(page: String, skills: String, rate: String, category: String, city: String,
                        userId: String, userType: String, vendorId: String,
                        completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/freelancers_frontend"
        let params: [String: String] = [
            "page": page, "skills": skills, "rate": rate, "category": category, "city": city,
            "user_id": userId, "user_type": userType, "vendor_id": vendorId
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The skill / rate / category / city lists behind the freelancer filter.
    /// Android: `RetrofitApi.freelancerDataAPI()` → `POST freelancing/get_freelancing_search`.
    func getFreelancerSearchFields(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/get_freelancing_search"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// What it costs to bring one freelancer out. Android: `RetrofitApi.transportationApi()`.
    func getFreelancerTransportationCharges(freelancerId: String, userId: String, userType: String,
                                            completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/transportation_charges"
        let params: [String: String] = ["freelancer_id": freelancerId, "user_id": userId, "user_type": userType]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Hire freelancers. Android: `RetrofitApi.hireFreelancerApi()` →
    /// `POST freelancing/hire_freelancers`.
    ///
    /// `freelancer_data` is a JSON *string* — Android sends `new Gson().toJson(list)` of its selected
    /// freelancers, each carrying a nested `detail` object with the booking. Pass the already-encoded
    /// JSON so the caller owns that shape.
    func hireFreelancers(freelancerDataJSON: String, userId: String, userType: String, vendorId: String,
                         completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/hire_freelancers"
        let params: [String: String] = [
            "freelancer_data": freelancerDataJSON,
            "user_id": userId,
            "user_type": userType,
            "vendor_id": vendorId
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    // MARK: - Post Workshop
    /// The three picker lists behind Android's post-workshop form.
    /// Android: `RetrofitApi.workshopFilterAPI()` → `POST workshop/workshop_filter_data`, returning
    /// `workshop_type`, `work_sector` (both `{title, value}`) and `freelancer_cities` (`{id, name}`).
    func getWorkshopFilterData(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/workshop_filter_data"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: [:], isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Post a new workshop ad. Android: `RetrofitApi.vendorPostWorkShopAdNewAPI()` →
    /// `POST workshop/submit_workshop_ad`.
    ///
    /// The images go up as repeated `images[]` parts — that is the name Android's
    /// `ImagePartFromUri.createPartFromUri(..., "images[]")` actually sends, despite the Retrofit
    /// signature calling the argument `surveyImage`.
    func submitWorkshopAd(vendorId: String, userId: String, userType: String,
                          bidType: String, workSector: String, workCity: String,
                          title: String, description: String, images: [Data],
                          completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/submit_workshop_ad"
        let params: [String: String] = [
            "vendor_id": vendorId,
            "user_id": userId,
            "user_type": userType,
            "bid_type": bidType,
            "work_sector": workSector,
            "work_city": workCity,
            "title": title,
            "description": description
        ]

        if images.isEmpty {
            self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
                completion(message, success)
            }
        } else {
            self.makePostAPICallWithImages(with: completeURL, params: params,
                                           images: images, partName: "images[]") { message, success, _ in
                completion(message, success)
            }
        }
    }

    // MARK: - Consumer quotation / complaint detail
    /// One of the signed-in user's own quotations. Android: `RetrofitApi.quotationDetail()` →
    /// `POST Home/quotation`.
    ///
    /// The response puts `quotation_price` and `symbol` at the **top level**, as siblings of
    /// `quotation` rather than inside it, so callers need all three.
    func getConsumerQuotationDetail(quotationId: String, userId: String,
                                    completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/quotation"
        let params: [String: String] = ["id": quotationId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One of the signed-in user's own complaints. Android: `POST Home/complaint`.
    func getConsumerComplaintDetail(complaintId: String, userId: String,
                                    completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "Home/complaint"
        let params: [String: String] = ["id": complaintId, "user_id": userId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Vendor Profile
    /// The company's own record. Android: `RetrofitApi.vendorProfile()` → `POST vendor/my_company`.
    ///
    /// The response key is `Vendor_profile` with a capital V, not the `vendor_profile` Android's
    /// model field implies — read what the server actually sends.
    func getVendorProfile(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/my_company"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Flip the company's online/offline flag. Android: `RetrofitApi.vendorIsOnline()`.
    /// `isOnline` goes over the wire as `"1"` / `"0"`.
    func setVendorOnline(vendorId: String, isOnline: Bool, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/is_online"
        let params: [String: String] = ["vendor_id": vendorId, "is_online": isOnline ? "1" : "0"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    // MARK: - Workshop detail
    /// Flip a workshop ad between enabled and disabled. Android: `RetrofitApi.updateWorkshopStatus()` →
    /// `POST workshop/toggle_workshop_status`, one part `workshop_id`. The endpoint decides the new
    /// state itself; nothing is sent to say which way to flip it.
    func toggleWorkshopStatus(workshopId: String,
                              completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/toggle_workshop_status"
        let params: [String: String] = ["workshop_id": workshopId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One workshop ad in full, including its images and the quotations placed on it.
    /// Android: `RetrofitApi.workshopAdDetails()` → `POST workshop/get_workshop_details`.
    func getWorkshopDetails(workshopId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/get_workshop_details"
        let params: [String: String] = ["workshop_id": workshopId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Place this company's quotation on a workshop ad.
    /// Android: `RetrofitApi.workshopsQuotation()` → `POST workshop/add_workshop_quotation`.
    ///
    /// The response's `action` field drives Android's follow-up: `"posted"` / `"failed"` /
    /// `"'invalid id"` just report the message, while `"need subscription"` and
    /// `"subscription expired"` raise a dialog instead.
    /// Note the part here is `workshop_id`, unlike `mark_workshop_interested` which wants
    /// `workshop_ad_id` for the same value.
    func addWorkshopQuotation(vendorId: String, userId: String, userType: String, workshopId: String,
                              price: String, message: String,
                              completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/add_workshop_quotation"
        let params: [String: String] = [
            "vendor_id": vendorId,
            "user_id": userId,
            "user_type": userType,
            "workshop_id": workshopId,
            "price": price,
            "message": message
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Vendor Rating
    /// The reviews customers left on this company. Android: `RetrofitApi.vendorRating()`,
    /// response key `rating_enquiries`.
    func getVendorRating(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/rating"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Vendor Memberships
    /// The plans on offer. Android: `RetrofitApi.vendorMembership()`, response key `memberships_list`.
    func getVendorMemberships(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/memberships"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The plans this company has bought. Android: `RetrofitApi.myMembership()`,
    /// response key `my_memberships`.
    func getVendorMyMemberships(vendorId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/my_memberships"
        let params: [String: String] = ["vendor_id": vendorId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Redeem a membership coupon. Android: `RetrofitApi.buyMembershipByCoupon()`.
    /// The card-payment sibling (`vendor/buy_membership_online`) needs a payment gateway and is
    /// deliberately not wired up here.
    func buyVendorMembershipByCoupon(vendorId: String, membershipId: String, couponCode: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "vendor/buy_membership_by_coupon"
        let params: [String: String] = ["vendor_id": vendorId, "membership_id": membershipId, "coupon_code": couponCode]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    // MARK: - Interested Workshops
    /// The workshop ads this company has bid on. Android: `RetrofitApi.interestedWorkshops()` →
    /// `POST workshop/workshop_my_page`, response keys `workshops` and `total_page`.
    /// `bidType` is `"open"` or `"close"` — Android's two tabs.
    func getInterestedWorkshops(vendorId: String, userId: String, userType: String, bidType: String, page: String,
                                completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/workshop_my_page"
        let params: [String: String] = [
            "vendor_id": vendorId,
            "user_id": userId,
            "user_type": userType,
            "bid_type": bidType,
            "page": page
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Vendor Jobs
    /// Job counts per status. Android: `RetrofitApi.vendorJobsStatus()` → `POST jobs/app_jobs_dashboard`,
    /// response key `vendor_dashboard_counts`.
    func getVendorJobsDashboard(vendorId: String, userId: String, userType: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/app_jobs_dashboard"
        let params: [String: String] = ["vendor_id": vendorId, "user_id": userId, "user_type": userType]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The jobs in one status. Android: `RetrofitApi.vendorJobListing()` → `POST jobs/jobs_listing`,
    /// response key `jobs_list`. `id` is the status id.
    func getVendorJobListing(statusId: String, vendorId: String, userId: String, userType: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/jobs_listing"
        let params: [String: String] = ["id": statusId, "vendor_id": vendorId, "user_id": userId, "user_type": userType]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// One job in full. Android: `RetrofitApi.vendorJobDetail()` → `POST jobs/view_job`,
    /// response key `job_details`. Keyed on `job_uuid`, not the numeric id.
    func getVendorJobDetail(jobUuid: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/view_job"
        let params: [String: String] = ["job_uuid": jobUuid]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Create or update a job posting. Android: `RetrofitApi.postJob()` / `updateJob()` —
    /// `POST jobs/post_job` and `POST jobs/update_job`, identical part lists except that the update
    /// adds `job_id`. Both accept an optional image part.
    ///
    /// Pass `jobId` to update, leave it nil to create.
    func saveVendorJob(jobId: String?,
                       title: String, arabicTitle: String,
                       vacancies: String, description: String, arabicDescription: String,
                       salary: String, categoryId: String, locationId: String, jobType: String,
                       deadline: String,
                       vendorId: String, userId: String, userType: String,
                       imageData: Data?,
                       completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + (jobId == nil ? "jobs/post_job" : "jobs/update_job")

        // Android's part name is "vaccancies" — the backend's spelling, not a typo to fix here.
        var params: [String: String] = [
            "title": title,
            "arabic_title": arabicTitle,
            "vaccancies": vacancies,
            "description": description,
            "arabic_description": arabicDescription,
            "salary": salary,
            "job_category": categoryId,
            "job_location": locationId,
            "job_type": jobType,
            "deadline": deadline,
            "vendor_id": vendorId,
            "user_id": userId,
            "user_type": userType
        ]
        if let jobId = jobId { params["job_id"] = jobId }

        if let imageData = imageData {
            self.makePostAPICallWithDocument(with: completeURL, params: params,
                                             fileData: imageData, fileName: "job.jpg",
                                             mimeType: "image/jpeg") { message, success, _ in
                completion(message, success)
            }
        } else {
            self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
                completion(message, success)
            }
        }
    }

    /// Android: `RetrofitApi.vendorUpdateJobPublishStatus()`. `check` is `"1"` / `"0"`.
    func setVendorJobPublished(jobId: String, published: Bool, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/toggle_job_publish"
        let params: [String: String] = ["job_id": jobId, "check": published ? "1" : "0"]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    /// Android: `RetrofitApi.vendorDelectJob()` (sic).
    func deleteVendorJob(jobId: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/delete_job"
        let params: [String: String] = ["job_id": jobId]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    // MARK: - Available Applicants
    /// Android: `RetrofitApi.availableApplicantApi()` → `POST jobs/search_applicants`,
    /// response keys `available_users` and `total_page`. `category` and `city` may be empty.
    func getAvailableApplicants(page: String, category: String, city: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/search_applicants"
        let params: [String: String] = ["page": page, "category": category, "city": city]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// The people who applied to one job. Android: `RetrofitApi.viewAppliesApi()` →
    /// `POST jobs/view_applies`, response key `job_applies`.
    func getVendorJobApplications(jobUuid: String, page: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/view_applies"
        let params: [String: String] = ["page": page, "job_uuid": jobUuid]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Everyone this company has hired directly, and where each of them is in the process.
    /// Android: `RetrofitApi.directHiringApi()` → `POST jobs/view_direct_hirings`, response key
    /// `direct_hirings`.
    ///
    /// The response carries no `total_page`, and Android's load-more is commented out in
    /// `VendorDirectHiring`, so `page` is sent but the list is single-page in practice.
    func getVendorDirectHirings(vendorId: String, userId: String, userType: String, page: String,
                                completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/view_direct_hirings"
        let params: [String: String] = [
            "page": page, "vendor_id": vendorId, "user_id": userId, "user_type": userType
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Move one direct hire along. Android: `RetrofitApi.updateDirectHireStatusApi()` →
    /// `POST jobs/update_direct_hiring_status` with `vendor_id`, `hiring_id`, `status`.
    ///
    /// `status` is one of Android's five literals, spelled as its own dialog spells them — including
    /// `interviewed` in lower case, which is what goes over the wire.
    func updateDirectHiringStatus(vendorId: String, hiringId: String, status: String,
                                  completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/update_direct_hiring_status"
        let params: [String: String] = ["vendor_id": vendorId, "hiring_id": hiringId, "status": status]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, _ in
            completion(message, success)
        }
    }

    /// Accept or reject one application. Android: `RetrofitApi.updateJobHireStatusApi()` →
    /// `POST jobs/update_job_application_status` with `vendor_id`, `application_id`, `status`.
    func updateVendorJobApplicationStatus(vendorId: String, applicationId: String, status: String,
                                          completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/update_job_application_status"
        let params: [String: String] = ["vendor_id": vendorId, "application_id": applicationId, "status": status]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    /// Hire an applicant directly. Android: `RetrofitApi.hireApplicantApi()` → `POST jobs/direct_hire`.
    func directHireApplicant(vendorId: String, userId: String, userType: String, applicantUuid: String, status: String,
                             completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/direct_hire"
        let params: [String: String] = [
            "vendor_id": vendorId,
            "user_id": userId,
            "user_type": userType,
            "applicant_uuid": applicantUuid,
            "status": status
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    // MARK: - Vendor Freelancing
    /// Freelancing counts. Android: `RetrofitApi.vendorFreelancerStatus()` →
    /// `POST freelancing/freelancing_dashboard`, response key `freelancing_dashboard`.
    func getVendorFreelancingDashboard(vendorId: String, userId: String, userType: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/freelancing_dashboard"
        let params: [String: String] = ["vendor_id": vendorId, "user_id": userId, "user_type": userType]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    // MARK: - Workshops (vendor side)
    /// This company's own workshop ads. Android: `RetrofitApi.workshopAds()` → `POST workshop/workshops`.
    func getVendorWorkshops(vendorId: String, userId: String, userType: String, bidType: String, page: String,
                            completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/workshops"
        let params: [String: String] = [
            "vendor_id": vendorId, "user_id": userId, "user_type": userType, "bid_type": bidType, "page": page
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Every open workshop ad the company could bid on. Android: `RetrofitApi.allWorkshopAds()` →
    /// `POST workshop/show_workshops_for_interest`.
    func getAllWorkshopsForInterest(vendorId: String, userId: String, userType: String, bidType: String, page: String,
                                    completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/show_workshops_for_interest"
        let params: [String: String] = [
            "vendor_id": vendorId, "user_id": userId, "user_type": userType, "bid_type": bidType, "page": page
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success, json)
        }
    }

    /// Register interest in a workshop ad. Android: `RetrofitApi.workshopMarkInterested()` — note the
    /// part is `workshop_ad_id`, not `workshop_id`.
    func markWorkshopInterested(vendorId: String, userId: String, userType: String, bidType: String, workshopAdId: String,
                                completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "workshop/mark_workshop_interested"
        let params: [String: String] = [
            "vendor_id": vendorId, "user_id": userId, "user_type": userType,
            "bid_type": bidType, "workshop_ad_id": workshopAdId
        ]
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            completion(message, success)
        }
    }

    
    /// Submit vendor quotation response
    
    // MARK: - Notifications
    /// Get user notifications
    
    /// Mark notification as read
    
    /// Update notification settings
    
    // MARK: - Reviews & Ratings
    /// Get company reviews
    
    /// Submit review with optional images
    
    /// Get company rating stats
    
    // MARK: - Memberships
    /// Get membership plans
    
    /// Get user membership
    
    /// Purchase membership
    
    // MARK: - Jobs Portal
    /// Get job listings
    
    /// Get job detail
    
    /// Apply for job with optional resume
    
    /// Get user job applications
    
    /// Create workshop with images
    
    /// Get workshop enrollments
    
    // MARK: - Documents
    /// Get documents
    
    /// Upload document
    
    /// Get company documents
    
    // MARK: - 24/7 Emergency Services
    /// Get emergency companies (24/7 available)
    
    /// Submit emergency request
    
    // MARK: - Freelancer Dashboard
    /// Get freelancer dashboard stats
    
    /// Get freelancer jobs
    
    /// Update freelancer profile with portfolio
    
    // MARK: - App Settings
    /// Get app settings
    
    /// Update app settings
    
    /// Get available languages
    
    /// Check app version
    
    // MARK: - Payments
    /// Get payment methods
    
    /// Process payment
    
    /// Get payment history
    
    // MARK: - Analytics
    /// Get user analytics
    
    /// Get company analytics
    
    /// Log activity
    
    // MARK: - Social Features
    /// Get social feed
    
    /// Create social post
    
    /// Like/Unlike post
    
    /// Get post comments
    
    /// Add comment
    
    // MARK: - Help & Support
    /// Get FAQs
    
    /// Create support ticket
    
    /// Get support tickets
    
    /// Get ticket messages
    
    /// Send ticket message
    
    // MARK: - Company Portfolio
    /// Get company portfolio
    
    /// Add portfolio item
    
    /// Get company gallery
    
    /// Upload gallery images
    
    // MARK: - Bookmarks/Favorites
    /// Get bookmarked companies
    
    /// Toggle company bookmark
    
    /// Get bookmarked workshops
    
    /// Toggle workshop bookmark
    
    /// Get bookmarked freelancers
    
    /// Toggle freelancer bookmark
    
    // MARK: - Recommendations
    /// Get recommended companies
    
    /// Get recommended workshops
    
    /// Get recommended freelancers
    
    // MARK: - Chat System
    /// Get chat conversations
    
    /// Get chat messages
    
    /// Send chat message
    
    /// Mark messages as read
    
    /// Update typing status
    
    // MARK: - Promotions
    /// Get active promotions
    
    /// Create promotion
    
    /// Claim promotion
    
    /// Get user promotions
    
    // MARK: - Certifications & Licenses
    /// Get company certifications
    
    /// Upload certification
    
    /// Get company licenses
    
    /// Upload license
    
    // MARK: - Insurance
    /// Get company insurance policies
    
    /// Upload insurance policy
    
    /// Submit insurance claim
    
    // MARK: - Advanced Filtering
    /// Search companies with advanced filters
    
    /// Search workshops with advanced filters
    
    /// Search freelancers with advanced filters
    
    /// Save filter
    
    /// Get saved filters
    
    // MARK: - Video Content
    /// Get company videos
    
    /// Upload video
    
    /// Like video
    
    /// Track video view
    
    // MARK: - Subscriptions
    /// Get subscription plans
    
    /// Subscribe to plan
    
    /// Get user subscription
    
    /// Cancel subscription
    
    /// Get subscription usage
    
    // MARK: - Referrals
    /// Get referral program details
    
    /// Get user referral code
    
    /// Apply referral code
    
    /// Get referral transactions
    
    /// Get referral leaderboard
    
    // MARK: - Geolocation
    /// Get nearby companies
    
    /// Get company service areas
    
    /// Add service area
    
    /// Track user location
    
    /// Check geofence
    
    // MARK: - Push Notifications
    /// Register device for push notifications
    
    /// Update push notification settings
    
    /// Get push notification history
    
    /// Send push notification
    
    // MARK: - QR Codes
    /// Generate QR code
    
    /// Scan QR code
    
    /// Get company QR codes
    
    /// Get QR scan analytics
    
    // MARK: - Barcode Scanner
    /// Scan barcode
    
    /// Add product with barcode
    
    /// Order material by barcode
    
    /// Get material orders
    
    // MARK: - Export & Reports
    /// Request export
    
    /// Get export requests
    
    /// Get report templates
    
    /// Generate dashboard report
    
    /// Download report
    
    // MARK: - Loyalty Program
    /// Get loyalty program details
    
    /// Get user loyalty account
    
    /// Get loyalty transactions
    
    /// Get loyalty rewards
    
    /// Redeem loyalty reward
    
    // MARK: - Vendor Ratings
    /// Get rating criteria
    
    /// Get detailed vendor rating
    
    /// Submit detailed rating
    
    /// Get vendor badges
    
    // MARK: - Service Requests
    /// Create service request
    
    /// Get service requests
    
    /// Get service proposals
    
    /// Submit service proposal
    
    /// Accept service proposal
    
    // MARK: - Admin Dashboard
    /// Get admin dashboard stats
    
    /// Get user activity logs
    
    /// Get pending approvals
    
    /// Approve/Reject item
    
    /// Get system health metrics
    
    /// Get revenue metrics
    
    // MARK: - Availability Calendar
    /// Get company availability
    
    /// Set company availability
    
    /// Get booking slots
    
    /// Book appointment
    
    /// Get user appointments
    
    // MARK: - Multi-Currency
    /// Get supported currencies
    
    /// Convert currency
    
    /// Set user currency preference
    
    /// Get exchange rates
    
    // MARK: - Dispute Resolution
    /// File dispute
    
    /// Get user disputes
    
    /// Get dispute messages
    
    /// Send dispute message
    
    /// Resolve dispute
    
    // MARK: - Tender Management
    /// Get active tenders
    
    /// Get tender details
    
    /// Submit tender bid
    
    /// Get tender bids
    
    /// Evaluate tender bid
    
    /// Award tender
    
    // MARK: - Contract Management
    /// Get contracts
    
    /// Get contract details
    
    /// Get contract milestones
    
    /// Update milestone status
    
    /// Request contract amendment
    
    // MARK: - Performance Tracking
    /// Get company performance metrics
    
    /// Get KPI targets
    
    /// Set KPI target
    
    /// Get project performance
    
    /// Get employee performance
    
    // MARK: - Inventory Management
    /// Get inventory items
    
    /// Add inventory item
    
    /// Record inventory transaction
    
    /// Get stock alerts
    
    /// Create purchase order
    
    // MARK: - Audit Logs
    /// Get audit logs
    
    /// Get security events
    
    /// Get data changes
    
    /// Generate compliance report
    
    /// Resolve security event
    
    // MARK: - Equipment Rental
    /// Get available equipment
    
    /// Rent equipment
    
    /// Get equipment rentals
    
    /// Schedule equipment maintenance
    
    // MARK: - Task Management
    /// Get project tasks
    
    /// Create task
    
    /// Update task status
    
    /// Add task comment
    
    /// Get task comments
    
    // MARK: - Invoicing
    /// Get invoices
    
    /// Get invoice details
    
    /// Create invoice
    
    /// Record invoice payment
    
    /// Send payment reminder
    
    // MARK: - Customer Portal
    /// Get customer dashboard
    
    /// Get customer project status
    
    /// Get customer documents
    
    /// Update customer preferences
    
    /// Get customer preferences
    
    // MARK: - Third-Party Integrations
    /// Get integrations
    
    /// Configure integration
    
    /// Get webhook events
    
    /// Get API logs
    
    // MARK: - Compliance Management
    /// Get compliance checklists
    
    /// Update compliance item
    
    /// Get regulatory requirements
    
    /// Report compliance violation
    
    // MARK: - Resource Planning
    /// Get available resources
    
    /// Allocate resource
    
    /// Get resource allocations
    
    /// Get resource forecast
    
    // MARK: - Communication Center
    /// Get announcements
    
    /// Create announcement
    
    /// Send bulk message
    
    /// Get newsletters
    
    /// Get email templates
    
    /// Get communication logs
    
    // MARK: - Vendor Onboarding
    /// Submit onboarding application
    
    /// Get onboarding applications
    
    /// Update onboarding status
    
    /// Get vendor verifications
    
    // MARK: - Quality Control
    /// Create quality inspection
    
    /// Get quality inspections
    
    /// Submit inspection finding
    
    /// Get quality standards
    
    // MARK: - Fleet Management
    /// Get fleet vehicles
    
    /// Add vehicle
    
    /// Assign vehicle
    
    /// Record vehicle maintenance
    
    /// Add fuel log
    
    // MARK: - Training Center
    /// Get training courses
    
    /// Enroll in course
    
    /// Get user enrollments
    
    /// Get course modules
    
    /// Submit assessment
    
    /// Get training certificates
    
    // MARK: - Expense Tracking
    /// Submit expense
    
    /// Get expenses
    
    /// Approve expense
    
    /// Get expense report
    
    // MARK: - Project Milestones
    /// Get project milestones
    
    /// Create milestone
    
    /// Update milestone progress
    
    /// Get project timeline
    
    // MARK: - Warranty Management
    /// Get warranties
    
    /// File warranty claim
    
    /// Get warranty claims
    
    /// Schedule warranty inspection
    
    // MARK: - Service History
    /// Get service history
    
    /// Add service record
    
    /// Get maintenance schedule
    
    /// Create service report
    
    /// Send service reminder
    
    // MARK: - Emergency Services
    /// Request emergency service
    
    /// Get emergency requests
    
    /// Respond to emergency
    
    /// Get emergency contacts
    
    /// Update emergency status
    
    // MARK: - Asset Management
    /// Get company assets
    
    /// Add asset
    
    /// Transfer asset
    
    /// Get asset depreciation
    
    /// Conduct asset audit
    
    /// Dispose asset
    
    // MARK: - Safety & Compliance
    /// Get safety trainings
    
    /// Enroll in safety training
    
    /// Conduct site inspection
    
    /// Report safety incident
    
    // MARK: - Material Procurement
    /// Get materials catalog
    
    /// Create procurement request
    
    /// Get suppliers
    
    /// Create purchase order
    
    // MARK: - Change Orders
    /// Submit change order
    
    /// Get change orders
    
    /// Create risk assessment
    
    // MARK: - Site Logistics
    /// Schedule delivery
    
    /// Record site access
    
    /// Deploy equipment
    
    /// Submit site report
    
    // MARK: - Progress Tracking
    /// Get project progress
    
    /// Update phase progress
    
    /// Add work log
    
    /// Upload progress photo
    
    // MARK: - Subcontractor Management
    /// Get subcontractors
    
    /// Create subcontractor agreement
    
    /// Submit subcontractor invoice
    
    /// Rate subcontractor performance
    
    // MARK: - Time & Attendance
    /// Record attendance
    
    /// Check out
    
    /// Submit timesheet
    
    /// Request leave
    
    // MARK: - Cost Estimation
    /// Create cost estimate
    
    /// Get budget variance
    
    /// Generate cost forecast
    
    // MARK: - Client Communication
    /// Schedule client meeting
    
    /// Submit client feedback
    
    /// Send project update
    
    /// Request client approval
    
    // NOTE: Old UIKit HomeViewModel removed - SwiftUI version makes direct API calls
    /*
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
    */
    
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

// MARK: - Vendor session

/// The subset of `vendor/login_company`'s `Vendor` object that the app keeps on disk.
///
/// Port of Android's `VendorSharedPrefModel` (see `VendorLogin.java:261-275`), which deliberately
/// copies ten fields out of the login response rather than storing the whole thing — the response
/// also carries the bcrypt password hash, `otp` and `verified_token`, none of which belong in
/// UserDefaults. `company_email` is the one addition Android doesn't have; iOS screens display it.
///
/// Encoded as a flat string dictionary so the existing
/// `JSONSerialization.jsonObject(with:) as? [String: Any]` readers keep working unchanged.
struct VendorSession: Codable {
    var id: String = ""
    var uuid: String = ""
    var company_serial_number: String = ""
    var company_name: String = ""
    var login_email: String = ""
    var company_email: String = ""
    var company_phone: String = ""
    var city_name: String = ""
    var company_address: String = ""
    var user_id: String = ""
    var user_type: String = ""

    init() {}

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.uuid = json["uuid"].stringValue
        self.company_serial_number = json["company_serial_number"].stringValue
        self.company_name = json["company_name"].stringValue
        self.login_email = json["login_email"].stringValue
        self.company_email = json["company_email"].stringValue
        self.company_phone = json["company_phone"].stringValue
        self.city_name = json["city_name"].stringValue
        self.company_address = json["company_address"].stringValue
        self.user_id = json["user_id"].stringValue
        self.user_type = json["user_type"].stringValue
    }

    /// The logged-in company's id, or `""` when no company is signed in. Every vendor endpoint
    /// needs this as its `vendor_id` part.
    static var currentVendorId: String {
        current?.id ?? ""
    }

    /// The stored session, if a company is signed in.
    static var current: VendorSession? {
        guard let data = UserDefaults.standard.data(forKey: "vendor") else { return nil }
        return try? JSONDecoder().decode(VendorSession.self, from: data)
    }
}
