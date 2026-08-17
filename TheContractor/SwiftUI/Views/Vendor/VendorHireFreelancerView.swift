//
//  VendorHireFreelancerView.swift
//  TheContractor
//
//  Android's `Freelancers` in vendor mode (`from=vendor`) plus the hire path that follows it.
//
//  Browse:  POST freelancing/freelancers_frontend -> `freelancers_list`
//  Filters: POST freelancing/get_freelancing_search
//  Charges: POST freelancing/transportation_charges
//  Hire:    POST freelancing/hire_freelancers
//
//  Android spreads this over several screens with a local SQLite table holding the selection. Here the
//  selection is view state: tick people on the list, book each in turn through the same sheet a single
//  hire uses, then post one `freelancer_data` array. Per-freelancer detail is preserved, which is the
//  point — each entry carries its own dates and time window.
//
//  Pick-up addresses belong to the freelancer's own profile rather than to this flow; they live in
//  `UpdateFreelancerView`, backed by `PickUpLocationPicker`.
//

import SwiftUI
import SwiftyJSON

// MARK: - Browse

/// `sheet(item:)` needs an Identifiable; the step's index is its identity, which is exactly what makes
/// SwiftUI tear the sheet down and present the next one as the batch advances.
private struct BookingStep: Identifiable {
    let index: Int
    var id: Int { index }
}

struct VendorHireFreelancerView: View {
    @State private var state: VendorLoadState = .loading
    @State private var freelancers: [VendorFreelancerListing] = []
    @State private var errorMessage: String?

    @State private var showFilter = false

    // MARK: Multi-select
    //
    // Android keeps the selection in a local SQLite table across its browse and checkout screens, then
    // posts every row as one `freelancer_data` array with a per-freelancer `detail` block. There is no
    // need for a database here, but the per-freelancer detail matters: each booking carries its own
    // dates and time window, so one sheet applied to everybody would be a different feature.
    //
    // The flow is therefore: tick people on the list, then book them one at a time in sequence,
    // accumulating entries, and send a single request at the end. That reuses the existing booking
    // sheet unchanged rather than inventing a second way to describe a booking.

    /// Ordered, so the booking sequence follows the order they were ticked.
    @State private var selection: [VendorFreelancerListing] = []
    /// Index into `selection` while stepping through the per-freelancer booking sheets.
    @State private var bookingIndex: Int?
    /// Entries built so far in the current run.
    @State private var pendingEntries: [[String: Any]] = []
    @State private var isHiringBatch = false
    @State private var noticeMessage: String?
    @State private var categories: [VendorJobFilterOption] = []
    @State private var cities: [VendorJobFilterOption] = []
    @State private var selectedCategory: VendorJobFilterOption?
    @State private var selectedCity: VendorJobFilterOption?

