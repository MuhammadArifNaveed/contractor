//
//  EditProfileView.swift
//  TheContractor
//
//  Edit user profile screen - matches Android Update Profile
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private let yellow = VendorTheme.accent
    /// `"0"` is Android's unset sentinel for both pickers, so it must not be shown as a value.
    private var categoryLabel: String {
        viewModel.selectedCategory == "0" ? "" : viewModel.selectedCategory
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar
            VendorTopBar(title: "Update Profile",
                         onBack: { presentationMode.wrappedValue.dismiss() })
            
            ScrollView {
                VStack(spacing: 16) {
                    // Profile Image
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.gray)
                            )
                        
                        Button(action: { viewModel.showImagePicker = true }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(yellow)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 16)
                    
                    // Name fields (horizontal)
                    HStack(spacing: 10) {
                        TextField("First Name", text: $viewModel.firstName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        
                        TextField("Last Name", text: $viewModel.lastName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // Email
                    TextField("Email Address", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    // Phone (disabled)
                    TextField("Phone Number", text: $viewModel.phone)
                        .disabled(true)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    // City Picker
                    Menu {
                        ForEach(viewModel.cities, id: \.id) { city in
                            Button(city.name) { viewModel.selectedCity = city.id }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCityName.isEmpty ? "Select City" : viewModel.selectedCityName)
                                .foregroundColor(viewModel.selectedCityName.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // Address
                    TextField("Address", text: $viewModel.address)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    
                    // Upload Video
                    Button(action: {}) {
                        Text("Upload Video")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    if !viewModel.videoName.isEmpty {
                        Text(viewModel.videoName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Category Picker
                    Menu {
                        // The *title* is what gets stored, not the id — Android's asymmetry, kept.
                        ForEach(viewModel.categories, id: \.id) { category in
                            Button(category.name) { viewModel.selectedCategory = category.name }
                        }
                    } label: {
                        HStack {
                            Text(categoryLabel.isEmpty ? "Select Category" : categoryLabel)
                                .foregroundColor(categoryLabel.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // Upload CV
                    Button(action: {}) {
                        Text("Upload CV")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    if !viewModel.cvName.isEmpty {
                        Text(viewModel.cvName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Job Availability Checkbox
                    HStack {
                        Button(action: { viewModel.availableForJob.toggle() }) {
                            HStack {
                                Image(systemName: viewModel.availableForJob ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.availableForJob ? yellow : .gray)
                                    .font(.system(size: 20))
                                Text("Yes, I am available for job")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    
                    // Freelancer availability. This was a local flag that saved nowhere; it now calls
                    // freelancing/update_user_freelance_status on each tap and follows the state the
                    // response reports, the way Android's UpdateProfile does.
                    HStack {
                        Button(action: { viewModel.toggleFreelanceAvailability() }) {
                            HStack {
                                Image(systemName: viewModel.isAvailableAsFreelancer ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.isAvailableAsFreelancer ? yellow : .gray)
                                    .font(.system(size: 20))
                                Text(viewModel.isAvailableAsFreelancer
                                     ? "Yes, I am available as a freelancer"
                                     : "No, I am not available as a freelancer")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        .disabled(viewModel.isUpdatingFreelanceStatus)
                        Spacer()
                        if viewModel.isUpdatingFreelanceStatus {
                            ProgressView()
                        }
                    }

                    // Registering yourself as a freelancer, and editing that record afterwards.
                    // Android reaches the same form from here with from=user.
                    Button(action: { viewModel.openFreelancerProfile() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.rectangle")
                                .font(.system(size: 16))
                            // A fixed label: whether a record exists is only known once
                            // freelancing/register_user_freelancer answers, so naming one or the other
                            // before the tap would be a guess. Android labels it plainly too.
                            Text("Freelancer profile")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            if viewModel.isCheckingFreelancerRecord {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 12)
                    }
                    .disabled(viewModel.isCheckingFreelancerRecord)

                    
                    // Update Button
                    Button(action: {
                        viewModel.updateProfile {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        if viewModel.isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Update Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(yellow)
                    .cornerRadius(8)
                    .disabled(viewModel.isUpdating)
                    
                    // Error/Success Messages
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                    
                    if !viewModel.successMessage.isEmpty {
                        Text(viewModel.successMessage)
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                    }
                }
                .padding(16)
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        // EditProfileView is pushed onto a UIKit navigation stack, so there is no SwiftUI
        // NavigationView above it and a NavigationLink here would do nothing.
        .sheet(isPresented: $viewModel.openFreelancerForm) {
            UpdateFreelancerView(record: viewModel.freelancerRecord)
        }
        .alert("", isPresented: Binding(get: { viewModel.freelanceNotice != nil },
                                       set: { if !$0 { viewModel.freelanceNotice = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.freelanceNotice ?? "")
        }
        .onAppear {
            viewModel.loadCurrentUserInfo()
        }
    }
}

// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
