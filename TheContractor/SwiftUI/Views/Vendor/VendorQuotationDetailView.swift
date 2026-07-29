//
//  VendorQuotationDetailView.swift
//  TheContractor
//
//  Port of Android's `VendorQuotationDetail` — `activity_vendor_quotation_detail.xml` for the
//  layout, POST vendor/quotation for the data, and the status chips / rejection dialog for the
//  actions. Android also lets the company attach a document once the quotation reaches status 2
//  or 5; that upload is not part of this screen yet.
//

import SwiftUI
import SwiftyJSON

struct VendorQuotationDetailView: View {
    let quotationId: String

    @State private var state: VendorLoadState = .loading
    @State private var quotation: VendorQuotationDetailModel?
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    @State private var showRejectionDialog = false
    @State private var rejectionReason = ""
    @State private var rejectingStatusId = ""
    @State private var isUpdating = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Quotation Details", onBack: { dismiss() })

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
                    if let quotation = quotation {
                        detail(quotation)
                    }
                }

                if isUpdating {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .sheet(isPresented: $showRejectionDialog) {
            VendorRejectionSheet(reason: $rejectionReason) {
                showRejectionDialog = false
                submitRejection()
            } onCancel: {
                showRejectionDialog = false
                rejectionReason = ""
            }
        }
        .onAppear(perform: load)
    }

    // MARK: - Layout (activity_vendor_quotation_detail.xml)

    private func detail(_ quotation: VendorQuotationDetailModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    field(label: "Category", value: quotation.categoryName)
                    field(label: "Sub Category", value: quotation.subCategoryName)
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Quotation No", value: quotation.quotationNumber)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Quotation Status")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(white: 0.35))
                        VendorStatusBadge(name: quotation.statusName, color: quotation.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                divider

                field(label: "Date & Time", value: VendorHomeStyle.formatDate(quotation.createdAt))

                // Android only shows the note block when the user actually left a message.
                if !quotation.message.isEmpty {
                    divider
                    field(label: "Note", value: quotation.message)
                }

                divider

                Text("User Information")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 8)

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Name", value: quotation.fullName)
                    field(label: "Phone Number", value: quotation.phone)
                }

                divider

                field(label: "Email Address", value: quotation.email)

                if !quotation.images.isEmpty {
                    divider

                    Text("Images")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 8)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                              spacing: 8) {
                        ForEach(quotation.images) { image in
                            VendorQuotationImageCell(path: image.path)
                        }
                    }
                }

                if !quotation.statusOptions.isEmpty {
                    divider

                    Text("Update Status")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quotation.statusOptions) { option in
                                Button(action: { updateStatus(to: option) }) {
                                    VendorStatusBadge(name: option.name, color: option.color)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(white: 0.35))
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(white: 0.85))
            .frame(height: 0.5)
            .padding(.vertical, 10)
    }

    // MARK: - Data

    private func load() {
        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorQuotationDetail(quotationId: quotationId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json, json["vendor_quotation"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    quotation = VendorQuotationDetailModel(json["vendor_quotation"])
                    state = .loaded
                }
            }
        }
    }

    private func updateStatus(to option: VendorStatusOption) {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isUpdating = true
        GCD.async(.Background) {
            LoginService.shared().updateVendorQuotationStatus(quotationId: quotationId, vendorId: vendorId, statusId: option.id) { message, success, json in
                GCD.async(.Main) {
                    isUpdating = false
                    guard success else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }

                    if json?["status"].stringValue == "reject" {
                        rejectingStatusId = option.id
                        rejectionReason = ""
                        showRejectionDialog = true
                    } else {
                        load()
                    }
                }
            }
        }
    }

    private func submitRejection() {
        let reason = rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reason.isEmpty else {
            noticeMessage = "Enter your reason of rejection"
            return
        }

        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isUpdating = true
        GCD.async(.Background) {
            LoginService.shared().rejectVendorQuotation(quotationId: quotationId, vendorId: vendorId, statusId: rejectingStatusId, reason: reason) { message, success in
                GCD.async(.Main) {
                    isUpdating = false
                    rejectionReason = ""
                    if success {
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Models

/// Android `VendorQuotationModel` in its detail form.
struct VendorQuotationDetailModel {
    let id: String
    let statusId: String
    let quotationNumber: String
    let statusName: String
    let color: String
    let createdAt: String
    let message: String
    let categoryName: String
    let subCategoryName: String
    let name: String
    let surname: String
    let phone: String
    let email: String
    let images: [VendorQuotationImage]
    let statusOptions: [VendorStatusOption]

    var fullName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.statusId = json["status_id"].stringValue
        self.quotationNumber = json["quotation_number"].stringValue
        self.statusName = json["status_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.message = json["message"].stringValue
        self.categoryName = json["cate_name"].stringValue
        self.subCategoryName = json["sub_cat_name"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.phone = json["phone"].stringValue
        self.email = json["email"].stringValue
        self.images = json["images"].arrayValue.map(VendorQuotationImage.init)
        self.statusOptions = json["status"].arrayValue.map(VendorStatusOption.init)
    }
}

/// Android `QuotationImages` — served from `uploads/quotations/`.
struct VendorQuotationImage: Identifiable {
    let id: String
    let path: String

    init(_ json: JSON) {
        self.path = json["image_path"].stringValue
        self.id = json["id"].exists() ? json["id"].stringValue : json["image_path"].stringValue
    }

    var url: URL? {
        URL(string: "https://contractor.bidcont.com/uploads/quotations/" + path)
    }
}

/// Android loads these with Glide into a 3-column grid.
struct VendorQuotationImageCell: View {
    let path: String

    var body: some View {
        AsyncImage(url: VendorQuotationImage.url(forPath: path)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                placeholder
            default:
                placeholder
            }
        }
        .frame(height: 90)
        .clipped()
        .cornerRadius(5)
    }

    private var placeholder: some View {
        ZStack {
            Color(white: 0.92)
            Image(systemName: "photo")
                .font(.system(size: 22))
                .foregroundColor(Color(white: 0.6))
        }
    }
}

extension VendorQuotationImage {
    static func url(forPath path: String) -> URL? {
        URL(string: "https://contractor.bidcont.com/uploads/quotations/" + path)
    }
}
