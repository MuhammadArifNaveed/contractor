//
//  ComplaintDetailView.swift
//  TheContractor
//
//  One of the signed-in user's own complaints. POST Home/complaint with `id` + `user_id`.
//
//  Replaces a display-only shell that took a list row and made no request. The endpoint answered
//  cleanly when probed, but the QA account has no complaints, so the field names below come from the
//  `Home/recent_complaints` row shape and Android's model rather than from a populated payload — the
//  parse is deliberately tolerant of the alternatives.
//

import SwiftUI
import SwiftyJSON

struct ComplaintDetailView: View {
    let complaintId: String

    @State private var state: VendorLoadState = .loading
    @State private var complaint: ConsumerComplaintDetail?
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Complaint", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 2) }
                case .noData:
                    VendorEmptyState(icon: "exclamationmark.bubble",
                                     title: "Complaint unavailable",
                                     message: "This complaint could not be loaded.",
                                     actionTitle: "Try again",
                                     action: load)
                case .loaded:
                    if let complaint = complaint {
                        content(complaint)
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

    private func content(_ complaint: ConsumerComplaintDetail) -> some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.l) {
                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    Text(complaint.number.isEmpty ? "Complaint" : complaint.number)
                        .font(VendorTheme.Text.screenTitle)
                        .foregroundColor(VendorTheme.textPrimary)

                    if !complaint.statusName.isEmpty {
                        VendorBadge(name: complaint.statusName, colorHex: complaint.color)
                    }

                    VendorField(label: "Raised", value: VendorTheme.date(complaint.createdAt))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "Complaint")
                    if !complaint.companyName.isEmpty {
                        VendorField(label: "Company", value: complaint.companyName)
                    }
                    VendorField(label: "Details", value: complaint.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                if !complaint.reply.isEmpty {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                        VendorSectionHeader(title: "Response")
                        Text(complaint.reply)
                            .font(VendorTheme.Text.body)
                            .foregroundColor(VendorTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()
                }
            }
            .padding(VendorTheme.Space.l)
        }
        .refreshable { await reload() }
    }

    // MARK: - Data

    private func load() {
        if complaint == nil { state = .loading }
        fetch()
    }

    private func reload() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        guard let userId = UserDefaultsManager.shared.userInfo?.id, !userId.isEmpty else {
            state = .noData
            finished?()
            return
        }

        GCD.async(.Background) {
            LoginService.shared().getConsumerComplaintDetail(complaintId: complaintId, userId: userId) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json, json["complaint"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    complaint = ConsumerComplaintDetail(json["complaint"])
                    state = .loaded
                }
            }
        }
    }
}

// MARK: - Model

struct ConsumerComplaintDetail {
    let id: String
    let number: String
    let statusName: String
    let color: String
    let createdAt: String
    let companyName: String
    let text: String
    let reply: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.number = json["complaint_number"].stringValue
        self.statusName = json["status_name"].exists()
            ? json["status_name"].stringValue
            : json["s_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.companyName = json["company_name"].stringValue
        // The submit part is `complaint`; the stored column has also appeared as `text`.
        self.text = json["complaint"].exists()
            ? json["complaint"].stringValue
            : json["text"].stringValue
        self.reply = json["reply"].stringValue
    }
}
