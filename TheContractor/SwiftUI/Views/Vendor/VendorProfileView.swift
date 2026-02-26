//  VendorProfileView.swift
import SwiftUI
struct VendorProfileView: View {
    @StateObject private var viewModel = VendorProfileViewModel()
    @State private var showEditProfile = false
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    Circle().fill(AppTheme.Colors.primary.opacity(0.2)).frame(width: 100, height: 100).overlay(Image(systemName: "building.2").font(.system(size: 50)).foregroundColor(AppTheme.Colors.primary))
                    Text(viewModel.companyName).font(AppTheme.Fonts.bold(20))
                }
                .padding(20)
                .background(LinearGradient(gradient: Gradient(colors: [AppTheme.Colors.primary.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(12)
                
                VStack(spacing: 0) {
                    ProfileOptionRow(icon: "building.2", title: "Edit Company", showDivider: true) { showEditProfile = true }
                    ProfileOptionRow(icon: "envelope", title: "Enquiries", showDivider: true) { viewModel.navigate("enquiries") }
                    ProfileOptionRow(icon: "doc.text", title: "Quotations", showDivider: true) { viewModel.navigate("quotations") }
                    ProfileOptionRow(icon: "briefcase", title: "Jobs", showDivider: true) { viewModel.navigate("jobs") }
                    ProfileOptionRow(icon: "person.2", title: "Freelancers", showDivider: true) { viewModel.navigate("freelancers") }
                    ProfileOptionRow(icon: "arrow.right.square", title: "Logout", showDivider: false, isDestructive: true) { viewModel.logout() }
                }
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(16)
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showEditProfile) { Text("Edit Profile") }
    }
}
class VendorProfileViewModel: ObservableObject {
    @Published var companyName = "My Company"
    func navigate(_ to: String) { print("Navigate to: \(to)") }
    func logout() { UserDefaultsManager.shared.clearAllLoginData() }
}
