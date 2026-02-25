//
//  SubmitQuotationView.swift
//  TheContractor
//
//  Submit quotation request form
//

import SwiftUI

struct SubmitQuotationView: View {
    @StateObject private var viewModel = SubmitQuotationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showDatePicker = false
    
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
                
                Section(header: Text("Request Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        TextEditor(text: $viewModel.description)
                            .frame(height: 100)
                            .padding(8)
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
                    
                    CustomTextField(placeholder: "Location", text: $viewModel.location, icon: "location")
                    
                    Button(action: { showDatePicker = true }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(AppTheme.Colors.gray)
                            Text(viewModel.dateTime.isEmpty ? "Select Date & Time" : viewModel.dateTime)
                                .foregroundColor(viewModel.dateTime.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                            Spacer()
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
            .navigationTitle("Request Quotation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.submitQuotation {
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
            .sheet(isPresented: $showDatePicker) {
                DateTimePicker(selectedDate: $viewModel.selectedDate, dateTime: $viewModel.dateTime)
            }
        }
    }
}

// MARK: - Date Time Picker
struct DateTimePicker: View {
    @Binding var selectedDate: Date
    @Binding var dateTime: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date & Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                        dateTime = formatter.string(from: selectedDate)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SubmitQuotationView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitQuotationView()
    }
}
