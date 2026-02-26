//
//  AddReviewView.swift
//  TheContractor
//
//  Add review/rating screen
//

import SwiftUI

struct AddReviewView: View {
    @StateObject private var viewModel: AddReviewViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(companyId: String, companyName: String) {
        _viewModel = StateObject(wrappedValue: AddReviewViewModel(companyId: companyId, companyName: companyName))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company")) {
                    Text(viewModel.companyName)
                        .font(AppTheme.Fonts.semibold(16))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                
                Section(header: Text("Your Rating")) {
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    viewModel.rating = index
                                }) {
                                    Image(systemName: index <= viewModel.rating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(index <= viewModel.rating ? AppTheme.Colors.starYellow : AppTheme.Colors.gray)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Your Review (Optional)")) {
                    TextEditor(text: $viewModel.comment)
                        .frame(height: 120)
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
            .navigationTitle("Add Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.submitReview {
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
struct AddReviewView_Previews: PreviewProvider {
    static var previews: some View {
        AddReviewView(companyId: "1", companyName: "Test Company")
    }
}
