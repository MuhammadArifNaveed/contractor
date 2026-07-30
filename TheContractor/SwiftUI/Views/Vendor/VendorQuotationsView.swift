//
//  VendorQuotationsView.swift
//  TheContractor
//
//  Two screens from Android's vendor drawer:
//    • `VendorDashboardQuotations` — every quotation status with its count
//      (POST vendor/quotations_dashnoard — the typo is the backend's, not ours)
//    • `VendorParticularQuotations` — the quotations sitting in one status (POST vendor/quotations)
//

import SwiftUI
import SwiftyJSON

// MARK: - Quotations (all statuses)

struct VendorQuotationsView: View {
    @State private var state: VendorLoadState = .loading
    @State private var counts: [VendorDashboardCount] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Quotations")

                ZStack {
                    VendorTheme.canvas
                        .ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        VendorSkeletonList()
                    case .noData:
                        VendorEmptyState(icon: "doc.plaintext",
                                     title: "No quotations yet",
                                     message: "Quotation requests will appear here.")
                    case .loaded:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                                      spacing: 4) {
                                ForEach(counts) { count in
                                    NavigationLink(destination: VendorParticularQuotationsView(status: count)) {
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
            LoginService.shared().getVendorQuotationStatuses(vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    counts = json["quotation_counts"].arrayValue.map(VendorDashboardCount.init)
                    state = counts.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Quotations in one status

struct VendorParticularQuotationsView: View {
    let status: VendorDashboardCount

    @State private var state: VendorLoadState = .loading
    @State private var quotations: [VendorQuotationRow] = []
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: status.name, onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "doc.plaintext",
                                     title: "Nothing in this status",
                                     message: "Quotations move here as their status changes.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(quotations) { quotation in
                                NavigationLink(destination: VendorQuotationDetailView(quotationId: quotation.id)) {
                                    VendorQuotationRowCard(quotation: quotation)
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
            LoginService.shared().getVendorParticularQuotations(statusId: status.id, vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    quotations = json["vendor_quotations"].arrayValue.map(VendorQuotationRow.init)
                    state = quotations.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Models

/// Android `VendorQuotationModel` reduced to what `VendorQuotationAdapter` binds.
struct VendorQuotationRow: Identifiable {
    let id: String
    let quotationNumber: String
    let statusName: String
    let color: String
    let createdAt: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.quotationNumber = json["quotation_number"].stringValue
        self.statusName = json["status_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
    }
}

/// Android `vendor_quotation_custom_row.xml` — same shape as the enquiry row.
struct VendorQuotationRowCard: View {
    let quotation: VendorQuotationRow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(quotation.quotationNumber)
                .font(.system(size: 14))
                .foregroundColor(.black)

            Text(VendorTheme.date(quotation.createdAt))
                .font(.system(size: 14))
                .foregroundColor(VendorTheme.textSecondary)

            VendorBadge(name: quotation.statusName, colorHex: quotation.color)
                .padding(.top, 5)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}
