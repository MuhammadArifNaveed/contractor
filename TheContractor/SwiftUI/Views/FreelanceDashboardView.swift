import SwiftUI
import SwiftyJSON
import Alamofire

struct FreelanceDashboardView: View {
    let onBack: (() -> Void)?

    /// Dashboard segments differ for normal users vs company users.
    private enum Segment: Identifiable {
        // User mode segments
        case userDashboard
        case userHiredFreelancer
        case userMeAsFreelancer
        case userWallet

        // Company mode segments
        case companyDashboard
        case companyFreelancers
        case companyHiredFreelancers
        case companyOrders
        case companyWallet
        case companyHireFreelancer
        case companyRegisterFreelancer

        var id: String {
            title
        }

        var title: String {
            switch self {
            case .userDashboard: return "Dashboard"
            case .userHiredFreelancer: return "Hired Freelancer"
            case .userMeAsFreelancer: return "Me as a freelancer"
            case .userWallet: return "Wallet"
            case .companyDashboard: return "Dashboard"
            case .companyFreelancers: return "Company Freelancers"
            case .companyHiredFreelancers: return "Hired Freelancers"
            case .companyOrders: return "Freelancing Orders"
            case .companyWallet: return "Wallet"
            case .companyHireFreelancer: return "Hire a Freelancer"
            case .companyRegisterFreelancer: return "Register a Freelancer"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment: Segment = .userDashboard
    @State private var pushedSegment: Segment?
    @State private var isShowingUpdateFreelancer: Bool = false

    @StateObject private var dashboardVM = FreelancingDashboardViewModel()

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
        // Initial segment depends on login type
        if Global.shared.loginType == "company" {
            _selectedSegment = State(initialValue: .companyDashboard)
        } else {
            _selectedSegment = State(initialValue: .userDashboard)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    navigationBar
                    segmentBar
                    dashboardContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(pushNavigationLink)
            .background(updateFreelancerNavigationLink)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var updateFreelancerNavigationLink: some View {
        NavigationLink(
            destination: UpdateFreelancerView(),
            isActive: $isShowingUpdateFreelancer
        ) {
            EmptyView()
        }
        .hidden()
    }

    private var pushNavigationLink: some View {
        NavigationLink(
            destination: pushedDestination,
            isActive: Binding(
                get: { pushedSegment != nil },
                set: { isActive in
                    if !isActive {
                        // Always reset to the base dashboard segment for the
                        // current login mode when a pushed view is dismissed.
                        selectedSegment = Global.shared.loginType == "company" ? .companyDashboard : .userDashboard
                        pushedSegment = nil
                    }
                }
            )
        ) {
            EmptyView()
        }
        .hidden()
    }

    @ViewBuilder
    private var pushedDestination: some View {
        if let segment = pushedSegment {
            switch segment {
            case .userHiredFreelancer, .companyHiredFreelancers:
                HiredFreelancerSummaryView()

            case .userMeAsFreelancer, .companyOrders:
                FreelancingOrdersView(freelancer: nil)

            case .userWallet, .companyWallet:
                FreelanceWalletView()

            case .companyFreelancers:
                CompanyFreelancersListView()

            case .companyHireFreelancer:
                CompanyHireFreelancerWrapperView()

            case .companyRegisterFreelancer:
                UpdateFreelancerView(mode: .registerCompany)

            case .userDashboard, .companyDashboard:
                EmptyView()
            }
        }
        else {
            EmptyView()
        }
    }

    private var isCompanyMode: Bool {
        Global.shared.loginType == "company"
    }

    private var navigationBar: some View {
        HStack(spacing: 0) {
            Button(action: {
                if let onBack {
                    onBack()
                }
                else {
                    dismiss()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text("Freelancer Dashboard")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }

    /// Segments available for the current login mode.
    private var availableSegments: [Segment] {
        if isCompanyMode {
            return [
                .companyDashboard,
                .companyFreelancers,
                .companyHiredFreelancers,
                .companyOrders,
                .companyWallet,
                .companyHireFreelancer,
                .companyRegisterFreelancer
            ]
        } else {
            return [
                .userDashboard,
                .userHiredFreelancer,
                .userMeAsFreelancer,
                .userWallet
            ]
        }
    }

    private var segmentBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(availableSegments.enumerated()), id: \.element.id) { index, segment in
                    Button(action: {
                        selectedSegment = segment

                        // Only some segments push a new screen; dashboard segments
                        // show inline content.
                        switch segment {
                        case .userDashboard, .companyDashboard:
                            pushedSegment = nil
                        default:
                            pushedSegment = segment
                        }
                    }) {
                        Text(segment.title)
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(.black)
                            .frame(height: 44)
                            .padding(.horizontal, 16)
                            .background(selectedSegment == segment ? AppTheme.Colors.primary.opacity(0.35) : AppTheme.Colors.primary.opacity(0.20))
                            .overlay(alignment: .bottom) {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(height: selectedSegment == segment ? 2 : 0)
                            }
                    }
                    .buttonStyle(.plain)

                    if index != availableSegments.count - 1 {
                        Rectangle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: 1, height: 30)
                            .padding(.horizontal, 0)
                    }
                }
            }
            .background(AppTheme.Colors.primary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small)
        }
        .background(AppTheme.Colors.primary)
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                // In user mode we show the availability row; in company mode
                // the dashboard only displays metrics.
                // Availability row hidden
                /*
                if !isCompanyMode {
                    availabilityRow
                }
                */

                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text("Freelancing Dashboard")
                        .font(AppTheme.Fonts.semibold(18))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if dashboardVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 120)
                    }
                    else {
                        metricsGrid(items: dashboardVM.metrics.map { ($0.name, $0.count) })
                    }
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.secondaryBackground)
        .onAppear {
            dashboardVM.load()
        }
    }

