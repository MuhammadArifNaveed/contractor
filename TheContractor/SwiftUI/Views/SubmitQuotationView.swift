//
//  SubmitQuotationView.swift
//  TheContractor
//
//  Submit quotation request form (Quotation By Photo) - matches Android
//

import SwiftUI
import PhotosUI

struct SubmitQuotationView: View {
    @StateObject private var viewModel = SubmitQuotationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePicker = false
    @State private var showSuccessAlert = false
    @State private var successMessage = ""
    
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar with back button
            HStack(spacing: 0) {
                Button(action: { 
                    NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Quotation By Photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.horizontal, 8)
            .frame(height: 56)
            .background(yellow)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Categories Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Categories")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Rectangle()
                                .fill(yellow)
                                .frame(width: 40, height: 3)
                        }
                        .padding(.horizontal, 16)
                        
                        // Horizontal category tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.categories) { category in
                                    Button(action: {
                                        viewModel.selectCategory(category.id)
                                    }) {
                                        Text(category.name)
                                            .font(.system(size: 14))
                                            .foregroundColor(viewModel.selectedCategoryId == category.id ? yellow : .black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(viewModel.selectedCategoryId == category.id ? yellow : Color.gray.opacity(0.3), lineWidth: viewModel.selectedCategoryId == category.id ? 2 : 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Sub Categories Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sub Categories")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Rectangle()
                                .fill(yellow)
                                .frame(width: 40, height: 3)
                        }
                        .padding(.horizontal, 16)
                        
                        // Grid of subcategories (2 columns)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.currentSubCategories) { subCategory in
                                Button(action: {
                                    viewModel.selectSubCategory(subCategory.id)
                                }) {
                                    Text(subCategory.name)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(viewModel.selectedSubCategoryId == subCategory.id ? yellow.opacity(0.2) : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(viewModel.selectedSubCategoryId == subCategory.id ? yellow : Color.gray.opacity(0.3), lineWidth: viewModel.selectedSubCategoryId == subCategory.id ? 2 : 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // User Info Fields
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
                    .padding(.horizontal, 16)
                    
                    TextField("Phone Number", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 16)
                    
                    TextField("Email Address", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 16)
                    
                    // Details TextEditor
                    VStack(alignment: .leading, spacing: 4) {
                        TextEditor(text: $viewModel.details)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if viewModel.details.isEmpty {
                                        Text("Details")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 12)
                                            .padding(.top, 16)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding(.horizontal, 16)
                    
                    // Choose Images Button
                    Button(action: { showImagePicker = true }) {
                        Text("Choose Images")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 16)
                    
                    Text("Maximum 5 Images")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    // Selected Images Grid
                    if !viewModel.selectedImages.isEmpty {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: viewModel.selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        viewModel.selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white.clipShape(Circle()))
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Submit Button
                    Button(action: {
                        viewModel.submitQuotation { success, message in
                            if success {
                                successMessage = message
                                showSuccessAlert = true
                            }
                        }
                    }) {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Quotation By Photo")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(yellow)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .disabled(viewModel.isSubmitting)
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadUserInfo()
            viewModel.loadCategories()
        }
        .sheet(isPresented: $showImagePicker) {
            QuotationImagePicker(selectedImages: $viewModel.selectedImages, maxSelection: 5)
        }
        .alert("Quotation Submitted", isPresented: $showSuccessAlert) {
            Button("OK") {
                NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil)
            }
        } message: {
            Text(successMessage)
        }
    }
}

// MARK: - PHPicker Image Picker Wrapper
struct QuotationImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var maxSelection: Int
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: QuotationImagePicker

        init(_ parent: QuotationImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            let group = DispatchGroup()
            var images: [UIImage] = []

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.parent.selectedImages = images
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
