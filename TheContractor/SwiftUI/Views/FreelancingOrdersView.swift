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

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.orders) { order in
                                FreelancingOrderCard(order: order)
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

    let freelancerName: String
    let pickStatus: String
    let durationText: String
    let requestFrom: String
    let requestDate: String

    let registeredOnDate: String
    let responseTime: String
    let response: String
    let status: String

}

final class FreelancingOrdersViewModel: ObservableObject {
    @Published var orders: [FreelancingOrderItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

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

                        let freelancerName = order["freelancer_name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let fromTime = order["from_time"].stringValue
                        let toTime = order["to_time"].stringValue
                        let picked = order["picked"].stringValue
                        let dates = order["dates"].stringValue
                        let createdAt = order["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let expired = order["expired"].stringValue
                        let statusValue = order["status"].stringValue

                        let requesterName = requester["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let requestDate = dates.replacingOccurrences(of: "\n", with: " ")

                        let duration = "Full Day (\(fromTime) to \(toTime))"
                        let pickStatus = picked == "1" ? "Picked" : "Not Picked"
                        let status = expired == "1" ? "Expired" : (statusValue.isEmpty ? "" : statusValue)

                        return FreelancingOrderItem(
                            freelancerName: freelancerName,
                            pickStatus: pickStatus,
                            durationText: duration,
                            requestFrom: requesterName,
                            requestDate: requestDate,
                            registeredOnDate: createdAt,
                            responseTime: "",
                            response: "",
                            status: status
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
}