    private var availabilityRow: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Text(dashboardVM.isAvailableAsFreelancer ? "I am available as freelancer." : "I am not available as freelancer.")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            // Edit button hidden
            /*
            Button(action: {
                isShowingUpdateFreelancer = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .medium))
                    Text("Edit")
                        .font(AppTheme.Fonts.medium(14))
                }
                .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .buttonStyle(.plain)
            */
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func metricsGrid(items: [(title: String, value: String)]) -> some View {
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: AppTheme.Spacing.small),
            GridItem(.flexible(), spacing: AppTheme.Spacing.small),
            GridItem(.flexible(), spacing: AppTheme.Spacing.small)
        ]

        return LazyVGrid(columns: columns, alignment: .center, spacing: AppTheme.Spacing.small) {
            ForEach(items.indices, id: \.self) { idx in
                MetricCard(title: items[idx].title, value: items[idx].value)
            }
        }
    }

}

final class FreelancingService: BaseService {
    static let shared = FreelancingService()

    private override init() {
        super.init()
    }

    private func defaultIdentityParams() -> [String: String] {
        // Build identity from the current logged-in session. Supports both
        // normal users and company (vendor) users.
        // Company vendor login temporarily disabled
        // if Global.shared.loginType == "company", let vendor = Global.shared.companyVendor {
        //     let userId = vendor.userId.isEmpty ? vendor.id : vendor.userId
        //     return [
        //         "user_id": userId,
        //         "user_type": "companies",
        //         "vendor_id": vendor.id
        //     ]
        // } else 
        if let user = Global.shared.user {
            let userId = user.id
            let userType = user.userType.isEmpty ? "users" : user.userType
            return [
                "user_id": userId,
                "user_type": userType,
                "vendor_id": userId
            ]
        }

        return [:]
    }

