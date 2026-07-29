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
                    VendorHomeStyle.background
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                    case .noData:
                        Text("Data Not Found")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
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
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                case .noData:
                    Text("Data Not Found")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
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

// MARK: - Shared top bar

/// The yellow action bar every vendor screen carries. A drawer-rooted screen leaves `onBack` nil
/// and gets the hamburger, matching Android's `ActionBarDrawerToggle`; a pushed screen passes a
/// dismiss closure and gets the up arrow Android's `setDisplayHomeAsUpEnabled(true)` shows.
struct VendorTopBar: View {
    private let title: String
    private let onBack: (() -> Void)?

    init(title: String, onBack: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: 8) {
            Button(action: tapLeading) {
                Image(systemName: onBack == nil ? "line.3.horizontal" : "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 32, height: 32)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(VendorHomeStyle.appColor)
    }

    private func tapLeading() {
        if let onBack = onBack {
            onBack()
        } else {
            VendorNavigation.openDrawer()
        }
    }
}
