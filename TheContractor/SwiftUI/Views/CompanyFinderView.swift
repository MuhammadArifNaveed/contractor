//
//  CompanyFinderView.swift
//  TheContractor
//
//  Android's `CompanyFinder`, reached from the drawer's "Company Finder" item. Android pops a dialog
//  asking for a company name or ID, then hands the keyword to the activity, which POSTs
//  `Home/get_by_company_id` with a single `keyword` part. The keyword field is inline here instead of
//  behind a dialog, so the search can be refined without reopening the drawer.
//
//  Verified live: the response is `{ companies: [...], message, error }` with the same company record
//  shape the other company lists use, so `CompanyViewModel` and `CompanyCard` are reused as they are.
//  A keyword that matches nothing answers `{"message":"company not found.","error":true}` — that is an
//  empty result, not a failure, and is shown as such.
//
//  The drawer item used to open the filter search, which the bottom bar's Search tab already reaches;
//  `Home/get_by_company_id` had no caller at all.
//

import SwiftUI
import SwiftyJSON

struct CompanyFinderView: View {
    @State private var keyword = ""
    @State private var companies: [CompanyViewModel] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    @State private var errorMessage: String?
    @State private var selectedCompany: CompanyViewModel?
    @State private var showDetail = false

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Company Finder",
                         onBack: { presentationMode.wrappedValue.dismiss() })

            searchField

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)
                results
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDetail) {
            if let company = selectedCompany {
                NavigationView {
                    CompanyDetailView(company: company)
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: VendorTheme.Space.s) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(VendorTheme.textSecondary)

            TextField("Company name or ID", text: $keyword)
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit(search)

            if !keyword.isEmpty {
                Button(action: { keyword = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(VendorTheme.textSecondary)
                }
            }

            Button(action: search) {
                Text("Search")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.onAccent)
                    .padding(.horizontal, VendorTheme.Space.m)
                    .padding(.vertical, VendorTheme.Space.s)
                    .background(VendorTheme.accent)
                    .cornerRadius(VendorTheme.Radius.control)
            }
            .disabled(trimmedKeyword.isEmpty)
            .opacity(trimmedKeyword.isEmpty ? 0.5 : 1)
        }
        .padding(VendorTheme.Space.m)
        .background(VendorTheme.surface)
    }

    @ViewBuilder
    private var results: some View {
        if isLoading {
            ScrollView { VendorSkeletonList(rows: 4) }
        } else if let errorMessage = errorMessage {
            VendorEmptyState(icon: "exclamationmark.triangle",
                             title: "Search failed",
                             message: errorMessage,
                             actionTitle: "Try again",
                             action: search)
        } else if companies.isEmpty {
            VendorEmptyState(icon: "magnifyingglass",
                             title: hasSearched ? "No companies found" : "Find a company",
                             message: hasSearched
                                ? "Nothing matched \"\(trimmedKeyword)\". Try a different name or ID."
                                : "Enter a company name or ID to search.")
        } else {
            ScrollView {
                LazyVStack(spacing: VendorTheme.Space.s) {
                    ForEach(companies.indices, id: \.self) { index in
                        CompanyCard(company: companies[index]) {
                            selectedCompany = companies[index]
                            showDetail = true
                        }
                        .padding(.horizontal, VendorTheme.Space.m)
                    }
                }
                .padding(.vertical, VendorTheme.Space.m)
            }
        }
    }

    private var trimmedKeyword: String {
        keyword.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func search() {
        let term = trimmedKeyword
        guard !term.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        LoginService.shared().findCompanies(keyword: term) { message, success, list in
            DispatchQueue.main.async {
                isLoading = false
                hasSearched = true
                if success {
                    companies = list
                } else {
                    companies = []
                    // "company not found." is the backend's way of saying zero results; anything else
                    // is a real failure and gets the retry state.
                    if !message.lowercased().contains("not found") {
                        errorMessage = message.isEmpty ? "Failed to search companies" : message
                    }
                }
            }
        }
    }
}

struct CompanyFinderView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyFinderView()
    }
}
