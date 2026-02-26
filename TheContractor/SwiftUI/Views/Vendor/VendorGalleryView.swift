//  VendorGalleryView.swift
import SwiftUI
struct VendorGalleryView: View {
    @StateObject private var viewModel = VendorGalleryViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.images.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.images.isEmpty { EmptyStateView(icon: "photo.on.rectangle", title: "No Images", message: "No gallery images yet") }
            else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(viewModel.images.indices, id: \.self) { i in
                            AsyncImage(url: URL(string: viewModel.images[i].url)) { img in img.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                                .frame(height: 150).cornerRadius(8).clipped()
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Gallery")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.addImage() }) { Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary) }
            }
        }
        .onAppear { viewModel.loadGallery() }
    }
}
class VendorGalleryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var images: [GalleryImage] = []
    func loadGallery() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_gallery", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["images"].array {
                    self?.images = arr.map { GalleryImage(id: $0["id"].stringValue, url: $0["url"].stringValue) }
                }
            }
        }
    }
    func addImage() { print("Add image") }
}
struct GalleryImage: Identifiable { let id, url: String }
