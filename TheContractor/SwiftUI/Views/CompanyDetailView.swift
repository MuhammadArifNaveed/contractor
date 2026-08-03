//
//  CompanyDetailView.swift
//  TheContractor
//
//  Company details screen matching Android CompanyDetails activity
//

import SwiftUI

private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)

struct CompanyDetailView: View {
    @StateObject private var viewModel: CompanyDetailViewModel
    @ObservedObject private var cart = ConsumerCartStore.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showComplaintSheet = false

    init(company: CompanyViewModel) {
        _viewModel = StateObject(wrappedValue: CompanyDetailViewModel(company: company))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading...")
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        companyHeaderCard
                        tabBar
                        tabContent
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.loadDetails() }
        .sheet(isPresented: $showComplaintSheet) {
            ComplaintSheet(
                isPresented: $showComplaintSheet,
                onSubmit: { text in
                    let uid = Global.shared.user?.id ?? ""
                    viewModel.submitComplaint(text: text, userId: uid)
                }
            )
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }

            Text("Company Details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            addToEnquiryButton
                .padding(.trailing, 12)
        }
        .frame(height: 56)
        .background(yellow)
    }

    /// Was a decorative cart glyph. Android's `CompanyDetails` adds the company to the local basket
    /// from here; the basket is then sent as one enquiry from the cart screen.
    private var addToEnquiryButton: some View {
        Button(action: toggleInCart) {
            HStack(spacing: 5) {
                Image(systemName: isInCart ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .bold))
                Text(isInCart ? "Added" : "Add to enquiry")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color(red: 26/255, green: 20/255, blue: 0))
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(Capsule().fill(Color.white.opacity(isInCart ? 0.65 : 1)))
        }
        .disabled(viewModel.company.id.isEmpty)
    }

    private var isInCart: Bool {
        cart.contains(companyId: viewModel.company.id)
    }

    private func toggleInCart() {
        let company = viewModel.company
        guard !company.id.isEmpty else { return }
        cart.toggle(CartCompany(id: company.id,
                                companyName: company.company_name,
                                companyLogo: company.company_logo,
                                categoryName: company.category_name))
    }

    // MARK: - Company Header Card
    private var companyHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: viewModel.company.company_logo.isEmpty ? "" : viewModel.company.company_logo)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Image(systemName: "building.2")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(width: 80, height: 70)
                .background(Color(UIColor.systemGray6))
                .clipped()
                .cornerRadius(4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.company.company_name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Text(viewModel.company.category_name)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    HStack(spacing: 6) {
                        starsView(rating: Double(viewModel.company.total_rating) ?? 0)

                        Text("(\(viewModel.company.review_count))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        if viewModel.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }

                        if viewModel.is24Hours {
                            Text("24h")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 2)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.orange, lineWidth: 1))
                        }
                    }
                }

                Spacer()
            }

            HStack(spacing: 10) {
                if !viewModel.companyPhone.isEmpty {
                    Button(action: { viewModel.callCompany() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill").font(.system(size: 12))
                            Text("Phone").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                }

                if !viewModel.companyEmail.isEmpty || !viewModel.company.login_email.isEmpty {
                    Button(action: { viewModel.emailCompany() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "envelope.fill").font(.system(size: 12))
                            Text("Email").font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: {}) {
                    Text("Select Company")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(yellow, lineWidth: 1.5))
                }

                Button(action: { showComplaintSheet = true }) {
                    Text("Complaint")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(4)
                }
            }
        }
        .padding(14)
        .background(Color.white)
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        let tabs = ["Details", "Opening Hours", "Reviews"]
        return HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button(action: { selectedTab = i }) {
                    VStack(spacing: 0) {
                        Text(tabs[i])
                            .font(.system(size: 14, weight: selectedTab == i ? .semibold : .regular))
                            .foregroundColor(selectedTab == i ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)

                        Rectangle()
                            .fill(selectedTab == i ? yellow : Color.clear)
                            .frame(height: 3)
                    }
                }
            }
        }
        .background(Color.white)
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        if selectedTab == 0 {
            detailsTab
        } else if selectedTab == 1 {
            openingHoursTab
        } else {
            reviewsTab
        }
    }

    // MARK: - Details Tab
    private var detailsTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !viewModel.companyAddress.isEmpty {
                detailSection("Address") {
                    Text(viewModel.companyAddress)
                        .font(.system(size: 14)).foregroundColor(.black)
                }
            }

            HStack(spacing: 0) {
                infoColumn(title: "City", value: viewModel.cityName)
                Divider().frame(height: 70)
                infoColumn(title: "Area", value: viewModel.areaName)
            }
            .background(Color.white)

            Divider().padding(.horizontal, 0)

            HStack(spacing: 0) {
                infoColumn(title: "Since", value: viewModel.companySince)
                Divider().frame(height: 70)
                infoColumn(title: "No of Employees", value: viewModel.companyEmployees)
            }
            .background(Color.white)

            if !viewModel.subCategories.isEmpty {
                detailSection("Sub Categories") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(viewModel.subCategories) { sub in
                            Text(sub.name)
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(6)
                                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                        }
                    }
                }
            }

            Spacer(minLength: 24)
        }
    }

    // MARK: - Opening Hours Tab
    private var openingHoursTab: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.openingHours.isEmpty {
                Text("No Opening Hours Available")
                    .font(.system(size: 14)).foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(40)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Opening Hours")
                            .font(.system(size: 16, weight: .semibold))
                        Rectangle().fill(yellow).frame(width: 50, height: 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 10)

                ForEach(viewModel.openingHours) { hour in
                    HStack {
                        Text(hour.day).font(.system(size: 14)).foregroundColor(.black)
                        Spacer()
                        Text("\(hour.openTime)-\(hour.closeTime)")
                            .font(.system(size: 14)).foregroundColor(.black)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(Color.white)
                    .padding(.horizontal, 16).padding(.bottom, 4)
                }
            }
            Spacer(minLength: 24)
        }
    }

    // MARK: - Reviews Tab
    private var reviewsTab: some View {
        VStack {
            if viewModel.reviews.isEmpty {
                Text("No Reviews Found")
                    .font(.system(size: 14)).foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(60)
            } else {
                ForEach(viewModel.reviews) { review in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(review.userName)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            starsView(rating: Double(review.rating) ?? 0)
                        }
                        if !review.comment.isEmpty {
                            Text(review.comment)
                                .font(.system(size: 13)).foregroundColor(.gray)
                        }
                        if !review.date.isEmpty {
                            Text(review.date)
                                .font(.system(size: 11)).foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(6)
                    .padding(.horizontal, 16).padding(.top, 8)
                }
            }
            Spacer(minLength: 24)
        }
    }

    // MARK: - Helpers
    private func starsView(rating: Double) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: Double(star) <= rating ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(yellow)
            }
        }
    }

    @ViewBuilder
    private func detailSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 15, weight: .semibold))
            Rectangle().fill(yellow).frame(width: 40, height: 3)
            content()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .padding(.top, 6)
    }

    private func infoColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 12)).foregroundColor(.gray)
            Rectangle().fill(yellow).frame(width: 30, height: 2)
            Text(value.isEmpty ? "-" : value).font(.system(size: 14)).foregroundColor(.black)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Complaint Sheet
struct ComplaintSheet: View {
    @Binding var isPresented: Bool
    let onSubmit: (String) -> Void
    @State private var complaintText = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Describe your complaint:")
                    .font(.system(size: 14)).foregroundColor(.gray)

                TextEditor(text: $complaintText)
                    .frame(minHeight: 120)
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                Spacer()
            }
            .padding(16)
            .navigationTitle("Submit Complaint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        if !complaintText.isEmpty {
                            onSubmit(complaintText)
                            isPresented = false
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Preview
struct CompanyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyDetailView(company: CompanyViewModel())
    }
}
