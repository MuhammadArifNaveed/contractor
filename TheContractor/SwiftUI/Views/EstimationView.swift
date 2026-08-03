//
//  EstimationView.swift
//  TheContractor
//
//  The cost estimate calculator — Android's `EstimationFragment`, the fourth bottom tab.
//
//  Pick what you are looking for, pick a type under it, enter the area, and the app multiplies the
//  area by that type's per-square-foot rate. From the result you can ask for a free consultation,
//  which is the only part that reaches the server: `Home/submit_estimate_request`.
//
//  The iOS screen this replaces was a calculator and nothing more — it had no consultation request, so
//  a calculated estimate went nowhere and the user's own requests were unreachable from here.
//
//  Endpoints verified live: `Home/get_estimation_categories` answers with two categories, three
//  sub-categories each, `min_val` carrying the rate.
//

import SwiftUI
import SwiftyJSON

struct EstimationView: View {
    @State private var state: VendorLoadState = .loading
    @State private var categories: [EstimationCategory] = []

    @State private var selectedCategoryId = ""
    @State private var selectedSubCategoryId = ""
    @State private var squareFeet = ""

    /// Android keeps the result hidden until Calculate is pressed, and clears it on "estimate again".
    @State private var result: EstimationResult?

    @State private var showingConsultation = false
    @State private var notice: String?

    private var selectedCategory: EstimationCategory? {
        categories.first { $0.id == selectedCategoryId }
    }

    private var selectedSubCategory: EstimationSubCategory? {
        selectedCategory?.subCategories.first { $0.id == selectedSubCategoryId }
    }

