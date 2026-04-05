//  MyJobApplicationsView.swift
import SwiftUI

struct MyJobApplicationsView: View {
    @StateObject private var viewModel = MyJobApplicationsViewModel()
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                Text("My Applications").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4).frame(height: 56).background(yellow)
            ZStack {
                if viewModel.isLoading && viewModel.applications.isEmpty { LoadingView(message: "Loading...") }
                else if viewModel.applications.isEmpty { EmptyStateView(icon: "briefcase", title: "No Applications", message: "You haven't applied to any jobs") }
                else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.applications.indices, id: \.self) { i in
                                ApplicationCard(app: viewModel.applications[i])
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .onAppear { viewModel.loadApplications() }
        }
        .navigationBarHidden(true)
    }
}

struct ApplicationCard: View {
    let app: JobApplication
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(app.jobTitle).font(AppTheme.Fonts.semibold(16))
            Text(app.companyName).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
            HStack {
                Text(app.appliedDate).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                Spacer()
                Text(app.status).font(AppTheme.Fonts.medium(12)).foregroundColor(app.status == "Accepted" ? .green : .orange)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct JobApplication: Identifiable { let id, jobTitle, companyName, appliedDate, status: String }
