import SwiftUI
import SwiftyJSON

struct HiredFreelancerListView: View {
    @Environment(\.presentationMode) private var presentationMode

    let summaryItem: SummaryItem?

    @State private var selectedFreelancer: HiredFreelancerItem?

    @StateObject private var vm = HiredFreelancerListViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(title: "Hired Freelancer")

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.items) { item in
                                Button(action: {
                                    selectedFreelancer = item
                                }) {
                                    HiredFreelancerCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }

                NavigationLink(
                    destination: FreelancingOrdersView(freelancer: selectedFreelancer),
                    isActive: Binding(
                        get: { selectedFreelancer != nil },
                        set: { isActive in
                            if !isActive {
                                selectedFreelancer = nil
                            }
                        }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            vm.load(batchId: summaryItem?.batchId)
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

private struct HiredFreelancerCard: View {
    let item: HiredFreelancerItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(AppTheme.Colors.gray)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(item.name)
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()

                        Text("(\(item.pickStatus))")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Text(item.durationText)
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }

            if !item.skills.isEmpty {
                HStack(spacing: 8) {
                    ForEach(item.skills, id: \.self) { skill in
                        Text(skill)
                            .font(AppTheme.Fonts.medium(13))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.primary.opacity(0.85))
                            .cornerRadius(20)
                    }
                }
            }

            Text(item.requestDate)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(20)

            HStack(alignment: .top, spacing: AppTheme.Spacing.large) {
                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(title: "Registered On Date", value: item.registeredOnDate)
                    InfoRow(title: "Response", value: item.response)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    InfoRow(title: "Response Time", value: item.responseTime)
                    InfoRow(title: "Status", value: item.status)
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

struct HiredFreelancerItem: Identifiable, Hashable {
    let id = UUID()

    let name: String
    let pickStatus: String
    let durationText: String
    let skills: [String]
    let requestDate: String
    let registeredOnDate: String
    let responseTime: String
    let response: String
    let status: String

}

final class HiredFreelancerListViewModel: ObservableObject {
    @Published var items: [HiredFreelancerItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func load(batchId: String?) {
        guard let batchId, !batchId.isEmpty else {
            items = []
            return
        }
        if isLoading { return }

        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchHiredFreelancers(batchId: batchId) { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    self.items = json["hired_freelancers"].arrayValue.map { freelancer in
                        let name = freelancer["name"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let fromTime = freelancer["from_time"].stringValue
                        let toTime = freelancer["to_time"].stringValue
                        let picked = freelancer["picked"].stringValue

                        let skills = freelancer["skills"].arrayValue.map { $0["skill_title"].stringValue }
                        let requestDate = freelancer["dates"].arrayValue.first?["date"].stringValue ?? ""
                        let createdAt = freelancer["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        let expired = freelancer["expired"].stringValue
                        let statusValue = freelancer["status"].stringValue

                        let duration = "Full Day (\(fromTime) to \(toTime))"
                        let pickStatus = picked == "1" ? "Picked" : "Not Picked"
                        let status = expired == "1" ? "Expired" : (statusValue.isEmpty ? "" : statusValue)

                        return HiredFreelancerItem(
                            name: name,
                            pickStatus: pickStatus,
                            durationText: duration,
                            skills: skills,
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
                    self.items = []
                }
            }
        }
    }
}
