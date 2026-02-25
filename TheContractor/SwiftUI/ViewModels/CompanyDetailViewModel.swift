//
//  CompanyDetailViewModel.swift
//  TheContractor
//
//  ViewModel for Company Details screen
//

import SwiftUI
import Combine

class CompanyDetailViewModel: ObservableObject {
    @Published var company: CompanyViewModel
    
    init(company: CompanyViewModel) {
        self.company = company
    }
    
    func submitEnquiry() {
        // Navigate to enquiry form
        // TODO: Implement navigation to enquiry screen
        print("Submit enquiry for: \(company.company_name)")
    }
    
    func requestQuotation() {
        // Navigate to quotation request form
        // TODO: Implement navigation to quotation screen
        print("Request quotation from: \(company.company_name)")
    }
    
    func callCompany() {
        // Make phone call
        guard !company.login_email.isEmpty else { return }
        // TODO: Extract phone number from company data and make call
        print("Call company: \(company.company_name)")
    }
    
    func showAllReviews() {
        // Navigate to reviews screen
        // TODO: Implement navigation to reviews screen
        print("Show all reviews for: \(company.company_name)")
    }
}
