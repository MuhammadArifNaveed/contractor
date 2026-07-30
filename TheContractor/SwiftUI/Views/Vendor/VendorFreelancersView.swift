//
//  VendorFreelancersView.swift
//  TheContractor
//
//  Port of Android's `VendorDashboardFreelancer` (drawer item "Freelancer Dashboard") —
//  POST freelancing/freelancing_dashboard, response key `freelancing_dashboard`, rendered with the
//  same `vendor_dashboard_row.xml` grid the other dashboards use.
//
//  Android's adapter routes every tile to `VendorJobListing`, so this does too.
//

import SwiftUI
import SwiftyJSON

struct VendorFreelancersView: View {
    @State private var state: VendorLoadState = .loading
    @State private var counts: [VendorDashboardCount] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Freelancer Dashboard")

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
                                    NavigationLink(destination: VendorJobListingView(status: count)) {
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
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorFreelancingDashboard(vendorId: session.id,
                                                               userId: session.user_id,
                                                               userType: session.user_type) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    counts = json["freelancing_dashboard"].arrayValue.map(VendorDashboardCount.init)
                    state = counts.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}
