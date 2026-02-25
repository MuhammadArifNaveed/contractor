//
//  SubmitEnquiryView.swift
//  TheContractor
//
//  Submit enquiry form screen
//

import SwiftUI

struct SubmitEnquiryView: View {
    @StateObject private var viewModel = SubmitEnquiryViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    CustomTextField(placeholder: "First Name", text: $viewModel.firstName, icon: "person")
                    
                    CustomTextField(placeholder: "Last Name", text: $viewModel.lastName, icon: "person")
                    
                    CustomTextField(placeholder: "Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)
                    
                    CustomTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
                }
                
                Section(header: Text("Select Companies")) {
                    if viewModel.selectedCompanies.isEmpty {
                        Button(action: { viewModel.showCompanyPicker() }) {
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(AppTheme.Colors.gray)
                                Text("Select Companies")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.Colors.gray)
                            }
                        }
                    } else {
                        ForEach(viewModel.selectedCompanies, id: \.id) { company in
                            HStack {
                                Text(company.company_name)
                                    .font(AppTheme.Fonts.regular(14))
                                Spacer()
                                Button(action: {
                                    viewModel.removeCompany(company)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Button(action: { viewModel.showCompanyPicker() }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Add More Companies")
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(AppTheme.Fonts.regular(14))
                    }
                }
            }
            .navigationTitle("Submit Enquiry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.submitEnquiry {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
        }
    }
}

// MARK: - Preview
struct SubmitEnquiryView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitEnquiryView()
    }
}
