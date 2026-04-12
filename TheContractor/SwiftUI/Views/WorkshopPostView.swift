//
//  WorkshopPostView.swift
//  TheContractor
//
//  Workshop Ad Posting Form matching Android WorkshopFragment
//

import SwiftUI
import PhotosUI

struct WorkshopPostView: View {
    @StateObject private var viewModel = WorkshopPostViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Yellow top bar with back button
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                Text("Workshop")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4)
            .frame(height: 56)
            .background(yellow)
            
            ZStack {
                if viewModel.isLoadingFilters {
                    LoadingView(message: "Loading...")
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Workshop Type Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Workshop Type")
                                    .font(AppTheme.Fonts.medium(14))
                                    .foregroundColor(.gray)
                            
                            Picker("Select Type", selection: $viewModel.selectedTypeId) {
                                ForEach(viewModel.workshopTypes) { type in
                                    Text(type.name).tag(type.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Workshop Sector Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workshop Sector")
                                .font(AppTheme.Fonts.medium(14))
                                .foregroundColor(.gray)
                            
                            Picker("Select Sector", selection: $viewModel.selectedSectorId) {
                                ForEach(viewModel.workshopSectors) { sector in
                                    Text(sector.name).tag(sector.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // City Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("City")
                                .font(AppTheme.Fonts.medium(14))
                                .foregroundColor(.gray)
                            
                            Picker("Select City", selection: $viewModel.selectedCityId) {
                                ForEach(viewModel.cities) { city in
                                    Text(city.name).tag(city.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(AppTheme.Fonts.medium(14))
                                .foregroundColor(.gray)
                            
                            TextField("Enter title", text: $viewModel.title)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Details Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(AppTheme.Fonts.medium(14))
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $viewModel.details)
                                .frame(height: 120)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Image Picker Button
                        Button(action: { viewModel.showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Choose Images (Max 5)")
                                    .font(AppTheme.Fonts.medium(16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                        }
                        
                        // Selected Images Grid
                        if !viewModel.selectedImages.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: viewModel.selectedImages[index].image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                        
                                        Button(action: { viewModel.removeImage(at: index) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.red.clipShape(Circle()))
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                        
                        // Submit Button
                        Button(action: { viewModel.submitWorkshopAd() }) {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit")
                                    .font(AppTheme.Fonts.semibold(16))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(8)
                        .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                        .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                        
                        // Error Message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(AppTheme.Fonts.regular(14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .padding(16)
                }
                .background(AppTheme.Colors.background)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(selectedImages: $viewModel.selectedImages, maxSelection: 5)
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(viewModel.successMessage)
        }
        .onAppear {
            viewModel.loadFilterData()
        }
    }
}
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [SelectedImage]
    let maxSelection: Int
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
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard !results.isEmpty else { return }
            
            parent.selectedImages.removeAll()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(SelectedImage(image: uiImage))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SelectedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
