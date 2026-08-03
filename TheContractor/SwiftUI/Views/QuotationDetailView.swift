//
//  QuotationDetailView.swift
//  TheContractor
//
//  One of the signed-in user's own quotations. POST Home/quotation with `id` + `user_id`.
//
//  Verified live: the response carries the record under `quotation`, with `quotation_price` and
//  `symbol` alongside it at the top level rather than nested inside. A screen reading only
//  `quotation` would show no price.
//
//  This replaces a display-only shell that took a list row and made no request at all.
//

import SwiftUI
import SwiftyJSON

struct QuotationDetailView: View {
    let quotationId: String

    @State private var state: VendorLoadState = .loading
    @State private var quotation: ConsumerQuotationDetail?
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Quotation", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ScrollView { VendorSkeletonList(rows: 3) }
                case .noData:
                    VendorEmptyState(icon: "doc.text.magnifyingglass",
                                     title: "Quotation unavailable",
                                     message: "This quotation could not be loaded.",
                                     actionTitle: "Try again",
                                     action: load)
                case .loaded:
                    if let quotation = quotation {
                        content(quotation)
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

    private func content(_ quotation: ConsumerQuotationDetail) -> some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.l) {
                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(quotation.number.isEmpty ? "Quotation" : quotation.number)
                            .font(VendorTheme.Text.screenTitle)
                            .foregroundColor(VendorTheme.textPrimary)
                        Spacer(minLength: VendorTheme.Space.s)
                        if !quotation.price.isEmpty {
                            Text("\(quotation.symbol) \(quotation.price)")
                                .font(VendorTheme.Text.cardTitle)
                                .foregroundColor(VendorTheme.textPrimary)
                        }
                    }

                    if !quotation.statusName.isEmpty {
                        VendorBadge(name: quotation.statusName, colorHex: quotation.color)
                    }

                    VendorField(label: "Requested", value: VendorTheme.date(quotation.createdAt))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "Work")
                    HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                        VendorField(label: "Category", value: quotation.categoryName)
                        VendorField(label: "Sub category", value: quotation.subCategoryName)
                    }
                    if !quotation.message.isEmpty {
                        VendorField(label: "Your note", value: quotation.message)
                    }
                    if !quotation.reply.isEmpty {
                        VendorField(label: "Reply", value: quotation.reply)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                    VendorSectionHeader(title: "Your details")
                    HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                        VendorField(label: "Name", value: quotation.fullName)
                        VendorField(label: "Phone", value: quotation.phone)
                    }
                    VendorField(label: "Email", value: quotation.email)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .vendorCard()

                if !quotation.imagePaths.isEmpty {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                        VendorSectionHeader(title: "Images", count: quotation.imagePaths.count)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: VendorTheme.Space.s) {
                                ForEach(quotation.imagePaths, id: \.self) { path in
                                    AsyncImage(url: VendorTheme.quotationImageURL(path)) { phase in
                                        if case .success(let image) = phase {
                                            image.resizable().scaledToFill()
                                        } else {
                                            ZStack {
                                                VendorTheme.surfaceRaised
                                                Image(systemName: "photo")
                                                    .foregroundColor(VendorTheme.textTertiary)
                                            }
                                        }
                                    }
                                    .frame(width: 120, height: 92)
                                    .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control,
                                                                style: .continuous))
                                }
                            }
                        }
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
        if quotation == nil { state = .loading }
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
            LoginService.shared().getConsumerQuotationDetail(quotationId: quotationId, userId: userId) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json, json["quotation"].exists() else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    quotation = ConsumerQuotationDetail(json)
                    state = .loaded
                }
            }
        }
    }
}

// MARK: - Model

/// Built from the whole response rather than just the `quotation` object, because the price and
/// currency symbol sit outside it.
struct ConsumerQuotationDetail {
    let id: String
    let number: String
    let statusName: String
    let color: String
    let createdAt: String
    let categoryName: String
    let subCategoryName: String
    let message: String
    let reply: String
    let name: String
    let surname: String
    let phone: String
    let email: String
    let imagePaths: [String]
    let price: String
    let symbol: String

    var fullName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    init(_ response: JSON) {
        let json = response["quotation"]
        self.id = json["id"].stringValue
        self.number = json["quotation_number"].stringValue
        self.statusName = json["status_name"].stringValue
        self.color = json["color"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.categoryName = json["cate_name"].stringValue
        self.subCategoryName = json["sub_cat_name"].stringValue
        self.message = json["message"].stringValue
        self.reply = json["reply"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.phone = json["phone"].stringValue
        self.email = json["email"].stringValue
        self.imagePaths = json["images"].arrayValue
            .map { $0["image_path"].stringValue }
            .filter { !$0.isEmpty }
        // Siblings of `quotation`, not children.
        self.price = response["quotation_price"].stringValue
        self.symbol = response["symbol"].stringValue.trimmingCharacters(in: .whitespaces)
    }
}
