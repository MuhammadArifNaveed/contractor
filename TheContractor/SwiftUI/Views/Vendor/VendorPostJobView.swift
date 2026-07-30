//
//  VendorPostJobView.swift
//  TheContractor
//
//  Port of Android's `VendorPostJob`, which serves both create and edit — `jobs/post_job` and
//  `jobs/update_job` take identical parts except that the update adds `job_id`.
//
//  Reached from the jobs dashboard toolbar (create) and from a row's Edit action (edit), matching
//  Android's `VendorJobListingAdapter`.
//

import SwiftUI
import SwiftyJSON

struct VendorPostJobView: View {
    /// nil creates, non-nil edits.
    var existing: VendorJobRow?

    @State private var title = ""
    @State private var arabicTitle = ""
    @State private var vacancies = ""
    @State private var salary = ""
    @State private var descriptionText = ""
    @State private var arabicDescription = ""
    @State private var deadline = Date()
    @State private var hasDeadline = false

    @State private var categories: [VendorJobFilterOption] = []
    @State private var cities: [VendorJobFilterOption] = []
    @State private var jobTypes: [String] = []
    @State private var selectedCategory: VendorJobFilterOption?
    @State private var selectedCity: VendorJobFilterOption?
    @State private var selectedType: String?

    @State private var jobImage: UIImage?
    @State private var showPhotoPicker = false

