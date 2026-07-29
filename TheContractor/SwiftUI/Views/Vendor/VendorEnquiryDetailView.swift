//
//  VendorEnquiryDetailView.swift
//  TheContractor
//
//  Port of Android's `VendorEnquiryDetail` — `activity_vendor_enquiry_detail.xml` for the layout,
//  POST vendor/enquiry for the data, and the status chips / rejection dialog for the actions.
//

import SwiftUI
import SwiftyJSON

struct VendorEnquiryDetailView: View {
    let enquiryId: String

    @State private var state: VendorLoadState = .loading
    @State private var enquiry: VendorEnquiryDetailModel?
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    @State private var showRejectionDialog = false
    @State private var rejectionReason = ""
    @State private var rejectingStatusId = ""
    @State private var isUpdating = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Enquiry Details", onBack: { dismiss() })

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
                    if let enquiry = enquiry {
                        detail(enquiry)
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
        // Android's rejection_dialog: one free-text field and a Submit button, and it refuses to
        // submit an empty reason.
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

    // MARK: - Layout (activity_vendor_enquiry_detail.xml)

    private func detail(_ enquiry: VendorEnquiryDetailModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    field(label: "Order At", value: VendorHomeStyle.formatDate(enquiry.createdAt))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Enquiry Status")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(white: 0.35))
                        VendorStatusBadge(name: enquiry.statusName, color: enquiry.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                divider

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Date & Time", value: VendorHomeStyle.formatDate(enquiry.dateTime))
                    field(label: "Enquiry Number", value: enquiry.enquiryNumber)
                }

                divider

                field(label: "Location", value: enquiry.location)

                divider

                field(label: "Description", value: enquiry.description)

                divider

                Text("User Information")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.bottom, 8)

                HStack(alignment: .top, spacing: 10) {
                    field(label: "Name", value: enquiry.fullName)
                    field(label: "Phone Number", value: enquiry.phone)
                }

                divider

                field(label: "Email Address", value: enquiry.email)

                // Android hides the whole "Update Status" block when the API sends no options.
                if !enquiry.statusOptions.isEmpty {
                    divider

                    Text("Update Status")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(enquiry.statusOptions) { option in
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
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else {
            state = .noData
            return
        }

        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getVendorEnquiryDetail(enquiryId: enquiryId, vendorId: vendorId) { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json, json["vendor_enquiry"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    enquiry = VendorEnquiryDetailModel(json["vendor_enquiry"])
                    state = .loaded
                }
            }
        }
    }

    /// Android posts the new status first; a `"reject"` response means the backend wants a reason
    /// before it will actually apply the change.
    private func updateStatus(to option: VendorStatusOption) {
        let vendorId = VendorSession.currentVendorId
        guard !vendorId.isEmpty else { return }

        isUpdating = true
        GCD.async(.Background) {
            LoginService.shared().updateVendorEnquiryStatus(enquiryId: enquiryId, vendorId: vendorId, statusId: option.id) { message, success, json in
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
            LoginService.shared().rejectVendorEnquiry(enquiryId: enquiryId, vendorId: vendorId, statusId: rejectingStatusId, reason: reason) { message, success in
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

/// Android `VendorEnquiryModel` in its detail form — the extra fields `vendor/enquiry` returns on
/// top of what the list rows carry.
struct VendorEnquiryDetailModel {
    let id: String
    let enquiryNumber: String
    let statusName: String
    let color: String
    let createdAt: String
    let dateTime: String
    let location: String
    let description: String
    let name: String
    let surname: String
    let phone: String
    let email: String
    let statusOptions: [VendorStatusOption]

    var fullName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.enquiryNumber = json["enquiry_number"].stringValue
        self.statusName = json["s_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.dateTime = json["date_time"].stringValue
        self.location = json["location"].stringValue
        self.description = json["description"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.phone = json["phone"].stringValue
        self.email = json["email"].stringValue
        self.statusOptions = json["status"].arrayValue.map(VendorStatusOption.init)
    }
}

/// Android `VendorStatusModel` — one selectable next status.
struct VendorStatusOption: Identifiable {
    let id: String
    let name: String
    let color: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.color = json["color"].stringValue
    }
}

// MARK: - Rejection sheet

/// Android `rejection_dialog.xml`. A sheet rather than an alert because the deployment target is
/// iOS 15, where alerts cannot host a text field.
struct VendorRejectionSheet: View {
    @Binding var reason: String
    let onSubmit: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Reason of Rejection", onBack: onCancel)

            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $reason)
                    .frame(height: 140)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(white: 0.8), lineWidth: 1)
                    )

                Button(action: onSubmit) {
                    Text("Submit")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(VendorHomeStyle.appColor)
                        .cornerRadius(5)
                }

                Spacer()
            }
            .padding(16)
            .background(VendorHomeStyle.background)
        }
    }
}
