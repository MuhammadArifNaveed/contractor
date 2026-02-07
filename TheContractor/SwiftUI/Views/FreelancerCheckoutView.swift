//
//  FreelancerCheckoutView.swift
//  TheContractor
//
//  Created by Warp AI
//

import SwiftUI

struct FreelancerCheckoutView: View {
    let onDismiss: () -> Void
    
    @StateObject private var cartManager = FreelancerCartManager.shared
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.secondaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation bar
                navigationBar
                
                if cartManager.selectedFreelancers.isEmpty {
                    emptyStateView
                } else {
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            // Freelancer cards
                            ForEach(cartManager.selectedFreelancers) { selection in
                                CheckoutFreelancerCard(selection: selection)
                            }
                        }
                        .padding(AppTheme.Spacing.medium)
                        .padding(.bottom, 200) // Space for summary card
                    }
                    
                    // Bottom summary card
                    summaryCard
                }
            }
            
            // Loading overlay
            if isSubmitting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text(isSuccess ? "Submitted" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        cartManager.clearCart()
                        onDismiss()
                    }
                }
            )
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 0) {
            // Back button
            Button(action: { onDismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            
            // Title
            Text("Freelancer Checkout")
                .font(AppTheme.Fonts.title)
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(AppTheme.Colors.primary)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.gray)
            
            Text("No freelancers selected")
                .font(AppTheme.Fonts.semibold(18))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("Go back and select freelancers to hire")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.large)
    }
    
    private var summaryCard: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            // Summary rows
            CheckoutSummaryRow(title: "Total Freelancers:", value: "\(cartManager.totalFreelancers)")
            CheckoutSummaryRow(title: "Freelancers Charges:", value: String(format: "%.2f AED", cartManager.freelancersCharges))
            CheckoutSummaryRow(title: "Transportation Charges:", value: String(format: "%.2f AED", cartManager.transportationCharges))
            
            Divider()
                .padding(.vertical, 4)
            
            // Total
            HStack {
                Text("Total Charges:")
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Text(String(format: "%.2f AED", cartManager.totalCharges))
                    .font(AppTheme.Fonts.semibold(18))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            // Submit button
            Button(action: submitHiring) {
                Text("Submit")
                    .font(AppTheme.Fonts.semibold(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(AppTheme.CornerRadius.small)
            }
            .disabled(isSubmitting)
            .padding(.top, 8)
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
    }
    
    private func submitHiring() {
        isSubmitting = true
        
        let payload = cartManager.generateAPIPayload()
        
        FreelancingService.shared.hireFreelancers(freelancerDataJSON: payload) { message, success in
            DispatchQueue.main.async {
                isSubmitting = false
                alertMessage = success ? "Freelancer Hired without payment" : message
                isSuccess = success
                showSuccessAlert = true
            }
        }
    }
}

// MARK: - Checkout Freelancer Card
struct CheckoutFreelancerCard: View {
    @ObservedObject var selection: FreelancerSelection
    @State private var isCalculatingTransport = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            // Header row with name, profession, rate, location
            HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                // Profile placeholder
                ProfileImageView(imageUrl: selection.profileImage, size: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(selection.name)
                            .font(AppTheme.Fonts.semibold(16))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text(selection.profession)
                            .font(AppTheme.Fonts.regular(13))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text(String(format: "%.2f/hr", selection.hourlyRate))
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text(selection.location)
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Delete button
                Button(action: {
                    FreelancerCartManager.shared.removeFreelancer(selection.freelancerId)
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            // Selected dates with time and hours
            ForEach(selection.selectedDates) { entry in
                HStack {
                    Text("\(entry.formattedDate) ( \(selection.workingHours) ) ( \(String(format: "%.2f", entry.hours)) hrs)")
                        .font(AppTheme.Fonts.regular(13))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            
            // Amount breakdown
            let totalHours = selection.selectedDates.reduce(0) { $0 + $1.hours }
            let totalDays = selection.selectedDates.count
            Text("Amount ( \(String(format: "%.2f", totalHours)) Hr x \(String(format: "%.2f", selection.hourlyRate)) Rate x \(totalDays) days ) : \(String(format: "%.2f", selection.totalAmount)) AED")
                .font(AppTheme.Fonts.regular(13))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // Calculate Transport Charges button
            HStack {
                Button(action: {
                    calculateTransportCharges()
                }) {
                    HStack(spacing: 6) {
                        if isCalculatingTransport {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Calculate Transport Charges")
                            .font(AppTheme.Fonts.medium(13))
                    }
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.Colors.primary.opacity(0.2))
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
                .disabled(isCalculatingTransport)
                
                Spacer()
            }
            
            // Payable amount
            HStack {
                Text("Payable : \(String(format: "%.2f", selection.payableAmount)) AED")
                    .font(AppTheme.Fonts.semibold(14))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            
            // Transport status indicator
            if selection.isTransportCalculated {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("Transport: \(String(format: "%.2f", selection.transportCharges)) AED")
                        .font(AppTheme.Fonts.caption)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    if selection.transportationDiscount > 0 {
                        Text("(Discount: \(String(format: "%.2f", selection.transportationDiscount)))")
                            .font(AppTheme.Fonts.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private func calculateTransportCharges() {
        isCalculatingTransport = true
        
        FreelancingService.shared.fetchTransportationCharges(freelancerId: selection.freelancerId) { message, success, cost, discount in
            DispatchQueue.main.async {
                isCalculatingTransport = false
                if success {
                    selection.transportationCost = cost
                    selection.transportationDiscount = discount
                    selection.isTransportCalculated = true
                }
            }
        }
    }
}

// MARK: - Checkout Summary Row
private struct CheckoutSummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    FreelancerCheckoutView(onDismiss: {})
}
