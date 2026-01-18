import SwiftUI
import SwiftyJSON
import Alamofire

struct FreelanceDashboardView: View {
    let onBack: (() -> Void)?
    private enum Segment: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case hiredFreelancer = "Hired Freelancer"
        case meAsFreelancer = "Me as a freelancer"
        case wallet = "Wallet"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .hiredFreelancer: return "Hired Freelancer"
            case .meAsFreelancer: return "Me as a freelancer"
            case .wallet: return "Wallet"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSegment: Segment = .dashboard
    @State private var pushedSegment: Segment?
    @State private var isShowingUpdateFreelancer: Bool = false

    @StateObject private var dashboardVM = FreelancingDashboardViewModel()

    init(onBack: (() -> Void)? = nil) {
        self.onBack = onBack
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
                        selectedSegment = .dashboard
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
            if segment == .hiredFreelancer {
                HiredFreelancerSummaryView()
            }
            else if segment == .meAsFreelancer {
                FreelancingOrdersView(freelancer: nil)
            }
            else if segment == .wallet {
                FreelanceWalletView()
            }
            else {
                FreelanceDashboardPlaceholderView(
                    title: segment.title,
                    onBack: {
                        selectedSegment = .dashboard
                        pushedSegment = nil
                    }
                )
            }
        }
        else {
            EmptyView()
        }
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

    private var segmentBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(Segment.allCases.enumerated()), id: \.element.id) { index, segment in
                    Button(action: {
                        selectedSegment = segment
                        if segment != .dashboard {
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

                    if index != Segment.allCases.count - 1 {
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
                availabilityRow

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
        // For now, use static values from the provided examples for user_type="users"
        // TODO: Replace with real Global.shared.user values when session/cookie is fixed
        return [
            "user_id": "45",
            "user_type": "users",
            "vendor_id": "45"
        ]
    }

    func fetchFreelancingDashboard(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/user_freelancing_dashboard"
        
        // For testing: manually set the session cookie from your working curl
        // TODO: This should be dynamically retrieved after login
        var headers = HTTPHeaders()
        headers["Cookie"] = "ci_session=d1063ae99f4b6e153bd86799a97423f147824030"
        
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false, headers: headers) { message, success, jsonData in
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

    func fetchWallet(completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) {
        let completeURL = EndPoints.BASE_URL + "freelancing/wallet"
        self.makePostAPICallWithMultipart(with: completeURL, dict: nil, params: defaultIdentityParams(), isImageData: false) { message, success, jsonData in
            completion(message, success, jsonData)
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
                    // Extract both freelancer and boss metrics
                    let freelancerMetrics = json["user_freelancing_dashboard"]["as_freelancer"].arrayValue.map { FreelancingDashboardMetric(json: $0) }
                    let bossMetrics = json["user_freelancing_dashboard"]["as_boss_details"].arrayValue.map { FreelancingDashboardMetric(json: $0) }
                    
                    // Combine both arrays for display
                    self.metrics = freelancerMetrics + bossMetrics
                    
                    // Update availability status
                    let availabilityValue = json["user_freelancing_dashboard"]["is_available_as_freelance"].stringValue
                    self.isAvailableAsFreelancer = availabilityValue == "1"
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
