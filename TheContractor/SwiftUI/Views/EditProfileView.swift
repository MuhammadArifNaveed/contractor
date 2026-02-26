//
//  EditProfileView.swift
//  TheContractor
//
//  Edit user profile screen
//

import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel = EditProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    CustomTextField(placeholder: "First Name", text: $viewModel.firstName, icon: "person")
                    
                    CustomTextField(placeholder: "Last Name", text: $viewModel.lastName, icon: "person")
                    
                    CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(AppTheme.Fonts.regular(14))
                    }
                }
                
                if !viewModel.successMessage.isEmpty {
                    Section {
                        Text(viewModel.successMessage)
                            .foregroundColor(.green)
                            .font(AppTheme.Fonts.regular(14))
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.updateProfile {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        if viewModel.isUpdating {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isUpdating)
                }
            }
            .onAppear {
                viewModel.loadCurrentUserInfo()
            }
        }
    }
}

// MARK: - Preview
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
