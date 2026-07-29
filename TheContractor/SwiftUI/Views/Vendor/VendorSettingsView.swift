//  VendorSettingsView.swift
import SwiftUI

struct VendorSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    private var vendorName: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["company_name"] as? String ?? ""
        }
        return ""
    }
    
    private var vendorEmail: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["company_email"] as? String ?? ""
        }
        return ""
    }
    
    private var vendorPhone: String {
        if let vendorData = UserDefaults.standard.data(forKey: "vendor"),
           let vendorDict = try? JSONSerialization.jsonObject(with: vendorData) as? [String: Any] {
            return vendorDict["company_phone"] as? String ?? ""
        }
        return ""
    }
    
    var body: some View {
        Form {
            // Company Info Section
            Section(header: Text("Company Information")) {
                HStack {
                    Text("Company Name")
                    Spacer()
                    Text(vendorName)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Email")
                    Spacer()
                    Text(vendorEmail)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Phone")
                    Spacer()
                    Text(vendorPhone)
                        .foregroundColor(.gray)
                }
            }
            
            // Account Section
            Section(header: Text("Account")) {
                NavigationLink("Edit Company Profile", destination: Text("Edit Profile"))
                NavigationLink("Change Password", destination: ChangePasswordView())
            }
            
            // Preferences Section
            Section(header: Text("Preferences")) {
                NavigationLink("Language", destination: LanguageSelectionView())
                Toggle("Notifications", isOn: .constant(true))
            }
            
            // About Section
            Section(header: Text("About")) {
                NavigationLink("Terms & Conditions", destination: WebContentView(url: "https://contractor.bidcont.com/terms", title: "Terms"))
                NavigationLink("Privacy Policy", destination: WebContentView(url: "https://contractor.bidcont.com/privacy", title: "Privacy"))
            }
        }
        .navigationTitle("Settings")
    }
}
