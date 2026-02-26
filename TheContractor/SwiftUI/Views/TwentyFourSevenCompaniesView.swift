//  TwentyFourSevenCompaniesView.swift
import SwiftUI
struct TwentyFourSevenCompaniesView: View {
    @StateObject private var viewModel = TwentyFourSevenCompaniesViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.companies.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.companies.isEmpty { EmptyStateView(icon: "building.2", title: "No Companies", message: "No 24/7 companies available") }
            else {
                List(viewModel.companies.indices, id: \.self) { i in
                    CompanyCard(company: viewModel.companies[i]) { viewModel.selectCompany(viewModel.companies[i]) }
                }
            }
        }
        .navigationTitle("24/7 Companies")
        .onAppear { viewModel.loadCompanies() }
    }
}
class TwentyFourSevenCompaniesViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var companies: [CompanyViewModel] = []
    func loadCompanies() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/get_24_7_companies", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["companies"].array {
                    self?.companies = arr.map { CompanyViewModel($0) }
                }
            }
        }
    }
    func selectCompany(_ company: CompanyViewModel) { print("Selected: \(company.company_name)") }
}
