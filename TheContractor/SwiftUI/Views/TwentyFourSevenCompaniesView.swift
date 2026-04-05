//  TwentyFourSevenCompaniesView.swift
import SwiftUI
struct TwentyFourSevenCompaniesView: View {
    @StateObject private var viewModel = TwentyFourSevenCompaniesViewModel()
    @Environment(\.presentationMode) private var presentationMode
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)

    var body: some View {
        VStack(spacing: 0) {
            // Custom yellow top bar
            HStack(spacing: 0) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("24/7 Maintenance")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: 56)
            .background(yellow)

            ZStack {
                if viewModel.isLoading && viewModel.companies.isEmpty {
                    LoadingView(message: "Loading...")
                } else if viewModel.companies.isEmpty {
                    EmptyStateView(icon: "building.2", title: "No Companies", message: "No 24/7 companies available")
                } else {
                    List(viewModel.companies.indices, id: \.self) { i in
                        CompanyCard(company: viewModel.companies[i]) { viewModel.selectCompany(viewModel.companies[i]) }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationBarHidden(true)
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
