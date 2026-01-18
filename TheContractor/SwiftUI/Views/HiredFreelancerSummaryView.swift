import SwiftUI
import SwiftyJSON

struct HiredFreelancerSummaryView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var selectedSummary: SummaryItem?

    @StateObject private var vm = HiredFreelancerSummaryViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(title: "Hired Freelancer Summary")

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.items) { item in
                            SummaryCard(
                                item: item,
                                onViewDetail: {
                                    selectedSummary = item
                                }
                            )
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.medium)
                }

                NavigationLink(
                    destination: HiredFreelancerListView(summaryItem: selectedSummary),
                    isActive: Binding(
                        get: { selectedSummary != nil },
                        set: { isActive in
                            if !isActive {
                                selectedSummary = nil
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

private struct SummaryCard: View {
    let item: SummaryItem
    let onViewDetail: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Freelancers")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Text("\(item.totalFreelancers)")
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Amount Paid")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Text(item.amountPaid)
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Registered Date")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)

                        Text(item.registeredDate)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Button(action: { onViewDetail() }) {
                        Text("View Detail")
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .cardStyle(cornerRadius: AppTheme.CornerRadius.medium, shadowRadius: 2)
    }
}

struct SummaryItem: Identifiable, Hashable {
    let id = UUID()
    let batchId: String
    let totalFreelancers: Int
    let amountPaid: String
    let registeredDate: String
}

final class HiredFreelancerSummaryViewModel: ObservableObject {
    @Published var items: [SummaryItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchHiredFreelancersSummary { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    self.items = json["batch_lists"].arrayValue.map { batch in
                        let batchId = batch["id"].stringValue
                        let total = batch["total"].intValue
                        let amount = batch["payment_amount"].stringValue
                        let createdAt = batch["create_at"].stringValue.replacingOccurrences(of: "\n", with: " ")

                        return SummaryItem(
                            batchId: batchId,
                            totalFreelancers: total,
                            amountPaid: amount,
                            registeredDate: createdAt
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
