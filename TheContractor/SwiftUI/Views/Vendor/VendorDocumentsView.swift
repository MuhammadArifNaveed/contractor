//  VendorDocumentsView.swift
import SwiftUI
struct VendorDocumentsView: View {
    @StateObject private var viewModel = VendorDocumentsViewModel()
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.documents.isEmpty { LoadingView(message: "Loading...") }
            else if viewModel.documents.isEmpty { EmptyStateView(icon: "doc.text", title: "No Documents", message: "No documents uploaded") }
            else {
                List(viewModel.documents.indices, id: \.self) { i in
                    HStack(spacing: 12) {
                        Image(systemName: "doc.fill").foregroundColor(AppTheme.Colors.primary).font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.documents[i].name).font(AppTheme.Fonts.semibold(16))
                            Text(viewModel.documents[i].uploadDate).font(AppTheme.Fonts.regular(12)).foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { viewModel.viewDocument(viewModel.documents[i]) }) {
                            Image(systemName: "eye").foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Documents")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.uploadDocument() }) { Image(systemName: "plus").foregroundColor(AppTheme.Colors.primary) }
            }
        }
        .onAppear { viewModel.loadDocuments() }
    }
}
class VendorDocumentsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var documents: [VendorDocument] = []
    func loadDocuments() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_documents", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["documents"].array {
                    self?.documents = arr.map { VendorDocument(id: $0["id"].stringValue, name: $0["name"].stringValue, uploadDate: $0["upload_date"].stringValue) }
                }
            }
        }
    }
    func uploadDocument() { print("Upload document") }
    func viewDocument(_ doc: VendorDocument) { print("View: \(doc.name)") }
}
struct VendorDocument: Identifiable { let id, name, uploadDate: String }
