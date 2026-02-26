//  VendorSettingsView.swift
import SwiftUI
struct VendorSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                NavigationLink("Edit Company Profile", destination: Text("Edit Profile"))
                NavigationLink("Change Password", destination: ChangePasswordView())
            }
            Section(header: Text("Preferences")) {
                NavigationLink("Language", destination: LanguageSelectionView())
                Toggle("Notifications", isOn: .constant(true))
            }
            Section(header: Text("About")) {
                NavigationLink("Terms & Conditions", destination: WebContentView(url: "https://contractor.bidcont.com/terms", title: "Terms"))
                NavigationLink("Privacy Policy", destination: WebContentView(url: "https://contractor.bidcont.com/privacy", title: "Privacy"))
            }
        }
        .navigationTitle("Settings")
    }
}
