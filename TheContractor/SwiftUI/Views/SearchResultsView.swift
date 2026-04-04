//
//  SearchResultsView.swift
//  TheContractor
//
//  Search results screen matching Android SearchResult activity
//

import SwiftUI
import SwiftyJSON

struct SearchResultsView: View {
    let categoryId: String
    let subCategoryIds: [String]
    let cityId: String
    let specialityIds: [String]
    let keyword: String
    let verified: Bool

    @Environment(\.presentationMode) var presentationMode
    @State private var companies: [CompanyViewModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCompany: CompanyViewModel?
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if isLoading {
                Spacer()
                ProgressView("Searching...")
                    .padding()
                Spacer()
            } else if let err = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text(err)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Retry") { fetchResults() }
                        .foregroundColor(Color(red: 242/255, green: 190/255, blue: 54/255))
                }
                .padding()
                Spacer()
            } else if companies.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No companies found.\nTry different filters.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(companies.indices, id: \.self) { index in
                            CompanyCard(company: companies[index]) {
                                selectedCompany = companies[index]
                                showDetail = true
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationBarHidden(true)
        .onAppear { fetchResults() }
        .sheet(isPresented: $showDetail) {
            if let company = selectedCompany {
                NavigationView {
                    CompanyDetailView(company: company)
                }
            }
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text("Search Results")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()

            if !companies.isEmpty {
                Text("\(companies.count) found")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.trailing, 16)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color(red: 242/255, green: 190/255, blue: 54/255))
    }

    // MARK: - API Call
    private func fetchResults() {
        isLoading = true
        errorMessage = nil

        var params: [String: Any] = [
            "category_id": categoryId,
            "city_id": cityId.isEmpty ? "" : cityId,
            "verified": verified ? "1" : "0",
            "keyword": keyword,
            "area_id": "0"
        ]

        if subCategoryIds.isEmpty {
            params["sub_category_id"] = "all"
        } else {
            params["sub_category_id"] = subCategoryIds.joined(separator: ",")
        }

        if !specialityIds.isEmpty {
            params["speciality_id"] = specialityIds.joined(separator: ",")
        }

        LoginService.shared().getSearchedCompanies(params: params) { message, success, result in
            DispatchQueue.main.async {
                isLoading = false
                if success, let result = result {
                    companies = result.companyList
                } else {
                    errorMessage = message.isEmpty ? "Failed to load results" : message
                }
            }
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(
            categoryId: "1",
            subCategoryIds: [],
            cityId: "",
            specialityIds: [],
            keyword: "",
            verified: false
        )
    }
}