    private var activeFilters: Int {
        [selectedCategory != nil, selectedCity != nil].filter { $0 }.count
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VendorTopBar(title: "Freelancers",
                             trailingIcon: activeFilters > 0 ? "line.3.horizontal.decrease.circle.fill"
                                                             : "line.3.horizontal.decrease.circle",
                             trailingAction: { showFilter = true })

                ZStack {
                    VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                    switch state {
                    case .loading:
                        VendorSkeletonList()
                    case .noData:
                        VendorEmptyState(icon: "person.crop.circle.badge.questionmark",
                                         title: "No freelancers found",
                                         message: activeFilters > 0
                                            ? "Try widening the category or city filter."
                                            : "No one is listed as available right now.",
                                         actionTitle: activeFilters > 0 ? "Clear filters" : "Try again",
                                         action: {
                                             if activeFilters > 0 {
                                                 selectedCategory = nil
                                                 selectedCity = nil
                                             }
                                             reload()
                                         })
                    case .loaded:
                        ScrollView {
                            VStack(spacing: VendorTheme.Space.m) {
                                ForEach(freelancers) { freelancer in
                                    HStack(spacing: VendorTheme.Space.s) {
                                        // The checkbox is its own tap target, outside the link, so
                                        // selecting somebody and opening their profile stay separate
                                        // gestures on the same row.
                                        Button(action: { toggleSelection(freelancer) }) {
                                            Image(systemName: isSelected(freelancer)
                                                  ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22))
                                                .foregroundColor(isSelected(freelancer)
                                                                 ? VendorTheme.accent : VendorTheme.textTertiary)
                                                .frame(width: VendorTheme.minTapTarget,
                                                       height: VendorTheme.minTapTarget)
                                        }
                                        .buttonStyle(.plain)

                                        NavigationLink(destination: VendorFreelancerDetailView(freelancer: freelancer)) {
                                            VendorFreelancerCard(freelancer: freelancer)
                                        }
                                        .buttonStyle(VendorPressStyle())
                                    }
                                }
                            }
                            .padding(VendorTheme.Space.l)
                            // Clear the selection bar so the last row is not trapped underneath it.
                            .padding(.bottom, selection.isEmpty ? 0 : 72)
                        }
                        .refreshable { await refresh() }
                    }

                    if !selection.isEmpty {
                        VStack {
                            Spacer()
                            selectionBar
                        }
                    }

                    if isHiringBatch {
                        Color.black.opacity(0.2).ignoresSafeArea()
                        VendorBusyIndicator()
                    }
                }
            }
            .navigationBarHidden(true)
            // One sheet per selected freelancer, in order. Keying on the index is what makes it
            // re-present for the next person rather than staying dismissed after the first.
            //
            // Kept on this view rather than next to the filter sheet on the outer one: stacking two
            // `.sheet` modifiers on a single view is unreliable, and separating them costs nothing.
            .sheet(item: Binding(get: { bookingIndex.map { BookingStep(index: $0) } },
                                 set: { if $0 == nil { cancelBatchBooking() } })) { step in
                if step.index < selection.count {
                    let freelancer = selection[step.index]
                    VendorFreelancerBookingSheet(freelancer: freelancer) { booking in
                        appendBooking(booking, for: freelancer)
                    } onCancel: {
                        cancelBatchBooking()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showFilter) {
            VendorApplicantFilterSheet(categories: categories,
                                       cities: cities,
                                       selectedCategory: $selectedCategory,
                                       selectedCity: $selectedCity) {
                showFilter = false
                reload()
            } onCancel: {
                showFilter = false
            }
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .onAppear {
            if freelancers.isEmpty { reload() }
            if categories.isEmpty { loadFilters() }
        }
    }

    // MARK: - Selection

    private func isSelected(_ freelancer: VendorFreelancerListing) -> Bool {
        selection.contains { $0.id == freelancer.id }
    }

    private func toggleSelection(_ freelancer: VendorFreelancerListing) {
        if let index = selection.firstIndex(where: { $0.id == freelancer.id }) {
            selection.remove(at: index)
        } else {
            selection.append(freelancer)
        }
    }

    private var selectionBar: some View {
        HStack(spacing: VendorTheme.Space.m) {
            Text(selection.count == 1 ? "1 selected" : "\(selection.count) selected")
                .font(VendorTheme.Text.body)
                .foregroundColor(VendorTheme.textPrimary)

            Button("Clear") { selection.removeAll() }
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textSecondary)

            Spacer(minLength: 0)

            Button(action: startBatchBooking) {
                Text("Book")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.onAccent)
                    .padding(.horizontal, VendorTheme.Space.l)
                    .padding(.vertical, VendorTheme.Space.s)
                    .background(Capsule().fill(VendorTheme.accent))
            }
        }
        .padding(.horizontal, VendorTheme.Space.l)
        .padding(.vertical, VendorTheme.Space.m)
        .background(VendorTheme.surface.shadow(color: .black.opacity(0.12), radius: 8, y: -2))
    }

    /// Opens the booking sheet for the first selected freelancer. Each completion appends an entry and
    /// advances; the request goes out after the last one.
    private func startBatchBooking() {
        guard !selection.isEmpty else { return }
        pendingEntries = []
        bookingIndex = 0
    }

    private func appendBooking(_ booking: VendorFreelancerBooking, for freelancer: VendorFreelancerListing) {
        pendingEntries.append(booking.freelancerDataEntry(for: freelancer, transportationCharges: "0"))

        let next = (bookingIndex ?? 0) + 1
        if next < selection.count {
            bookingIndex = next
        } else {
            bookingIndex = nil
            submitBatch()
        }
    }

    private func cancelBatchBooking() {
        bookingIndex = nil
        pendingEntries = []
    }

    private func submitBatch() {
        guard let session = VendorSession.current, !session.id.isEmpty else { return }
        guard !pendingEntries.isEmpty,
              let data = try? JSONSerialization.data(withJSONObject: pendingEntries),
              let payload = String(data: data, encoding: .utf8) else {
            errorMessage = "Could not prepare the booking."
            return
        }

        let count = pendingEntries.count
        isHiringBatch = true
        GCD.async(.Background) {
            LoginService.shared().hireFreelancers(freelancerDataJSON: payload,
                                                  userId: session.user_id,
                                                  userType: session.user_type,
                                                  vendorId: session.id) { message, success in
                GCD.async(.Main) {
                    isHiringBatch = false
                    pendingEntries = []
                    if success {
                        selection.removeAll()
                        noticeMessage = message.isEmpty
                            ? (count == 1 ? "Hiring request sent." : "Hiring request sent for \(count) freelancers.")
                            : message
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }

    private func reload() {
        state = .loading
        fetch()
    }

    private func refresh() async {
        await withCheckedContinuation { continuation in
            fetch { continuation.resume() }
        }
    }

    private func fetch(then finished: (() -> Void)? = nil) {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            finished?()
            return
        }

        GCD.async(.Background) {
            // Android's vendor mode passes the company id as both vendor_id and user_id.
            LoginService.shared().getFreelancers(page: "1",
                                                skills: "",
                                                rate: "",
                                                category: selectedCategory?.id ?? "",
                                                city: selectedCity?.id ?? "",
                                                userId: session.user_id,
                                                userType: session.user_type,
                                                vendorId: session.id) { message, success, json in
                GCD.async(.Main) {
                    defer { finished?() }
                    guard success, let json = json else {
                        state = .noData
                        errorMessage = message.isEmpty ? "Please try again" : message
                        return
                    }
                    // `freelancers_list`, not `freelancers` — verified live: vendor 706 gets
                    // `{"total":1, "freelancers_list":[…]}`. Reading the wrong key meant this screen
                    // showed "No freelancers found" every time, so hiring was unreachable from here
                    // no matter who was listed.
                    freelancers = json["freelancers_list"].arrayValue.map(VendorFreelancerListing.init)
                    state = freelancers.isEmpty ? .noData : .loaded
                }
            }
        }
    }

    private func loadFilters() {
        GCD.async(.Background) {
            LoginService.shared().getFreelancerSearchFields { _, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else { return }
                    // The search payload uses the job category and city lists.
                    categories = json["job_categories"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue,
                                              name: $0["title"].exists() ? $0["title"].stringValue
                                                                         : $0["name"].stringValue)
                    }
                    cities = json["freelancer_cities"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["name"].stringValue)
                    }
                    if cities.isEmpty {
                        cities = json["job_cities"].arrayValue.map {
                            VendorJobFilterOption(id: $0["id"].stringValue, name: $0["name"].stringValue)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Detail and hire

struct VendorFreelancerDetailView: View {
    let freelancer: VendorFreelancerListing

    @State private var transportationCharges: String?
    @State private var isHiring = false
    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var showHireSheet = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Freelancer", onBack: { dismiss() })

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(spacing: VendorTheme.Space.l) {
                        headerCard
                        ratesCard
                        if !freelancer.skills.isEmpty { skillsCard }
                        availabilityCard
                        hireButton
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isHiring {
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
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(noticeMessage ?? "")
        }
        .sheet(isPresented: $showHireSheet) {
            VendorFreelancerBookingSheet(freelancer: freelancer) { booking in
                showHireSheet = false
                hire(booking)
            } onCancel: {
                showHireSheet = false
            }
        }
        .onAppear(perform: loadCharges)
    }

    private var headerCard: some View {
        HStack(spacing: VendorTheme.Space.m) {
            VendorPersonAvatar(path: freelancer.image)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 3) {
                Text(freelancer.name)
                    .font(VendorTheme.Text.screenTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                if !freelancer.categoryTitle.isEmpty {
                    Text(freelancer.categoryTitle)
                        .font(VendorTheme.Text.body)
                        .foregroundColor(VendorTheme.textSecondary)
                }
                Text([freelancer.areaName, freelancer.cityName].filter { !$0.isEmpty }.joined(separator: ", "))
                    .font(VendorTheme.Text.meta)
                    .foregroundColor(VendorTheme.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var ratesCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Rates")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "Hourly rate",
                            value: freelancer.hourlyRate.isEmpty ? "—" : "AED \(freelancer.hourlyRate)")
                VendorField(label: "Transport",
                            value: transportationCharges.map { "AED \($0)" } ?? "Checking…")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var skillsCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Skills", count: freelancer.skills.count)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: VendorTheme.Space.s)],
                      alignment: .leading, spacing: VendorTheme.Space.s) {
                ForEach(freelancer.skills, id: \.self) { skill in
                    Text(skill)
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textPrimary)
                        .lineLimit(1)
                        .padding(.horizontal, VendorTheme.Space.s)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(VendorTheme.surfaceRaised))
                        .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var availabilityCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Availability")
            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                VendorField(label: "From", value: freelancer.fromTime)
                VendorField(label: "To", value: freelancer.toTime)
            }
            if !freelancer.pickUpAddress.isEmpty {
                VendorField(label: "Pick-up", value: freelancer.pickUpAddress)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var hireButton: some View {
        Button(action: { showHireSheet = true }) {
            Text("Hire this freelancer")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    private func loadCharges() {
        guard let session = VendorSession.current, !session.id.isEmpty else { return }
        GCD.async(.Background) {
            LoginService.shared().getFreelancerTransportationCharges(freelancerId: freelancer.id,
                                                                     userId: session.user_id,
                                                                     userType: session.user_type) { _, success, json in
                GCD.async(.Main) {
                    guard success, let json = json else {
                        transportationCharges = "—"
                        return
                    }
                    // The amount has appeared under a couple of names; take whichever is present.
                    let value = [json["transportation_charges"], json["charges"], json["amount"]]
                        .first { $0.exists() }?.stringValue ?? "0"
                    transportationCharges = value
                }
            }
        }
    }

    private func hire(_ booking: VendorFreelancerBooking) {
        guard let session = VendorSession.current, !session.id.isEmpty else { return }
        guard let payload = booking.freelancerDataJSON(for: freelancer,
                                                       transportationCharges: transportationCharges ?? "0") else {
            errorMessage = "Could not prepare the booking."
            return
        }

        isHiring = true
        GCD.async(.Background) {
            LoginService.shared().hireFreelancers(freelancerDataJSON: payload,
                                                  userId: session.user_id,
                                                  userType: session.user_type,
                                                  vendorId: session.id) { message, success in
                GCD.async(.Main) {
                    isHiring = false
                    if success {
                        noticeMessage = message.isEmpty ? "Hiring request sent." : message
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Booking sheet

/// Android collects the booking across its checkout screens: hourly or daily, a time window, and one
/// or more dates. Same inputs, one sheet.
struct VendorFreelancerBookingSheet: View {
    let freelancer: VendorFreelancerListing
    let onConfirm: (VendorFreelancerBooking) -> Void
    let onCancel: () -> Void

    @State private var isHourly = true
    @State private var fromTime = Date()
    @State private var toTime = Date().addingTimeInterval(4 * 3600)
    @State private var dates: [Date] = [Date()]
    @State private var notice: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Booking", onBack: onCancel)

            ScrollView {
                VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                        VendorSectionHeader(title: "Basis")
                        Picker("", selection: $isHourly) {
                            Text("Hourly").tag(true)
                            Text("Daily").tag(false)
                        }
                        .pickerStyle(.segmented)

                        if isHourly {
                            HStack(alignment: .top, spacing: VendorTheme.Space.m) {
                                timeField("From", selection: $fromTime)
                                timeField("To", selection: $toTime)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()

                    VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
                        VendorSectionHeader(title: "Dates", count: dates.count)

                        ForEach(Array(dates.enumerated()), id: \.offset) { index, _ in
                            HStack {
                                DatePicker("", selection: Binding(get: { dates[index] },
                                                                  set: { dates[index] = $0 }),
                                           in: Date()...,
                                           displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()

                                Spacer(minLength: 0)

                                if dates.count > 1 {
                                    Button(action: { dates.remove(at: index) }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(VendorTheme.negative)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        Button(action: { dates.append(dates.last ?? Date()) }) {
                            Label("Add a date", systemImage: "plus.circle")
                                .font(VendorTheme.Text.meta)
                                .foregroundColor(VendorTheme.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .vendorCard()

                    Button(action: confirm) {
                        Text("Confirm booking")
                            .font(VendorTheme.Text.cardTitle)
                            .foregroundColor(VendorTheme.onAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VendorTheme.Space.m)
                            .background(
                                RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                                    .fill(VendorTheme.accent)
                            )
                    }
                    .buttonStyle(VendorPressStyle())
                }
                .padding(VendorTheme.Space.l)
            }
            .background(VendorTheme.canvas)
        }
        .alert("", isPresented: Binding(get: { notice != nil }, set: { _ in notice = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notice ?? "")
        }
    }

    private func timeField(_ label: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text(label.uppercased())
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)
            DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func confirm() {
        guard !dates.isEmpty else {
            notice = "Add at least one date"
            return
        }
        if isHourly && toTime <= fromTime {
            notice = "The end time must be after the start time"
            return
        }
        onConfirm(VendorFreelancerBooking(isHourly: isHourly,
                                          fromTime: fromTime,
                                          toTime: toTime,
                                          dates: dates.sorted()))
    }
}

// MARK: - Models

/// Android `FreelancerListModel`, reduced to what this flow reads.
struct VendorFreelancerListing: Identifiable {
    let id: String
    let uuid: String
    let userId: String
    let name: String
    let image: String
    let hourlyRate: String
    let fromTime: String
    let toTime: String
    let pickUpAddress: String
    let categoryId: String
    let categoryTitle: String
    let cityId: String
    let cityName: String
    let areaName: String
    let skills: [String]

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.uuid = json["uuid"].stringValue
        self.userId = json["user_id"].stringValue
        self.name = json["name"].stringValue
        self.image = json["image"].stringValue
        self.hourlyRate = json["hourly_rate"].stringValue
        self.fromTime = json["from_time"].stringValue
        self.toTime = json["to_time"].stringValue
        self.pickUpAddress = json["pick_up_address"].stringValue
        self.categoryId = json["job_category"].stringValue
        self.categoryTitle = json["job_category_title"].stringValue
        self.cityId = json["city_id"].stringValue
        self.cityName = json["city_name"].stringValue
        self.areaName = json["area_name"].stringValue
        self.skills = json["skills"].arrayValue.map {
            $0["title"].exists() ? $0["title"].stringValue : $0["name"].stringValue
        }.filter { !$0.isEmpty }
    }
}

/// What the booking sheet collects, plus the encoder for `freelancer_data`.
struct VendorFreelancerBooking {
    let isHourly: Bool
    let fromTime: Date
    let toTime: Date
    let dates: [Date]

    /// Mirrors Android's `SelectedFreelancersDatabaseModel` — the object it hands to
    /// `new Gson().toJson(list)` — including the nested `detail` and its `dates` array. Sent as a
    /// one-element array, which is what `hire_freelancers` expects a single booking to look like.
    /// One freelancer's entry. Split out from `freelancerDataJSON` so a batch can collect several and
    /// serialise them as one array — the endpoint has always taken an array; only the UI was singular.
    func freelancerDataEntry(for freelancer: VendorFreelancerListing,
                             transportationCharges: String) -> [String: Any] {
        let time = DateFormatter()
        time.locale = Locale(identifier: "en_US_POSIX")
        time.dateFormat = "HH:mm"

        let day = DateFormatter()
        day.locale = Locale(identifier: "en_US_POSIX")
        day.dateFormat = "yyyy-MM-dd"

        let entry: [String: Any] = [
            "id": freelancer.id,
            "uuid": freelancer.uuid,
            "cityId": freelancer.cityId,
            "name": freelancer.name,
            "image": freelancer.image,
            "category": freelancer.categoryId,
            "hourlyRate": freelancer.hourlyRate,
            "commission": "",
            "city": freelancer.cityName,
            "area": freelancer.areaName,
            "transportation_charges": transportationCharges,
            "detail": [
                // Android stores these as strings, so a "1"/"0" flag rather than a JSON boolean.
                "isHourly": isHourly ? "1" : "0",
                "fromTime": isHourly ? time.string(from: fromTime) : freelancer.fromTime,
                "toTime": isHourly ? time.string(from: toTime) : freelancer.toTime,
                "isPicked": "0",
                "dates": dates.map { ["date": day.string(from: $0)] }
            ]
        ]

        return entry
    }

    func freelancerDataJSON(for freelancer: VendorFreelancerListing,
                            transportationCharges: String) -> String? {
        let entry = freelancerDataEntry(for: freelancer, transportationCharges: transportationCharges)
        guard let data = try? JSONSerialization.data(withJSONObject: [entry]) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Card

struct VendorFreelancerCard: View {
    let freelancer: VendorFreelancerListing

    var body: some View {
        HStack(spacing: VendorTheme.Space.m) {
            VendorPersonAvatar(path: freelancer.image)

            VStack(alignment: .leading, spacing: 2) {
                Text(freelancer.name)
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)

                if !freelancer.categoryTitle.isEmpty {
                    Text(freelancer.categoryTitle)
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.textSecondary)
                }

                if !freelancer.hourlyRate.isEmpty {
                    Text("AED \(freelancer.hourlyRate) / hour")
                        .font(VendorTheme.Text.meta)
                        .foregroundColor(VendorTheme.accent)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(VendorTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }
}
