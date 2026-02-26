//  CompaniesByCategoryView.swift
import SwiftUI
struct CompaniesByCategoryView: View {
    let category: CategoryViewModel
    @StateObject private var viewModel: CompaniesByCategoryViewModel
    init(category: CategoryViewModel) {
        self.category = category
        _viewModel = StateObject(wrappedValue: CompaniesByCategoryViewModel(category: category))
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.companies.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.companies.isEmpty { EmptyStateView(icon: "building.2", title: "No Companies", message: "No companies in this category") }
            else {
                List(viewModel.companies.indices, id: \.self) { i in
                    CompanyCard(company: viewModel.companies[i]) { viewModel.selectCompany(viewModel.companies[i]) }
                }
            }
        }
        .navigationTitle(category.name)
        .onAppear { viewModel.loadCompanies() }
    }
}
class CompaniesByCategoryViewModel: ObservableObject {
    let category: CategoryViewModel
    @Published var isLoading = false
    @Published var companies: [CompanyViewModel] = []
    init(category: CategoryViewModel) { self.category = category }
    func loadCompanies() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/companies_by_category", params: ["category_id": category.id]) { [weak self] _, success, json, _ in
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
