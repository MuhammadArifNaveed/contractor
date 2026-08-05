import SwiftUI
import SwiftyJSON

// MARK: - Public Freelancers Screen (side menu → Freelancers, from=user)

struct FreelancersView: View {
    @StateObject private var vm = FreelancersViewModel()
    @State private var selectedFreelancer: FreelancerItem?
    @State private var showCheckout = false

    private let yellow = VendorTheme.accent

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: 0) {
                    Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(VendorTheme.onAccent)
                            .frame(width: 44, height: 44)
                    }
                    Text("Freelancers")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(VendorTheme.onAccent)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .frame(height: 56)
                .background(yellow)

                if vm.isLoading && vm.items.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if vm.items.isEmpty && !vm.isLoading {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.2")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Freelancers Found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.items) { item in
                                FreelancerPublicCard(item: item, onHire: {
                                    if Global.shared.isLogedIn {
                                        selectedFreelancer = item
                                    }
                                })
                                .padding(.horizontal, 12)
                                .onAppear {
                                    if item.id == vm.items.last?.id {
                                        vm.loadMore()
                                    }
                                }
                            }
                            if vm.isLoading {
                                ProgressView().padding()
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.bottom, vm.cartCount > 0 ? 70 : 0)
                    }
                }
            }

            // Selected freelancer list button (like Android selectedFreelancerList button)
            if vm.cartCount > 0 {
                Button(action: { showCheckout = true }) {
                    HStack {
                        Spacer()
                        Text("Selected Freelancer List (\(vm.cartCount))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(yellow)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear { vm.load() }
        .sheet(item: $selectedFreelancer) { freelancer in
            FreelancerSelectionDialog(
                freelancer: freelancer.toViewModel(),
                onAddToList: { selection in
                    FreelancerCartManager.shared.addFreelancer(selection)
                    vm.refreshCart()
                    selectedFreelancer = nil
                },
                onDismiss: { selectedFreelancer = nil }
            )
        }
        .sheet(isPresented: $showCheckout) {
            FreelancerCheckoutView(onDismiss: { showCheckout = false })
        }
    }
}

// MARK: - Card

private struct FreelancerPublicCard: View {
    let item: FreelancerItem
    let onHire: () -> Void
    private let yellow = VendorTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "person.fill").foregroundColor(.gray))

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text("\(item.hourlyRate)/hr")
                            .font(.system(size: 14, weight: .medium))
                    }
                    if !item.category.isEmpty {
                        Text(item.category)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }

            if !item.skills.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.skills, id: \.self) { skill in
                            Text(skill)
                                .font(.system(size: 12))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(yellow.opacity(0.15))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse").font(.system(size: 13)).foregroundColor(.gray)
                Text(item.location).font(.system(size: 13)).foregroundColor(.gray).lineLimit(1)
                Spacer()
                Image(systemName: "clock").font(.system(size: 13)).foregroundColor(.gray)
                Text(item.workingHours).font(.system(size: 13)).foregroundColor(.gray).lineLimit(1)
            }

            if !item.memberSince.isEmpty {
                Text("Member since \(item.memberSince)").font(.system(size: 12)).foregroundColor(.secondary)
            }

            HStack {
                // Stars
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(item.rating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(yellow)
                    }
                    Text("(\(item.reviewCount))").font(.system(size: 12)).foregroundColor(.gray)
                }
                Spacer()
                Button(action: onHire) {
                    Text("Hire")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16).padding(.vertical, 7)
                        .background(yellow)
                        .cornerRadius(4)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Model

struct FreelancerItem: Identifiable {
    let id: String
    let uuid: String
    let userId: String
    let name: String
    let category: String
    let hourlyRate: String
    let imageUrl: String
    let skills: [String]
    let location: String
    let workingHours: String
    let memberSince: String
    let rating: Double
    let reviewCount: Int
    let availability: String
    let cityId: String
    let commission: String
    let fromTime: String
    let toTime: String
    let isHourly: String

