//
//  VendorApplicantDetailView.swift
//  TheContractor
//
//  Port of Android's `VendorApplicantDetail`. Android fetches nothing here — the row is passed
//  straight through from the list — and the one action is a direct hire via POST jobs/direct_hire.
//

import SwiftUI

struct VendorApplicantDetailView: View {
    let applicant: VendorApplicant

    @State private var errorMessage: String?
    @State private var noticeMessage: String?
    @State private var isHiring = false
    @State private var confirmHire = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Applicant Details", onBack: { dismiss() })

            ZStack {
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            VendorPersonAvatar(path: applicant.image)
                                .frame(width: 72, height: 72)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(applicant.fullName)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.black)
                                if !applicant.categoryTitle.isEmpty {
                                    Text(applicant.categoryTitle)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(white: 0.35))
                                }
                            }

                            Spacer()
                        }

                        divider

                        HStack(alignment: .top, spacing: 10) {
                            field(label: "Phone Number", value: applicant.phone)
                            field(label: "Email Address", value: applicant.email)
                        }

                        divider

                        HStack(alignment: .top, spacing: 10) {
                            field(label: "City", value: applicant.cityName)
                            field(label: "Country", value: applicant.countryName)
                        }

                        if !applicant.address.isEmpty {
                            divider
                            field(label: "Address", value: applicant.address)
                        }

                        divider

                        field(label: "Registered", value: VendorHomeStyle.formatWorkshopDate(applicant.createdAt))

                        divider

                        Button(action: { confirmHire = true }) {
                            Text("Hire Directly")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(VendorHomeStyle.appColor)
                                .cornerRadius(5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(10)
                }

                if isHiring {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
        }
        .alert("Hire \(applicant.fullName)?", isPresented: $confirmHire) {
            Button("Hire") { hire() }
            Button("Cancel", role: .cancel) { }
        }
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(white: 0.35))
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(white: 0.85))
            .frame(height: 0.5)
            .padding(.vertical, 10)
    }

    /// Android sends status `"1"` for the initial hire request.
    private func hire() {
        guard let session = VendorSession.current, !session.id.isEmpty else { return }

        isHiring = true
        GCD.async(.Background) {
            LoginService.shared().directHireApplicant(vendorId: session.id,
                                                      userId: session.user_id,
                                                      userType: session.user_type,
                                                      applicantUuid: applicant.uuid,
                                                      status: "1") { message, success in
                GCD.async(.Main) {
                    isHiring = false
                    if success {
                        noticeMessage = message.isEmpty ? "Hiring request sent." : message
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}
