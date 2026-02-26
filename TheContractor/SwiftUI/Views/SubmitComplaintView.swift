//
//  SubmitComplaintView.swift
//  TheContractor
//
//  Submit complaint form screen
//

import SwiftUI

struct SubmitComplaintView: View {
    @StateObject private var viewModel = SubmitComplaintViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Company")) {
                    if let company = viewModel.selectedCompany {
                        HStack {
                            Text(company.company_name)
                                .font(AppTheme.Fonts.regular(14))
                            Spacer()
                            Button(action: {
                                viewModel.selectedCompany = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        Button(action: { viewModel.showCompanyPicker() }) {
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(AppTheme.Colors.gray)
                                Text("Select Company")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.Colors.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("Complaint Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        TextEditor(text: $viewModel.description)
                            .frame(height: 120)
                            .padding(8)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
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
            .navigationTitle("Submit Complaint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.submitComplaint {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
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
struct SubmitComplaintView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitComplaintView()
    }
}
