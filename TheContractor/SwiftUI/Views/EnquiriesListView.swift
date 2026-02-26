//
//  EnquiriesListView.swift
//  TheContractor
//
//  Enquiries list screen matching Android Enquiries activity
//

import SwiftUI

struct EnquiriesListView: View {
    @StateObject private var viewModel = EnquiriesListViewModel()
    @State private var showSubmitEnquiry = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.enquiries.isEmpty {
                LoadingView(message: "Loading enquiries...")
            } else if let error = viewModel.errorMessage, viewModel.enquiries.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadEnquiries()
                }
            } else if viewModel.enquiries.isEmpty {
                EmptyStateView(
                    icon: "envelope",
                    title: "No Enquiries",
                    message: "You haven't submitted any enquiries yet."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.enquiries.indices, id: \.self) { index in
                            EnquiryCard(enquiry: viewModel.enquiries[index]) {
                                viewModel.selectEnquiry(viewModel.enquiries[index])
                            }
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            
                            // Pagination trigger
                            if index == viewModel.enquiries.count - 2 {
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
        .navigationTitle("Enquiries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSubmitEnquiry = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showSubmitEnquiry) {
            SubmitEnquiryView()
        }
        .onAppear {
            if viewModel.enquiries.isEmpty {
                viewModel.loadEnquiries()
            }
        }
    }
}

// MARK: - Enquiry Card
struct EnquiryCard: View {
    let enquiry: EnquiryModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text("Enquiry #\(enquiry.id)")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(status: enquiry.status)
                }
                
                if !enquiry.companyName.isEmpty {
                    Text("Company: \(enquiry.companyName)")
                        .font(AppTheme.Fonts.regular(14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(enquiry.date, systemImage: "calendar")
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

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    
    private var badgeColor: Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return AppTheme.Colors.gray
        }
    }
    
    var body: some View {
        Text(status)
            .font(AppTheme.Fonts.medium(12))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeColor)
            .cornerRadius(12)
    }
}

// MARK: - Enquiry Model
struct EnquiryModel: Identifiable {
    let id: String
    let status: String
    let date: String
    let companyName: String
    let description: String
    let response: String
    
    init() {
        self.id = ""
        self.status = "Pending"
        self.date = ""
        self.companyName = ""
        self.description = ""
        self.response = ""
    }
    
    init(id: String, status: String, date: String, companyName: String = "", description: String = "", response: String = "") {
        self.id = id
        self.status = status
        self.date = date
        self.companyName = companyName
        self.description = description
        self.response = response
    }
}

// MARK: - Preview
struct EnquiriesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnquiriesListView()
        }
    }
}
