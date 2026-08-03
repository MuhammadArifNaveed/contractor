//
//  ComplaintsListView.swift
//  TheContractor
//
//  Complaints list screen matching Android Complaints activity
//

import SwiftUI

struct ComplaintsListView: View {
    /// Set by a row tap; drives the detail sheet.
    @State private var selectedComplaintId: String?
    @StateObject private var viewModel = ComplaintsListViewModel()
    @State private var showSubmitComplaint = false
    
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
                Text("Complaints")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showSubmitComplaint = true }) {
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
            if viewModel.isLoading && viewModel.complaints.isEmpty {
                LoadingView(message: "Loading complaints...")
            } else if let error = viewModel.errorMessage, viewModel.complaints.isEmpty {
                ErrorView(message: error) {
                    viewModel.loadComplaints()
                }
            } else if viewModel.complaints.isEmpty {
                EmptyStateView(
                    icon: "exclamationmark.bubble",
                    title: "No Complaints",
                    message: "You haven't submitted any complaints yet."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.small) {
                        ForEach(viewModel.complaints.indices, id: \.self) { index in
                            ComplaintCard(complaint: viewModel.complaints[index]) {
                                selectedComplaintId = viewModel.complaints[index].id
                            }
                            .padding(.horizontal, AppTheme.Spacing.medium)
                            
                            if index == viewModel.complaints.count - 2 {
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
        .sheet(isPresented: $showSubmitComplaint) {
            SubmitComplaintView()
        }
        .onAppear {
            if viewModel.complaints.isEmpty {
                viewModel.loadComplaints()
            }
        }
        } // end VStack
        .sheet(item: $selectedComplaintId) { id in
            ComplaintDetailView(complaintId: id)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Complaint Card
struct ComplaintCard: View {
    let complaint: ComplaintModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack {
                    Text("Complaint #\(complaint.id)")
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    StatusBadge(status: complaint.status)
                }
                
                if !complaint.companyName.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text(complaint.companyName)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                if !complaint.description.isEmpty {
                    Text(complaint.description)
                        .font(AppTheme.Fonts.regular(13))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(complaint.date, systemImage: "calendar")
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

// MARK: - Complaint Model
struct ComplaintModel: Identifiable {
    let id: String
    let companyName: String
    let description: String
    let date: String
    let status: String
    let response: String
    
    init() {
        self.id = ""
        self.companyName = ""
        self.description = ""
        self.date = ""
        self.status = "Pending"
        self.response = ""
    }
    
    init(id: String, companyName: String, description: String, date: String, status: String, response: String) {
        self.id = id
        self.companyName = companyName
        self.description = description
        self.date = date
        self.status = status
        self.response = response
    }
}

// MARK: - Preview
struct ComplaintsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComplaintsListView()
        }
    }
}
