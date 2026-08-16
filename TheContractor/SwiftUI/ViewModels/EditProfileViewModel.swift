//
//  EditProfileViewModel.swift
//  TheContractor
//
//  ViewModel for editing user profile
//

import SwiftUI
import Combine
import SwiftyJSON

class EditProfileViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var email = ""
    /// The city's **id** and the category's **title** — the asymmetry is Android's, and the backend's:
    /// `UpdateProfile` sets `selectedCity = citiesList.get(i).getId()` but
    /// `selectedCategory = categoriesList.get(i).getTitle()`, and prefills them from `city_id` and
    /// `cv_job_category`. Both default to `"0"` there, so an untouched picker sends `"0"`, not "".
    @Published var selectedCity = "0"
    @Published var address = ""
    @Published var selectedCategory = "0"

    /// Real cities and categories, replacing two hardcoded arrays that were invented outright — the
    /// city list did not carry ids at all, so nothing it produced could have been saved correctly.
    /// `Home/get_search` is the same source the company search filter uses.
    @Published var cities: [CityViewModel] = []
    @Published var categories: [CategoryViewModel] = []
    @Published var availableForJob = false
    /// Android's `cbFreelancer`, and a live switch rather than a local flag: each tap calls
    /// `freelancing/update_user_freelance_status` and follows the state the response reports back,
    /// reverting on failure exactly as `UpdateProfile` does.
    @Published var isAvailableAsFreelancer = false
    @Published var isUpdatingFreelanceStatus = false
    @Published var freelanceNotice: String?
    @Published var isCheckingFreelancerRecord = false
    /// Set when the freelancer form should open; the value says whether a record already exists.
    @Published var openFreelancerForm = false
    @Published var videoName = ""
    @Published var cvName = ""
    @Published var errorMessage = ""
    @Published var successMessage = ""
    @Published var isUpdating = false
    @Published var showImagePicker = false
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !phone.isEmpty
    }
    
    func loadCurrentUserInfo() {
        if let user = UserDefaultsManager.shared.userInfo {
            firstName = user.name
            lastName = user.surname
            phone = user.phone
            // The field used to render blank on an account that has an email, and anything typed into
            // it was thrown away because the update read the stored value instead.
            email = user.email
            isAvailableAsFreelancer = user.isAvailableAsFreelance == "1"
            address = user.address
            selectedCity = user.cityId.isEmpty ? "0" : user.cityId
            selectedCategory = user.cvJobCategory.isEmpty ? "0" : user.cvJobCategory
        }
        loadPickerData()
    }

    /// Cities and categories for the two pickers. A failure leaves them empty rather than surfacing an
    /// error: the pickers degrade to showing the stored value, and saving still round-trips it intact,
    /// which is the behaviour that matters here.
    private func loadPickerData() {
        guard cities.isEmpty || categories.isEmpty else { return }
        LoginService.shared().getSearchData(params: nil) { [weak self] _, success, search in
            guard success, let search = search else { return }
            DispatchQueue.main.async {
                self?.cities = search.cities.cityList
                self?.categories = search.categories.categoryList
            }
        }
    }

    /// What the city picker shows: the stored id resolved to a name, or a plain prompt.
    var selectedCityName: String {
        cities.first { $0.id == selectedCity }?.name ?? ""
    }

    // MARK: - Freelancing

    func toggleFreelanceAvailability() {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            errorMessage = "User not logged in"
            return
        }

        let wanted = !isAvailableAsFreelancer
        isAvailableAsFreelancer = wanted          // optimistic, reverted below if the call fails
        isUpdatingFreelanceStatus = true

        GCD.async(.Background) {
            LoginService.shared().updateUserFreelanceStatus(userId: user.id,
                                                           userType: user.userType.isEmpty ? "users" : user.userType,
                                                           isAvailable: wanted) { [weak self] message, success, json in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isUpdatingFreelanceStatus = false
                    guard success else {
                        self.isAvailableAsFreelancer = !wanted
                        self.errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    // Follow what the server says rather than what was tapped — the endpoint decides
                    // the resulting state itself and ignores `isChecked`, so the optimistic flip above
                    // has to be corrected here.
                    //
                    // The key is `available`, not `isAvailable`: Android reads it through Gson from a
                    // model whose getter is `isAvailable()`, which maps to the JSON key `available`.
                    // Looking for `isAvailable` found nothing and left the optimistic value in place,
                    // so the checkbox could say "available" while the alert said the opposite.
                    if let json = json {
                        let flag = json["available"].exists() ? json["available"] : json["isAvailable"]
                        if flag.exists() {
                            self.isAvailableAsFreelancer = flag.boolValue
                                || flag.stringValue == "1"
                                || flag.stringValue == "true"
                        }
                    }
                    var stored = user
                    stored.isAvailableAsFreelance = self.isAvailableAsFreelancer ? "1" : "0"
                    UserDefaultsManager.shared.userInfo = stored
                    Global.shared.user = stored
                    self.freelanceNotice = message.isEmpty
                        ? (self.isAvailableAsFreelancer ? "You are listed as available." : "You are no longer listed.")
                        : message
                }
            }
        }
    }

    /// Android checks for an existing freelancer record before opening the form, so the form knows
    /// whether it is adding or updating. Either way the form opens; only the mode differs.
    func openFreelancerProfile() {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            errorMessage = "User not logged in"
            return
        }

        isCheckingFreelancerRecord = true
        GCD.async(.Background) {
            LoginService.shared().getUserFreelancerRecord(userId: user.id) { [weak self] message, success, hasRecord, json in
                GCD.async(.Main) {
                    guard let self = self else { return }
                    self.isCheckingFreelancerRecord = false
                    guard success else {
                        self.errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    self.hasFreelancerRecord = hasRecord
                    self.freelancerRecord = hasRecord ? json?["user_freelancer_details"] : nil
                    self.openFreelancerForm = true
                }
            }
        }
    }

    /// True once `freelancing/register_user_freelancer` reports a record; the form opens in update mode.
    @Published var hasFreelancerRecord = false
    /// The record itself, handed to the form so an existing profile arrives filled in rather than blank.
    @Published var freelancerRecord: JSON?
    
    func updateProfile(completion: @escaping () -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill all fields"
            return
        }
        
        guard let storedUser = UserDefaultsManager.shared.userInfo, !storedUser.id.isEmpty else {
            errorMessage = "User not logged in"
            return
        }
        let userId = storedUser.id

        isUpdating = true
        errorMessage = ""
        successMessage = ""
        
        // Android: Account/update_user_profile. Home/update_user_profile does not exist, and the
        // `name` / `phone` parts were never read — they are user_name / user_phone.
        let params = [
            "user_id": userId,
            "user_name": firstName,
            "surname": lastName,
            "user_phone": phone,
            "user_email": email.isEmpty ? (UserDefaultsManager.shared.userInfo?.email ?? "") : email,
            // These four used to be sent as empty strings, and the backend wrote them straight over the
            // stored values — so saving a name change silently erased the user's address, city and job
            // category. `country` is hardcoded "2" exactly as Android does; the app is UAE-only and no
            // screen collects a country.
            "address": address,
            "city": selectedCity,
            "country": storedUser.countryId.isEmpty ? "2" : storedUser.countryId,
            "job_category": selectedCategory
        ]

        let completeURL = "https://contractor.bidcont.com/rest/Account/update_user_profile"
        LoginService.shared().makePostAPICall(with: completeURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                self?.isUpdating = false
                
                if success {
                    // Update local user info
                    if var user = UserDefaultsManager.shared.userInfo {
                        user.name = self?.firstName ?? ""
                        user.surname = self?.lastName ?? ""
                        user.phone = self?.phone ?? ""
                        UserDefaultsManager.shared.userInfo = user
                    }
                    
                    self?.successMessage = "Profile updated successfully"
                    completion()
                } else {
                    self?.errorMessage = message ?? "Failed to update profile"
                }
            }
        }
    }
}
