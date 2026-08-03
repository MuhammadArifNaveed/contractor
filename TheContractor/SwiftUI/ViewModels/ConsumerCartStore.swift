//
//  ConsumerCartStore.swift
//  TheContractor
//
//  The consumer cart, replicating Android.
//
//  There is no cart endpoint. Android keeps the basket in a local SQLite table via its
//  `DatabaseHandler` and only talks to the server twice: `Home/check_cart_limit` to learn how many
//  companies the user's plan allows, and `Home/send_enquiries` to submit. The previous iOS code
//  called `Home/get_cart` and `Home/submit_order`, neither of which the backend serves.
//
//  Persistence here is UserDefaults rather than SQLite — the basket is a short list of ids and a few
//  strings per row, so a table would buy nothing.
//

import Foundation
import SwiftyJSON

/// One company in the basket, plus the per-company job details Android collects before submitting.
struct CartCompany: Codable, Identifiable, Equatable {
    let id: String
    var companyName: String
    var companyLogo: String
    var categoryName: String

    /// Collected per company on the cart screen; all four are required before submitting, matching
    /// `SelectedCompaniesAdapter`, which refuses to build the payload while any is blank.
    var dateTime: String = ""
    var location: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var description: String = ""

    var isReadyToSubmit: Bool {
        !dateTime.isEmpty && !location.isEmpty && !description.isEmpty
    }
}

final class ConsumerCartStore: ObservableObject {
    static let shared = ConsumerCartStore()

    private static let storageKey = "consumerCart"

    @Published private(set) var companies: [CartCompany] = []

    /// From `Home/check_cart_limit`. Android blocks submission while the basket exceeds
    /// `available_cart_limit` and tells the user how many to remove.
    @Published private(set) var cartLimit: Int = 0
    @Published private(set) var availableLimit: Int = 0

    private init() {
        load()
    }

    // MARK: - Basket

    var count: Int { companies.count }

    func contains(companyId: String) -> Bool {
        companies.contains { $0.id == companyId }
    }

    func add(_ company: CartCompany) {
        guard !contains(companyId: company.id) else { return }
        companies.append(company)
        save()
    }

    func remove(companyId: String) {
        companies.removeAll { $0.id == companyId }
        save()
    }

    func toggle(_ company: CartCompany) {
        contains(companyId: company.id) ? remove(companyId: company.id) : add(company)
    }

    func update(_ company: CartCompany) {
        guard let index = companies.firstIndex(where: { $0.id == company.id }) else { return }
        companies[index] = company
        save()
    }

    func clear() {
        companies = []
        save()
    }

    /// Android's rule: every row must be filled in, and the basket must fit the plan.
    var canSubmit: Bool {
        !companies.isEmpty
            && companies.allSatisfy { $0.isReadyToSubmit }
            && !exceedsLimit
    }

    var exceedsLimit: Bool {
        availableLimit > 0 && companies.count > availableLimit
    }

    /// How many the user must remove, phrased the way Android's `cartLimitIssue` label is.
    var overLimitBy: Int {
        max(0, companies.count - availableLimit)
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let stored = try? JSONDecoder().decode([CartCompany].self, from: data) else { return }
        companies = stored
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(companies) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    // MARK: - Server

    func refreshLimit(completion: (() -> Void)? = nil) {
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            completion?()
            return
        }
        GCD.async(.Background) {
            LoginService.shared().checkCartLimit(userId: userId) { _, success, limit, available in
                GCD.async(.Main) {
                    if success {
                        self.cartLimit = limit
                        self.availableLimit = available
                    }
                    completion?()
                }
            }
        }
    }

    /// The `companies` part of `Home/send_enquiries`: a JSON *string* holding an array of
    /// `{company_id, date_time, location, lat, lng, description}` — the shape Android produces with
    /// `new Gson().toJson(selectedCompaniesList)` of its `SelectedCompaniesResponseModel`.
    func companiesJSON() -> String? {
        let payload = companies.map { company -> [String: String] in
            [
                "company_id": company.id,
                "date_time": company.dateTime,
                "location": company.location,
                "lat": company.latitude,
                "lng": company.longitude,
                "description": company.description
            ]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Submits the basket as an enquiry and empties it on success. Android reads the contact details
    /// off the stored user rather than asking again.
    func submit(completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            completion("Sign in to send an enquiry", false)
            return
        }
        guard let json = companiesJSON() else {
            completion("Could not prepare the enquiry", false)
            return
        }

        GCD.async(.Background) {
            LoginService.shared().submitEnquiry(userId: user.id,
                                                firstName: user.name,
                                                lastName: user.surname,
                                                phone: user.phone,
                                                email: user.email,
                                                companiesJSON: json) { message, success in
                GCD.async(.Main) {
                    if success { self.clear() }
                    completion(message, success)
                }
            }
        }
    }
}
