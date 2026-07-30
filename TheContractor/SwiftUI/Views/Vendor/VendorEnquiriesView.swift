//
//  VendorEnquiriesView.swift
//  TheContractor
//
//  Two screens from Android's vendor drawer:
//    • `VendorDashboardEnquiries` — every enquiry status with its count (POST vendor/enquiries_status)
//    • `VendorParticularEnquiries` — the enquiries sitting in one status (POST vendor/view)
//

import SwiftUI
import SwiftyJSON

// MARK: - Enquiries (all statuses)

struct VendorEnquiriesView: View {
    @State private var state: VendorLoadState = .loading
    @State private var counts: [VendorDashboardCount] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Enquiries")

                ZStack {
                    VendorTheme.canvas
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        VendorSkeletonList()
                    case .noData:
                        VendorEmptyState(icon: "tray",
                                     title: "No enquiries yet",
                                     message: "Enquiries from customers will appear here.")
                    case .loaded:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                                      spacing: 4) {
                                ForEach(counts) { count in
                                    NavigationLink(destination: VendorParticularEnquiriesView(status: count)) {
                                        VendorDashboardCountCard(count: count)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func load() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorEnquiryStatuses(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    counts = json["vendor_dashboard_counts"].arrayValue.map(VendorDashboardCount.init)
                    state = counts.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Enquiries in one status

struct VendorParticularEnquiriesView: View {
    let status: VendorDashboardCount

    @State private var state: VendorLoadState = .loading
    @State private var enquiries: [VendorEnquiryRow] = []
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Android sets the action bar title to the status name and shows the up arrow.
            VendorTopBar(title: status.name, onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "tray",
                                     title: "Nothing in this status",
                                     message: "Enquiries move here as their status changes.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(enquiries) { enquiry in
                                NavigationLink(destination: VendorEnquiryDetailView(enquiryId: enquiry.id)) {
                                    VendorEnquiryRowCard(enquiry: enquiry)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(10)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear(perform: load)
    }

    private func load() {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorParticularEnquiries(statusId: status.id, vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    enquiries = json["vendor_enquiries"].arrayValue.map(VendorEnquiryRow.init)
                    state = enquiries.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

