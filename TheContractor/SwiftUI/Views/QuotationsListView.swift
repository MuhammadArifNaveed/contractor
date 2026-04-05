//
//  QuotationsListView.swift
//  TheContractor
//
//  Quotations list screen matching Android Quotations activity
//

import SwiftUI

struct QuotationsListView: View {
    @StateObject private var viewModel = QuotationsListViewModel()
    @State private var showSubmitQuotation = false
    
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Quotations")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showSubmitQuotation = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal, 4)
            .frame(height: 56)
            .background(yellow)

        ZStack {
            if viewModel.isLoading && viewModel.quotations.isEmpty {
                LoadingView(message: "Loading quotations...")
            } else if let error = viewModel.errorMessage, viewModel.quotations.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadQuotations()
                }
            } else if viewModel.quotations.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Quotations",
                    message: "You haven't requested any quotations yet."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.quotations.indices, id: \.self) { index in
                            QuotationCard(quotation: viewModel.quotations[index]) {
                                viewModel.selectQuotation(viewModel.quotations[index])
                            }
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            
                            if index == viewModel.quotations.count - 2 {
                                Color.clear
                                    .frame(height: 1)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded()
                                    }
                            }
                        }
                        
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top, AppTheme.Spacing.medium)
                }
                .background(AppTheme.Colors.background)
            }
        }
        .sheet(isPresented: $showSubmitQuotation) {
            SubmitQuotationView()
        }
        .onAppear {
            if viewModel.quotations.isEmpty {
                viewModel.loadQuotations()
            }
        }
        } // end VStack
        .navigationBarHidden(true)
    }
}

// MARK: - Quotation Card
struct QuotationCard: View {
    let quotation: QuotationModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text("Quotation #\(quotation.id)")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(status: quotation.status)
                }
                
                if !quotation.companyName.isEmpty {
                    Text(quotation.companyName)
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                if !quotation.description.isEmpty {
                    Text(quotation.description)
                        .font(AppTheme.Fonts.regular(13))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(quotation.dateTime, systemImage: "calendar")
                        .font(AppTheme.Fonts.regular(12))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.gray)
                }
            }
            .padding(AppTheme.Spacing.medium)
            .background(Color.white)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quotation Model
struct QuotationModel: Identifiable {
    let id: String
    let status: String
    let date: String
    let companyName: String
    let description: String
    let location: String
    let dateTime: String
    
    init() {
        self.id = ""
        self.status = "Pending"
        self.date = ""
        self.companyName = ""
        self.description = ""
        self.location = ""
        self.dateTime = ""
    }
    
    init(id: String, status: String, date: String, companyName: String = "", description: String = "", location: String = "", dateTime: String = "") {
        self.id = id
        self.status = status
        self.date = date
        self.companyName = companyName
        self.description = description
        self.location = location
        self.dateTime = dateTime
    }
}

// MARK: - Preview
struct QuotationsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuotationsListView()
        }
    }
}