    @State private var isLoadingFields = true
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var savedMessage: String?

    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool { existing != nil }

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: isEditing ? "Edit Job" : "Post a Job", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                        basicsCard
                        classificationCard
                        detailCard
                        imageCard
                        saveButton
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isSaving {
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
        // Dismiss on success, so the listing behind reloads to show the change.
        .alert("", isPresented: Binding(get: { savedMessage != nil }, set: { _ in savedMessage = nil })) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(savedMessage ?? "")
        }
        .sheet(isPresented: $showPhotoPicker) {
            VendorPhotoPicker(selectionLimit: 1) { picked in
                jobImage = picked.first
            }
        }
        .onAppear(perform: prepare)
    }

    /// jobs/post_job and jobs/update_job both accept one optional image part.
    private var imageCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Image")

            Text("Optional. Shown alongside the listing.")
                .font(VendorTheme.Text.meta)
                .foregroundColor(VendorTheme.textSecondary)

            if let jobImage = jobImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: jobImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control,
                                                    style: .continuous))

                    Button(action: { self.jobImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    }
                    .padding(VendorTheme.Space.s)
                }
            }

            Button(action: { showPhotoPicker = true }) {
                Label(jobImage == nil ? "Add an image" : "Replace image",
                      systemImage: "photo.on.rectangle.angled")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                    .padding(.horizontal, VendorTheme.Space.l)
                    .padding(.vertical, VendorTheme.Space.s)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
                    .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
            }
            .buttonStyle(VendorPressStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    // MARK: - Sections

    private var basicsCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Basics")
            field("Job title", text: $title, placeholder: "Site Engineer")
            field("Job title (Arabic)", text: $arabicTitle, placeholder: "Optional")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                field("Vacancies", text: $vacancies, placeholder: "1", keyboard: .numberPad)
                field("Salary", text: $salary, placeholder: "5000", keyboard: .numbersAndPunctuation)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var classificationCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Classification")

            if isLoadingFields {
                VendorSkeleton(height: 30)
                VendorSkeleton(height: 30)
            } else {
                labelled("Category") {
                    VendorChipRow(options: categories, selection: $selectedCategory)
                }
                labelled("Location") {
                    VendorChipRow(options: cities, selection: $selectedCity)
                }
                labelled("Job type") {
                    // job_types comes back with only a `type` string and no id, so the value posted
                    // is the label itself.
                    VendorChipRow(options: jobTypes.map { VendorJobFilterOption(id: $0, name: $0) },
                                  selection: Binding(
                                    get: { selectedType.map { VendorJobFilterOption(id: $0, name: $0) } },
                                    set: { selectedType = $0?.id }))
                }
            }

            Toggle(isOn: $hasDeadline) {
                Text("Set a deadline")
                    .font(VendorTheme.Text.body)
                    .foregroundColor(VendorTheme.textPrimary)
            }
            .tint(VendorTheme.accent)

            if hasDeadline {
                DatePicker("", selection: $deadline, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Description")
            editor("Description", text: $descriptionText)
            editor("Description (Arabic)", text: $arabicDescription)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var saveButton: some View {
        Button(action: save) {
            Text(isEditing ? "Save changes" : "Post job")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    // MARK: - Field builders

    private func field(_ label: String, text: Binding<String>, placeholder: String,
                       keyboard: UIKeyboardType = .default) -> some View {
        labelled(label) {
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(VendorTheme.Text.body)
                .padding(VendorTheme.Space.s)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
        }
    }

    private func editor(_ label: String, text: Binding<String>) -> some View {
        labelled(label) {
            TextEditor(text: text)
                .frame(height: 100)
                .padding(VendorTheme.Space.xs)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.surfaceRaised)
                )
        }
    }

    private func labelled<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text(label.uppercased())
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Data

    private func prepare() {
        if let existing = existing {
            // The listing row already carries everything the form needs, so editing opens populated
            // without a second fetch.
            if title.isEmpty {
                title = existing.title
                vacancies = existing.vacancies
                salary = existing.salary
                descriptionText = existing.description
                if let parsed = VendorPostJobView.parseDeadline(existing.deadline) {
                    deadline = parsed
                    hasDeadline = true
                }
            }
        }
        if categories.isEmpty { loadFields() }
    }

    private func loadFields() {
        isLoadingFields = true
        GCD.async(.Background) {
            LoginService.shared().getJobSearchFields { message, success, json in
                GCD.async(.Main) {
                    isLoadingFields = false
                    guard success, let json = json else {
                        errorMessage = message.isEmpty ? "Could not load job options." : message
                        return
                    }
                    categories = json["job_categories"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["title"].stringValue)
                    }
                    cities = json["job_cities"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["name"].stringValue)
                    }
                    jobTypes = json["job_types"].arrayValue.map { $0["type"].stringValue }
                        .filter { !$0.isEmpty }

                    preselectFromExisting()
                }
            }
        }
    }

    /// Match the row's names back onto the freshly loaded option lists — the listing response gives
    /// display names, not the ids the form needs to post.
    private func preselectFromExisting() {
        guard let existing = existing else { return }
        if selectedCategory == nil {
            selectedCategory = categories.first { $0.name == existing.categoryName }
        }
        if selectedCity == nil {
            selectedCity = cities.first { $0.name == existing.locationName }
        }
        if selectedType == nil {
            selectedType = jobTypes.first { $0 == existing.jobType }
        }
    }

    private static func parseDeadline(_ raw: String) -> Date? {
        guard !raw.isEmpty else { return nil }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        for pattern in ["yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss"] {
            input.dateFormat = pattern
            if let date = input.date(from: raw) { return date }
        }
        return nil
    }

    private static func formatDeadline(_ date: Date) -> String {
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.dateFormat = "yyyy-MM-dd"
        return out.string(from: date)
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Enter a job title"
            return
        }
        guard !vacancies.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter the number of vacancies"
            return
        }
        guard let category = selectedCategory else {
            errorMessage = "Select a category"
            return
        }
        guard let city = selectedCity else {
            errorMessage = "Select a location"
            return
        }
        guard let type = selectedType else {
            errorMessage = "Select a job type"
            return
        }
        guard let session = VendorSession.current, !session.id.isEmpty else { return }

        isSaving = true
        GCD.async(.Background) {
            LoginService.shared().saveVendorJob(
                jobId: existing?.id,
                title: trimmedTitle,
                arabicTitle: arabicTitle,
                vacancies: vacancies,
                description: descriptionText,
                arabicDescription: arabicDescription,
                salary: salary,
                categoryId: category.id,
                locationId: city.id,
                jobType: type,
                deadline: hasDeadline ? VendorPostJobView.formatDeadline(deadline) : "",
                vendorId: session.id,
                userId: session.user_id,
                userType: session.user_type,
                imageData: jobImage?.vendorUploadJPEG()
            ) { message, success in
                GCD.async(.Main) {
                    isSaving = false
                    if success {
                        savedMessage = message.isEmpty
                            ? (isEditing ? "Job updated." : "Job posted.")
                            : message
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}