    var body: some View {
        ZStack {
            VendorTheme.canvas.ignoresSafeArea()

            switch state {
            case .loading:
                ScrollView { VendorSkeletonList(rows: 3) }
            case .noData:
                VendorEmptyState(icon: "function",
                                 title: "Estimates unavailable",
                                 message: "The estimate categories could not be loaded.",
                                 actionTitle: "Try again",
                                 action: load)
            case .loaded:
                content
            }
        }
        .alert("", isPresented: Binding(get: { notice != nil }, set: { _ in notice = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notice ?? "")
        }
        .sheet(isPresented: $showingConsultation) {
            if let result = result {
                EstimationConsultationView(result: result) { message in
                    showingConsultation = false
                    reset()
                    notice = message
                }
            }
        }
        .onAppear(perform: load)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: VendorTheme.Space.m) {
                if let result = result {
                    resultCard(result)
                } else {
                    lookingForCard
                    typeCard
                    areaCard
                    calculateButton
                }
            }
            .padding(VendorTheme.Space.l)
        }
    }

    // MARK: - Steps

    private var lookingForCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "What are you looking for")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VendorTheme.Space.s) {
                    ForEach(categories) { category in
                        chip(category.name, selected: category.id == selectedCategoryId) {
                            selectedCategoryId = category.id
                            selectedSubCategoryId = ""
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var typeCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Type of space")

            if let category = selectedCategory, !category.subCategories.isEmpty {
                // Android lays these out two per row.
                let columns = [GridItem(.flexible(), spacing: VendorTheme.Space.s),
                               GridItem(.flexible(), spacing: VendorTheme.Space.s)]
                LazyVGrid(columns: columns, spacing: VendorTheme.Space.s) {
                    ForEach(category.subCategories) { sub in
                        chip(sub.name, selected: sub.id == selectedSubCategoryId, fillsWidth: true) {
                            selectedSubCategoryId = sub.id
                        }
                    }
                }
            } else {
                Text("Choose what you are looking for first.")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var areaCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Total area")

            HStack(spacing: VendorTheme.Space.s) {
                TextField("0", text: $squareFeet)
                    .keyboardType(.numberPad)
                    .font(VendorTheme.Text.body)
                    .padding(VendorTheme.Space.s)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.surfaceRaised)
                    )

                Text("Sqft")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var calculateButton: some View {
        Button(action: calculate) {
            Text("Calculate estimate")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.onAccent)
                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    // MARK: - Result

    private func resultCard(_ result: EstimationResult) -> some View {
        VStack(spacing: VendorTheme.Space.m) {
            VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                Text("ESTIMATED BUDGET")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textTertiary)
                    .tracking(0.4)

                Text(result.formattedBudget)
                    .font(VendorTheme.Text.metric)
                    .foregroundColor(VendorTheme.textPrimary)

                Divider().background(VendorTheme.separator)

                VendorField(label: "Looking for", value: result.categoryName)
                VendorField(label: "Type of space", value: result.subCategoryName)
                HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                    VendorField(label: "Total area", value: result.formattedArea)
                    VendorField(label: "Rate", value: "\(result.rate) AED / Sqft")
                }

                Text("An indicative figure only. Request a free consultation and the team will come back with a firm quote.")
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .vendorCard()

            Button(action: requestConsultation) {
                Text("Request a free consultation")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.onAccent)
                    .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.accent)
                    )
            }
            .buttonStyle(VendorPressStyle())

            Button(action: reset) {
                Text("Estimate again")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
            }
            .buttonStyle(VendorPressStyle())
        }
    }

    private func chip(_ title: String, selected: Bool, fillsWidth: Bool = false,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(VendorTheme.Text.label)
                .foregroundColor(selected ? VendorTheme.onAccent : VendorTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, VendorTheme.Space.m)
                .padding(.vertical, VendorTheme.Space.s)
                .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: 40)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(selected ? VendorTheme.accent : VendorTheme.surfaceRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .stroke(selected ? Color.clear : VendorTheme.separator, lineWidth: 0.5)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    // MARK: - Actions

    /// Android's validation order, with one addition: it calls `Integer.parseInt` on the entered area
    /// and crashes on anything non-numeric.
    private func calculate() {
        guard selectedCategory != nil else {
            notice = "Choose what you are looking for"
            return
        }
        guard let sub = selectedSubCategory else {
            notice = "Choose a type of space"
            return
        }
        let trimmed = squareFeet.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            notice = "Enter the total area"
            return
        }
        guard let area = Int(trimmed), area > 0 else {
            notice = "Enter the area as a whole number of square feet"
            return
        }
        guard let rate = Int(sub.minVal), rate > 0 else {
            notice = "This type has no rate set. Please choose another."
            return
        }

        result = EstimationResult(categoryId: selectedCategoryId,
                                  categoryName: selectedCategory?.name ?? "",
                                  subCategoryId: sub.id,
                                  subCategoryName: sub.name,
                                  squareFeet: area,
                                  rate: rate)
    }

    private func requestConsultation() {
        // Android sends the user to Login here. `MainContainerViewController` observes "RequestLogin";
        // the "GoToLogin" notification the profile screen uses is only observed while that screen is up.
        guard Global.shared.isLogedIn, let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            NotificationCenter.default.post(name: .init("RequestLogin"), object: nil)
            return
        }
        showingConsultation = true
    }

    private func reset() {
        result = nil
        squareFeet = ""
        selectedSubCategoryId = ""
    }

    // MARK: - Data

    private func load() {
        guard categories.isEmpty else { return }
        state = .loading
        GCD.async(.Background) {
            LoginService.shared().getEstimationCategories { message, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        state = .noData
                        notice = message.isEmpty ? "Please try again" : message
                        return
                    }
                    categories = json["estimation_categories"].arrayValue.map(EstimationCategory.init)
                    selectedCategoryId = categories.first?.id ?? ""
                    state = categories.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Consultation request

/// Android's `estimationContactLayout` — the contact details, prefilled from the stored user, plus an
/// optional note. Submitting is the only server call in the whole estimate flow.
struct EstimationConsultationView: View {
    let result: EstimationResult
    let onSubmitted: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var note = ""
    @State private var isSubmitting = false
    @State private var notice: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Free consultation", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.m) {
                        VStack(alignment: .leading, spacing: VendorTheme.Space.s) {
                            VendorField(label: "Your estimate", value: result.formattedBudget)
                            Text("\(result.categoryName) · \(result.subCategoryName) · \(result.formattedArea)")
                                .font(VendorTheme.Text.meta)
                                .foregroundColor(VendorTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .vendorCard()

                        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                            VendorSectionHeader(title: "How to reach you")
                            field("FULL NAME", text: $fullName, placeholder: "Your name")
                            field("PHONE", text: $phone, placeholder: "Mobile number", keyboard: .phonePad)
                            field("EMAIL", text: $email, placeholder: "you@example.com", keyboard: .emailAddress)

                            VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                                label("NOTE (OPTIONAL)")
                                TextEditor(text: $note)
                                    .font(VendorTheme.Text.body)
                                    .frame(height: 100)
                                    .padding(VendorTheme.Space.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                            .fill(VendorTheme.surfaceRaised)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .vendorCard()

                        Button(action: submit) {
                            Text("Send request")
                                .font(VendorTheme.Text.cardTitle)
                                .foregroundColor(VendorTheme.onAccent)
                                .frame(maxWidth: .infinity, minHeight: VendorTheme.minTapTarget)
                                .background(
                                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                        .fill(VendorTheme.accent)
                                )
                        }
                        .buttonStyle(VendorPressStyle())
                        .disabled(isSubmitting)
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isSubmitting {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { notice != nil }, set: { _ in notice = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notice ?? "")
        }
        .onAppear(perform: prefill)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(VendorTheme.Text.label)
            .foregroundColor(VendorTheme.textTertiary)
            .tracking(0.4)
    }

    private func field(_ title: String, text: Binding<String>, placeholder: String,
                       keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            label(title)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocapitalization(keyboard == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboard == .emailAddress)
                .font(VendorTheme.Text.body)
                .padding(VendorTheme.Space.s)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
        }
    }

    /// Android fills the name field with `name + " " + surname` and sends the pair as one `full_name`.
    private func prefill() {
        guard let user = UserDefaultsManager.shared.userInfo else { return }
        if fullName.isEmpty {
            fullName = [user.name, user.surname].filter { !$0.isEmpty }.joined(separator: " ")
        }
        if phone.isEmpty { phone = user.phone }
        if email.isEmpty { email = user.email }
    }

    private func submit() {
        guard let user = UserDefaultsManager.shared.userInfo, !user.id.isEmpty else {
            notice = "Sign in to request a consultation"
            return
        }
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            notice = "Enter your full name"
            return
        }
        guard !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
            notice = "Enter your phone number"
            return
        }
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        guard !trimmedEmail.isEmpty else {
            notice = "Enter your email address"
            return
        }
        guard EstimationConsultationView.isValidEmail(trimmedEmail) else {
            notice = "Enter a valid email address"
            return
        }

        isSubmitting = true
        GCD.async(.Background) {
            LoginService.shared().submitEstimateRequest(userId: user.id,
                                                       fullName: fullName,
                                                       phone: phone,
                                                       email: trimmedEmail,
                                                       note: note,
                                                       squareFeet: "\(result.squareFeet)",
                                                       lookId: result.categoryId,
                                                       categoryId: result.subCategoryId) { message, success in
                GCD.async(.Main) {
                    isSubmitting = false
                    if success {
                        onSubmitted(message.isEmpty ? "Your request has been sent." : message)
                    } else {
                        notice = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }

    /// Android's own pattern, ported verbatim.
    static func isValidEmail(_ address: String) -> Bool {
        let pattern = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
        return address.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Models

struct EstimationCategory: Identifiable {
    let id: String
    let name: String
    let arabicName: String
    let subCategories: [EstimationSubCategory]

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.arabicName = json["arabic_name"].stringValue
        self.subCategories = json["sub_categories"].arrayValue.map(EstimationSubCategory.init)
    }
}

struct EstimationSubCategory: Identifiable {
    let id: String
    let categoryId: String
    let name: String
    let arabicName: String
    /// The per-square-foot rate, despite the name.
    let minVal: String
    let isActive: String

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.categoryId = json["category_id"].stringValue
        self.name = json["name"].stringValue
        self.arabicName = json["arabic_name"].stringValue
        self.minVal = json["min_val"].stringValue
        self.isActive = json["is_active"].stringValue
    }
}

struct EstimationResult {
    let categoryId: String
    let categoryName: String
    let subCategoryId: String
    let subCategoryName: String
    let squareFeet: Int
    let rate: Int

    var budget: Int { squareFeet * rate }

    var formattedBudget: String {
        "AED " + EstimationResult.grouped(budget)
    }

    var formattedArea: String {
        EstimationResult.grouped(squareFeet) + " Sqft"
    }

    private static func grouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