    func toViewModel() -> FreelancerViewModel {
        let vm = FreelancerViewModel()
        vm.id = id
        vm.uuid = uuid
        vm.name = name
        vm.profession = category
        vm.hourlyRate = hourlyRate
        vm.profileImage = imageUrl
        vm.skills = skills
        vm.location = location
        vm.workingHours = workingHours
        vm.memberSince = memberSince
        vm.rating = rating
        vm.reviewCount = reviewCount
        vm.availability = availability
        vm.cityId = cityId
        vm.commission = commission
        vm.fromTime = fromTime
        vm.toTime = toTime
        vm.isHourly = isHourly
        return vm
    }
}

// MARK: - ViewModel

final class FreelancersViewModel: ObservableObject {
    @Published var items: [FreelancerItem] = []
    @Published var isLoading = false
    @Published var cartCount = 0

    private var currentPage = 1
    private var lastPage = 0
    private var isLastPage = false

    private let apiURL = "https://contractor.bidcont.com/rest/freelancing/freelancers_frontend"

    func load() {
        guard !isLoading else { return }
        currentPage = 1
        lastPage = 0
        isLastPage = false
        items = []
        refreshCart()
        fetchPage(page: 1)
    }

    func loadMore() {
        guard !isLoading, !isLastPage else { return }
        fetchPage(page: currentPage)
    }

    func refreshCart() {
        cartCount = FreelancerCartManager.shared.selectedFreelancers.count
    }

    private func fetchPage(page: Int) {
        isLoading = true

        let userId = Global.shared.user?.id ?? ""
        let vendorId = ""
        let userType = Global.shared.isVendor ? "company" : "user"

        let params: [String: Any] = [
            "page": String(page),
            "skills": "",
            "rate": "",
            "category": "",
            "city": "",
            "user_id": userId,
            "user_type": userType,
            "vendor_id": vendorId
        ]

        LoginService.shared().makePostAPICall(with: apiURL, params: params) { [weak self] message, success, json, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json = json {
                    let list = json["freelancers_list"].arrayValue
                    self.lastPage = json["total_page"].intValue
                    let parsed = list.map { f in FreelancerItem(
                        id: f["id"].stringValue,
                        uuid: f["uuid"].stringValue,
                        userId: f["user_id"].stringValue,
                        name: f["name"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                        category: f["job_category_title"].stringValue,
                        hourlyRate: f["hourly_rate"].stringValue,
                        imageUrl: f["image"].stringValue,
                        skills: f["skills"].arrayValue.map { $0["skill_title"].stringValue },
                        location: [f["area_name"].stringValue, f["city_name"].stringValue]
                            .filter { !$0.isEmpty }.joined(separator: " , "),
                        workingHours: Self.formatTimeRange(from: f["from_time"].stringValue, to: f["to_time"].stringValue),
                        memberSince: Self.formatDate(f["created_at"].stringValue),
                        rating: f["rating"].doubleValue,
                        reviewCount: f["review_count"].intValue,
                        availability: f["availability"].stringValue,
                        cityId: f["city_id"].stringValue,
                        commission: f["commission"].stringValue,
                        fromTime: f["from_time"].stringValue,
                        toTime: f["to_time"].stringValue,
                        isHourly: f["is_hourly"].stringValue
                    )}
                    self.items.append(contentsOf: parsed)
                    self.isLastPage = page >= self.lastPage
                    if !self.isLastPage { self.currentPage = page + 1 }
                }
            }
        }
    }

    private static func formatTimeRange(from: String, to: String) -> String {
        let f = formatTime(from); let t = formatTime(to)
        guard !f.isEmpty, !t.isEmpty else { return "" }
        return "\(f) to \(t)"
    }

    private static func formatTime(_ v: String) -> String {
        guard !v.isEmpty else { return "" }
        let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.dateFormat = "HH:mm:ss"
        if let d = df.date(from: v) { df.dateFormat = "h:mm a"; return df.string(from: d) }
        return v
    }

    private static func formatDate(_ v: String) -> String {
        guard !v.isEmpty else { return "" }
        let df = DateFormatter(); df.locale = Locale(identifier: "en_US_POSIX"); df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let d = df.date(from: v.trimmingCharacters(in: .whitespacesAndNewlines)) {
            df.dateFormat = "dd MMM yyyy"; return df.string(from: d)
        }
        return v
    }
}