    func fetchFreelancingDashboard(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        // Companies use `freelancing_dashboard`, normal users use
        // `user_freelancing_dashboard`.
        let path: String = Global.shared.loginType == "company"
            ? "freelancing/freelancing_dashboard"
            : "freelancing/user_freelancing_dashboard"
        let completeURL = EndPoints.BASE_URL + path

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    func fetchHiredFreelancersSummary(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/hired_freelancers_summary"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    func fetchHiredFreelancers(batchId: String, completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        var params = defaultIdentityParams()
        params["batch_id"] = batchId
        let completeURL = EndPoints.BASE_URL + "freelancing/hired_freelancers"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    func fetchFreelancingOrders(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/freelancing_orders"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Change order status for a freelancing order.
    /// type = 1 (accept), 2 (reject)
    func changeFreelancingOrderStatus(orderId: String, type: Int, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/change_order_status"
        var params = defaultIdentityParams()
        params["order_id"] = orderId
        params["type"] = String(type)

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            guard success, let json = json else {
                completion(message, false)
                return
            }
            // API returns { status: Bool, error: Bool, message: String }
            let apiStatus = json["status"].boolValue
            let apiError = json["error"].boolValue
            if apiStatus && !apiError {
                completion(json["message"].stringValue.isEmpty ? message : json["message"].stringValue, true)
            } else {
                completion(json["message"].stringValue.isEmpty ? message : json["message"].stringValue, false)
            }
        }
    }

    func fetchWallet(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/wallet"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Registers a new company freelancer with optional image and video.
    func registerCompanyFreelancer(params: [String: String], imageData: Data?, videoData: Data?, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/register_company_freelancer"

        self.makePostAPICallWithMultipartWithFiles(with: completeURL, params: params, imageData: imageData, videoData: videoData) { message, success, jsonData in
            completion(message, success)
        }
    }

    /// Adds an address for an existing freelancer.
    func addFreelancerAddress(freelancerId: String,
                              address: String,
                              pickUpAddress: String,
                              latitude: String,
                              longitude: String,
                              current: Bool,
                              completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/add_freelancer_address"
        var params = defaultIdentityParams()
        params["freelancer_id"] = freelancerId
        params["address"] = address
        params["pick_up_address"] = pickUpAddress
        params["pick_up_latitude"] = latitude
        params["pick_up_longitude"] = longitude
        params["current"] = current ? "1" : "0"

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Fetches all addresses for a freelancer.
    func fetchFreelancerAddresses(freelancerId: String,
                                  completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/get_freelancer_addresses"
        var params = defaultIdentityParams()
        params["freelancer_id"] = freelancerId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Deletes a freelancer address by id.
    func deleteFreelancerAddress(addressId: String,
                                 completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/delete_freelancer_address"
        var params = defaultIdentityParams()
        params["address_id"] = addressId
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Fetches freelancing search metadata for dropdowns (cities/areas, categories, skills).
    func fetchFreelancingSearch(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/get_freelancing_search"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Company-specific list of freelancers owned by the logged-in vendor.
    func fetchCompanyFreelancersList(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/freelancers_list"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
        }
    }

    /// Updates the "available as freelancer" status for a company freelancer.
    func updateCompanyFreelancerStatus(freelancerId: String, isChecked: Bool, completion: @escaping (_ message: String, _ success: Bool, _ available: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/update_company_freelancer_status"
        var params = defaultIdentityParams()
        params["freelancer_id"] = freelancerId
        params["is_checked"] = isChecked ? "1" : "0"

        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let available = json["available"].boolValue
                completion(message, true, available)
            } else {
                completion(message, false, false)
            }
        }
    }
    
    // MARK: - Freelancer Hiring APIs
    
    /// Updates user job status (availability) for a freelancer.
    /// - Parameters:
    ///   - uuid: The freelancer's UUID
    ///   - completion: Callback with message, success status, and new status
    func updateUserJobStatus(uuid: String, completion: @escaping (_ message: String, _ success: Bool, _ status: String) -> Void) {
        let completeURL = EndPoints.BASE_URL + "jobs/update_user_job_status"
        let params: [String: String] = ["uuid": uuid]
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let status = json["data"]["status"].stringValue
                let apiMessage = json["message"].stringValue
                completion(apiMessage.isEmpty ? message : apiMessage, true, status)
            } else {
                completion(message, false, "")
            }
        }
    }
    
    /// Fetches transportation charges for hiring a freelancer.
    /// - Parameters:
    ///   - freelancerId: The freelancer's ID
    ///   - completion: Callback with message, success, cost, and discount
    func fetchTransportationCharges(freelancerId: String, completion: @escaping (_ message: String, _ success: Bool, _ cost: Double, _ discount: Double) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/transportation_charges"
        var params = defaultIdentityParams()
        params["freelancer_id"] = freelancerId
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let cost = json["charges"]["cost"].doubleValue
                let discount = json["charges"]["discount"].doubleValue
                let apiMessage = json["message"].stringValue
                completion(apiMessage.isEmpty ? message : apiMessage, true, cost, discount)
            } else {
                completion(message, false, 0, 0)
            }
        }
    }
    
    /// Hires multiple freelancers.
    /// - Parameters:
    ///   - freelancerDataJSON: JSON string array of freelancer selection data
    ///   - completion: Callback with message and success status
    func hireFreelancers(freelancerDataJSON: String, completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/hire_freelancers"
        var params = defaultIdentityParams()
        params["freelancer_id"] = freelancerDataJSON
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: params, isImageData: false) { message, success, json in
            if success, let json = json {
                let apiStatus = json["status"].boolValue
                let apiError = json["error"].boolValue
                let apiMessage = json["message"].stringValue
                if apiStatus && !apiError {
                    completion(apiMessage.isEmpty ? message : apiMessage, true)
                } else {
                    completion(apiMessage.isEmpty ? message : apiMessage, false)
                }
            } else {
                completion(message, false)
            }
        }
    }
}

