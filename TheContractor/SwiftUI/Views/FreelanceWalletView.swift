import SwiftUI
import SwiftyJSON

struct FreelanceWalletView: View {
    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var vm = FreelanceWalletViewModel()

    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar(title: "Wallet")

                VStack(alignment: .leading, spacing: 10) {
                    SummaryRow(title: "Total Balance:", value: vm.summary.totalBalance, valueColor: .green)
                    SummaryRow(title: "Total Refund:", value: vm.summary.totalRefund, valueColor: .green)
                    SummaryRow(title: "Total Reinvest:", value: vm.summary.totalReinvest, valueColor: .red)
                }
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.background)

                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.medium) {
                        if vm.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                        else {
                            ForEach(vm.transactions) { trx in
                                WalletTransactionCard(transaction: trx)
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

private struct SummaryRow: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Text(value)
                .font(AppTheme.Fonts.semibold(16))
                .foregroundColor(valueColor)
        }
    }
}

private struct WalletTransactionCard: View {
    let transaction: WalletTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Transaction ID")
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()
            }

            Text(transaction.transactionId)
                .font(AppTheme.Fonts.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(2)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Text(transaction.amount)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Created At")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Text(transaction.createdAt)
                        .font(AppTheme.Fonts.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .cardStyle(cornerRadius: AppTheme.CornerRadius.medium, shadowRadius: 2)
    }
}

struct WalletSummary: Hashable {
    let totalBalance: String
    let totalRefund: String
    let totalReinvest: String
}

struct WalletTransaction: Identifiable, Hashable {
    let id = UUID()

    let transactionId: String
    let amount: String
    let createdAt: String

}

final class FreelanceWalletViewModel: ObservableObject {
    @Published var summary: WalletSummary = WalletSummary(totalBalance: "", totalRefund: "", totalReinvest: "")
    @Published var transactions: [WalletTransaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func load() {
        if isLoading { return }
        isLoading = true
        errorMessage = ""

        FreelancingService.shared.fetchWallet { [weak self] message, success, json in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if success, let json {
                    let wallet = json["wallet"]
                    let refund = wallet["refund"].stringValue.replacingOccurrences(of: "\n", with: " ")
                    let deposit = wallet["deposit"].stringValue.replacingOccurrences(of: "\n", with: " ")
                    let balance = wallet["balance"].stringValue.replacingOccurrences(of: "\n", with: " ")

                    self.summary = WalletSummary(
                        totalBalance: "\(balance) AED",
                        totalRefund: "\(refund) AED",
                        totalReinvest: "\(deposit) AED"
                    )

                    self.transactions = wallet["transactions"].arrayValue.map { trx in
                        let uuid = trx["uuid"].stringValue
                        let amount = trx["amount"].stringValue
                        let type = trx["type"].stringValue
                        let createdAt = trx["created_at"].stringValue.replacingOccurrences(of: "\n", with: " ")
                        return WalletTransaction(transactionId: uuid, amount: "\(amount) AED (\(type))", createdAt: createdAt)
                    }
                }
                else {
                    self.errorMessage = message
                    self.summary = WalletSummary(totalBalance: "", totalRefund: "", totalReinvest: "")
                    self.transactions = []
                }
            }
        }
    }
}
