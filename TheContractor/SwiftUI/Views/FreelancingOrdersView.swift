import SwiftUI
import SwiftyJSON

struct FreelancingOrdersView: View {
    @Environment(\.presentationMode) private var presentationMode

    let freelancer: HiredFreelancerItem?

    @StateObject private var vm = FreelancingOrdersViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(title: "Freelancing Orders")

                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, AppTheme.Spacing.medium)
                        .padding(.top, AppTheme.Spacing.small)
                }

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.orders) { order in
                                FreelancingOrderCard(
                                    order: order,
                                    isUpdating: vm.isUpdating(orderId: order.orderId),
                                    onAccept: {
                                        vm.changeStatus(for: order, action: .accept)
                                    },
                                    onReject: {
                                        vm.changeStatus(for: order, action: .reject)
                                    }
                                )
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.load()
        }
    }

    private func topBar(title: String) -> some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
    }
}

private struct FreelancingOrderCard: View {
    let order: FreelancingOrderItem
    let isUpdating: Bool
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("Freelancers")
                .font(AppTheme.Fonts.semibold(18))
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(AppTheme.Colors.gray)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(order.freelancerName)
                            .font(AppTheme.Fonts.semibold(15))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()

                        Text("(\(order.pickStatus))")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Text(order.durationText)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }

            Text("Request From")
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.top, 4)

            Text(order.requestFrom)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(order.requestDate)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(20)

            HStack(alignment: .top, spacing: AppTheme.Spacing.large) {
                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(title: "Registered On Date", value: order.registeredOnDate)
                    InfoRow(title: "Response", value: order.response)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(title: "Response Time", value: order.responseTime)
                    InfoRow(title: "Status", value: order.status)
                }
            }

            HStack(spacing: AppTheme.Spacing.small) {
                if order.canRespond {
                    Button(action: { onAccept() }) {
                        Text("Accept")
                            .font(AppTheme.Fonts.semibold(14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(isUpdating ? AppTheme.Colors.primary.opacity(0.6) : Color.green)
                            .cornerRadius(4)
                    }
                    .disabled(isUpdating)

                    Button(action: { onReject() }) {
                        Text("Reject")
                            .font(AppTheme.Fonts.semibold(14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(isUpdating ? Color.red.opacity(0.6) : Color.red)
                            .cornerRadius(4)
                    }
                    .disabled(isUpdating)
                } else {
                    Text(order.status.isEmpty ? "No Response" : "")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.top, AppTheme.Spacing.small)
        }
        .padding(AppTheme.Spacing.medium)
        .cardStyle(cornerRadius: AppTheme.CornerRadius.medium, shadowRadius: 2)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text(value)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

struct FreelancingOrderItem: Identifiable, Hashable {
    let id = UUID()

    let orderId: String
    let freelancerName: String
    let pickStatus: String
    let durationText: String
    let requestFrom: String
    let requestDate: String

    let registeredOnDate: String
    var responseTime: String
    var response: String
    var status: String
    var isExpired: Bool

    var canRespond: Bool {
        !isExpired && status.isEmpty
    }
}

final class FreelancingOrdersViewModel: ObservableObject {
    @Published var orders: [FreelancingOrderItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published private var updatingOrderIds: Set<String> = []

    enum OrderAction: Int {
        case accept = 1
        case reject = 2
    }

    func isUpdating(orderId: String) -> Bool {
        updatingOrderIds.contains(orderId)
    }

    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchFreelancingOrders { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    self.orders = json["freelancing_orders"].arrayValue.map { wrapper in
                        let order = wrapper["order"]
                        let requester = wrapper["requester"]

                        let orderId = order["id"].stringValue
                        let freelancerName = order["freelancer_name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let fromTime = order["from_time"].stringValue
                        let toTime = order["to_time"].stringValue
                        let picked = order["picked"].stringValue
                        let dates = order["dates"].stringValue
                        let createdAt = order["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let expired = order["expired"].stringValue
                        let statusValue = order["status"].stringValue
                        let responseRaw = order["response"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let responseTimeRaw = order["response_time"].stringValue.replacingOccurrences(of: "\n", with: " ")

                        let requesterName = requester["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let requestDate = dates.replacingOccurrences(of: "\n", with: " ")

                        let duration = "Full Day (\(fromTime) to \(toTime))"
                        let pickStatus = picked == "1" ? "Picked" : "Not Picked"
                        let isExpired = expired == "1"
                        let status = isExpired ? "Expired" : (statusValue.isEmpty ? "" : statusValue)
                        let responseTime = isExpired && responseTimeRaw.isEmpty ? "Time Over" : responseTimeRaw

                        return FreelancingOrderItem(
                            orderId: orderId,
                            freelancerName: freelancerName,
                            pickStatus: pickStatus,
                            durationText: duration,
                            requestFrom: requesterName,
                            requestDate: requestDate,
                            registeredOnDate: createdAt,
                            responseTime: responseTime,
                            response: responseRaw,
                            status: status,
                            isExpired: isExpired
                        )
                    }
                }
                else {
                    self.errorMessage = message
                    self.orders = []
                }
            }
        }
    }

    func changeStatus(for order: FreelancingOrderItem, action: OrderAction) {
        guard !order.orderId.isEmpty else { return }
        if updatingOrderIds.contains(order.orderId) { return }

        updatingOrderIds.insert(order.orderId)
        errorMessage = ""

        FreelancingService.shared.changeFreelancingOrderStatus(orderId: order.orderId, type: action.rawValue) { [weak self] message, success in
            DispatchQueue.main.async {
                guard let self else { return }
                self.updatingOrderIds.remove(order.orderId)

                if success {
                    if let index = self.orders.firstIndex(where: { $0.orderId == order.orderId }) {
                        var updated = self.orders[index]
                        updated.status = action == .accept ? "Accepted" : "Rejected"
                        updated.response = action == .accept ? "Accept" : "Reject"
                        updated.isExpired = false
                        self.orders[index] = updated
                    }
                } else {
                    self.errorMessage = message
                    // On failure (e.g., "Order has been expired") we reload
                    // the list so UI reflects latest backend state.
                    self.load()
                }
            }
        }
    }
}