struct FreelancingDashboardMetric: Identifiable, Hashable {
    let id: Int
    let name: String
    let count: String

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
        self.count = json["count"].stringValue
    }
}

final class FreelancingDashboardViewModel: ObservableObject {
    @Published var metrics: [FreelancingDashboardMetric] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isAvailableAsFreelancer: Bool = false

    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchFreelancingDashboard { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    if json["user_freelancing_dashboard"].exists() {
                        // User mode structure
                        let root = json["user_freelancing_dashboard"]
                        let freelancerMetrics = root["as_freelancer"].arrayValue.map { FreelancingDashboardMetric(json: $0) }
                        let bossMetrics = root["as_boss_details"].arrayValue.map { FreelancingDashboardMetric(json: $0) }

                        // Combine both arrays for display
                        self.metrics = freelancerMetrics + bossMetrics

                        // Update availability status
                        let availabilityValue = root["is_available_as_freelance"].stringValue
                        self.isAvailableAsFreelancer = availabilityValue == "1"
                    } else if json["freelancing_dashboard"].exists() {
                        // Company mode structure – simple metrics array
                        self.metrics = json["freelancing_dashboard"].arrayValue.map { FreelancingDashboardMetric(json: $0) }
                        self.isAvailableAsFreelancer = false
                    } else {
                        self.metrics = []
                    }
                }
                else {
                    self.errorMessage = message
                    self.metrics = []
                }
            }
        }
    }
}

private struct FreelanceDashboardPlaceholderView: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)

                    Text(title)
                        .font(AppTheme.Fonts.title)
                        .foregroundColor(.white)
                        .padding(.leading, 8)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
                .background(AppTheme.Colors.primary)

                Spacer()

                Text(title)
                    .font(AppTheme.Fonts.semibold(20))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

private struct CompanyHireFreelancerWrapperView: View {
    @StateObject private var summaryVM = HiredFreelancerSummaryViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            if summaryVM.isLoading {
                ProgressView()
            } else if let first = summaryVM.items.first {
                HiredFreelancerListView(summaryItem: first)
            } else {
                VStack(spacing: AppTheme.Spacing.medium) {
                    Text("No hired freelancer batches found.")
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(AppTheme.Spacing.medium)
            }
        }
        .onAppear {
            summaryVM.load()
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppTheme.Fonts.medium(13))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(value)
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
}
