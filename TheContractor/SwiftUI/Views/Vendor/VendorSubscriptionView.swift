//  VendorSubscriptionView.swift
import SwiftUI
struct VendorSubscriptionView: View {
    @StateObject private var viewModel = VendorSubscriptionViewModel()
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Current Plan").font(AppTheme.Fonts.semibold(16)).foregroundColor(.gray)
                    Text(viewModel.currentPlan).font(AppTheme.Fonts.bold(28))
                    Text("Expires: \(viewModel.expiryDate)").font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                }
                .padding(20).frame(maxWidth: .infinity).background(LinearGradient(gradient: Gradient(colors: [AppTheme.Colors.primary.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom)).cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Plans").font(AppTheme.Fonts.bold(20))
                    ForEach(viewModel.plans.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(viewModel.plans[i].name).font(AppTheme.Fonts.semibold(18))
                                Spacer()
                                Text(viewModel.plans[i].price).font(AppTheme.Fonts.bold(16)).foregroundColor(AppTheme.Colors.primary)
                            }
                            Text(viewModel.plans[i].features).font(AppTheme.Fonts.regular(14)).foregroundColor(.gray)
                            PrimaryButton(title: "Subscribe") { viewModel.subscribe(plan: viewModel.plans[i]) }
                        }
                        .padding(16).background(Color.white).cornerRadius(8).shadow(color: Color.black.opacity(0.05), radius: 4)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Subscription")
        .onAppear { viewModel.loadPlans() }
    }
}
class VendorSubscriptionViewModel: ObservableObject {
    @Published var currentPlan = "Free Plan"
    @Published var expiryDate = "N/A"
    @Published var plans: [SubscriptionPlan] = []
    func loadPlans() {
        plans = [
            SubscriptionPlan(id: "1", name: "Basic", price: "$29/month", features: "Up to 50 enquiries"),
            SubscriptionPlan(id: "2", name: "Pro", price: "$99/month", features: "Unlimited enquiries + priority support"),
            SubscriptionPlan(id: "3", name: "Enterprise", price: "$199/month", features: "Everything + dedicated manager")
        ]
    }
    func subscribe(plan: SubscriptionPlan) { print("Subscribe to: \(plan.name)") }
}
struct SubscriptionPlan: Identifiable { let id, name, price, features: String }
