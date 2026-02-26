//  VendorReportsView.swift
import SwiftUI
struct VendorReportsView: View {
    var body: some View {
        List {
            NavigationLink("Monthly Report", destination: Text("Monthly Report"))
            NavigationLink("Quarterly Report", destination: Text("Quarterly Report"))
            NavigationLink("Annual Report", destination: Text("Annual Report"))
            NavigationLink("Custom Report", destination: Text("Custom Report"))
        }
        .navigationTitle("Reports")
    }
}
