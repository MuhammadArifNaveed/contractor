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
    
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    private let cities = ["Abu Dhabi", "Dubai", "Sharjah", "Ajman", "Umm Al Quwain", "Ras Al Khaimah", "Fujairah"]
    private let categories = ["Plumber", "Electrician", "Carpenter", "Painter", "Mason", "Welder"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Update Profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4)
            .frame(height: 56)
            .background(yellow)
            
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
                        ForEach(cities, id: \.self) { city in
                            Button(city) { viewModel.selectedCity = city }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCity.isEmpty ? "Select City" : viewModel.selectedCity)
                                .foregroundColor(viewModel.selectedCity.isEmpty ? .gray : .black)
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
                        ForEach(categories, id: \.self) { category in
                            Button(category) { viewModel.selectedCategory = category }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCategory.isEmpty ? "Select Category" : viewModel.selectedCategory)
                                .foregroundColor(viewModel.selectedCategory.isEmpty ? .gray : .black)
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
                    
                    // Freelancer Checkbox
                    HStack {
                        Button(action: { viewModel.notAvailableAsFreelancer.toggle() }) {
                            HStack {
                                Image(systemName: viewModel.notAvailableAsFreelancer ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.notAvailableAsFreelancer ? yellow : .gray)
                                    .font(.system(size: 20))
                                Text("No, I am not available as freelancer")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    
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
