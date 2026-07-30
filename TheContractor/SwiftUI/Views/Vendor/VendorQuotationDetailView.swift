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

    @State private var showDocumentPicker = false
    @State private var pickedDocument: Data?
    @State private var pickedDocumentName: String?
    @State private var pickedDocumentMime = "application/octet-stream"

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Quotation Details", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "doc.text.magnifyingglass",
                                     title: "Quotation unavailable",
                                     message: "This quotation could not be loaded.")
                case .loaded:
                    if let quotation = quotation {
                        detail(quotation)
                    }
                }

                if isUpdating {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
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
        .fileImporter(isPresented: $showDocumentPicker,
                      allowedContentTypes: [.pdf, .image, .plainText, .spreadsheet, .data],
                      allowsMultipleSelection: false) { result in
            handlePickedDocument(result)
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
                            .foregroundColor(VendorTheme.textSecondary)
                        VendorBadge(name: quotation.statusName, colorHex: quotation.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                divider

                field(label: "Date & Time", value: VendorTheme.date(quotation.createdAt))

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
                                    VendorBadge(name: option.name, colorHex: option.color)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }

                // Android offers the attachment only at status 2 ("Select Document") and status 5
                // ("Resubmit Document"), and hides the existing filename in the resubmit case.
                if quotation.allowsDocumentUpload {
                    divider
                    documentSection(quotation)
                }
            }
            .padding(10)
        }
    }

    private func documentSection(_ quotation: VendorQuotationDetailModel) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: quotation.isResubmitStage ? "Resubmit Document" : "Upload Document")

            Text(quotation.isResubmitStage
                 ? "Your last document was not accepted. Attach a replacement."
                 : "Attach the quotation document for this request.")
                .font(VendorTheme.Text.meta)
                .foregroundColor(VendorTheme.textSecondary)

            if let name = pickedDocumentName {
                HStack(spacing: VendorTheme.Space.s) {
                    Image(systemName: "doc.fill").foregroundColor(VendorTheme.accent)
                    Text(name)
                        .font(VendorTheme.Text.body)
                        .foregroundColor(VendorTheme.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            }

            HStack(spacing: VendorTheme.Space.s) {
                Button(action: { showDocumentPicker = true }) {
                    Text(pickedDocumentName == nil ? "Choose file" : "Change")
                        .font(VendorTheme.Text.cardTitle)
                        .foregroundColor(VendorTheme.textPrimary)
                        .padding(.horizontal, VendorTheme.Space.l)
                        .padding(.vertical, VendorTheme.Space.s)
                        .background(Capsule().fill(VendorTheme.surfaceRaised))
                        .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
                }
                .buttonStyle(VendorPressStyle())

                if pickedDocument != nil {
                    Button(action: uploadDocument) {
                        Text("Upload")
                            .font(VendorTheme.Text.cardTitle)
                            .foregroundColor(.black.opacity(0.85))
                            .padding(.horizontal, VendorTheme.Space.l)
                            .padding(.vertical, VendorTheme.Space.s)
                            .background(Capsule().fill(VendorTheme.accent))
                    }
                    .buttonStyle(VendorPressStyle())
                }

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(VendorTheme.textSecondary)
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var divider: some View {
        Rectangle()
            .fill(VendorTheme.separator)
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

    /// The picker hands back a security-scoped URL, so the bytes have to be read inside a
    /// start/stop access pair before the scope is released.
    private func handlePickedDocument(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                pickedDocument = try Data(contentsOf: url)
                pickedDocumentName = url.lastPathComponent
                pickedDocumentMime = VendorQuotationDetailView.mimeType(for: url)
            } catch {
                errorMessage = "That file could not be read."
            }
        }
    }

    private static func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }

    private func uploadDocument() {
        guard let data = pickedDocument, let name = pickedDocumentName else { return }
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isUpdating = true
        GCD.async(.Background) {
            LoginService.shared().uploadQuotationDocument(quotationId: quotationId,
                                                          vendorId: vendorId,
                                                          fileData: data,
                                                          fileName: name,
                                                          mimeType: pickedDocumentMime) { message, success in
                GCD.async(.Main) {
                    isUpdating = false
                    if success {
                        pickedDocument = nil
                        pickedDocumentName = nil
                        noticeMessage = message.isEmpty ? "Document uploaded." : message
                        load()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
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

    /// Android shows the upload block only at these two statuses
    /// (`VendorQuotationDetail.setDataToWidget`).
    var allowsDocumentUpload: Bool { statusId == "2" || statusId == "5" }
    /// Status 5 is Android's "Resubmit Document" wording.
    var isResubmitStage: Bool { statusId == "5" }

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
            VendorTheme.surfaceRaised
            Image(systemName: "photo")
                .font(.system(size: 22))
                .foregroundColor(VendorTheme.textTertiary)
        }
    }
}

extension VendorQuotationImage {
    static func url(forPath path: String) -> URL? {
        URL(string: "https://contractor.bidcont.com/uploads/quotations/" + path)
    }
}
