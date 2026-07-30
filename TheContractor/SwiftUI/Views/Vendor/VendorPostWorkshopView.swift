//
//  VendorPostWorkshopView.swift
//  TheContractor
//
//  Port of Android's `VendorPostWorkshop`.
//
//  Pickers come from POST workshop/workshop_filter_data (`workshop_type`, `work_sector` as
//  {title, value}; `freelancer_cities` as {id, name}), and the ad is posted to
//  POST workshop/submit_workshop_ad with the photos as repeated `images[]` parts.
//
//  Replaces VendorAddWorkshopItemView, which posted to Home/add_workshop_item — an endpoint the
//  backend does not serve.
//

import SwiftUI
import SwiftyJSON
import PhotosUI

struct VendorPostWorkshopView: View {
    @State private var title = ""
    @State private var details = ""

    @State private var types: [VendorJobFilterOption] = []
    @State private var sectors: [VendorJobFilterOption] = []
    @State private var cities: [VendorJobFilterOption] = []
    @State private var selectedType: VendorJobFilterOption?
    @State private var selectedSector: VendorJobFilterOption?
    @State private var selectedCity: VendorJobFilterOption?

    @State private var images: [UIImage] = []
    @State private var showPhotoPicker = false

    @State private var isLoadingFields = true
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var postedMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Post Workshop")

            ZStack {
                VendorTheme.canvas.ignoresSafeArea(edges: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: VendorTheme.Space.l) {
                        detailsCard
                        classificationCard
                        photosCard
                        submitButton
                    }
                    .padding(VendorTheme.Space.l)
                }

                if isSubmitting {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    VendorBusyIndicator()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("", isPresented: Binding(get: { postedMessage != nil }, set: { _ in postedMessage = nil })) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(postedMessage ?? "")
        }
        .sheet(isPresented: $showPhotoPicker) {
            VendorPhotoPicker(selectionLimit: 8) { picked in
                images.append(contentsOf: picked)
            }
        }
        .onAppear { if types.isEmpty { loadFields() } }
    }

    // MARK: - Sections

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Workshop")

            VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                Text("TITLE")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textTertiary)
                    .tracking(0.4)
                TextField("Short, specific title", text: $title)
                    .font(VendorTheme.Text.body)
                    .padding(VendorTheme.Space.s)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.surfaceRaised)
                    )
            }

            VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
                Text("DESCRIPTION")
                    .font(VendorTheme.Text.label)
                    .foregroundColor(VendorTheme.textTertiary)
                    .tracking(0.4)
                TextEditor(text: $details)
                    .frame(height: 120)
                    .padding(VendorTheme.Space.xs)
                    .background(
                        RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                            .fill(VendorTheme.surfaceRaised)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var classificationCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Classification")

            if isLoadingFields {
                VendorSkeleton(height: 30)
                VendorSkeleton(height: 30)
                VendorSkeleton(height: 30)
            } else {
                picker("Bid type", options: types, selection: $selectedType)
                picker("Work sector", options: sectors, selection: $selectedSector)
                picker("City", options: cities, selection: $selectedCity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private func picker(_ label: String,
                        options: [VendorJobFilterOption],
                        selection: Binding<VendorJobFilterOption?>) -> some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.xs) {
            Text(label.uppercased())
                .font(VendorTheme.Text.label)
                .foregroundColor(VendorTheme.textTertiary)
                .tracking(0.4)
            VendorChipRow(options: options, selection: selection)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: VendorTheme.Space.m) {
            VendorSectionHeader(title: "Photos", count: images.count)

            Text("Optional. Clear photos get more responses.")
                .font(VendorTheme.Text.meta)
                .foregroundColor(VendorTheme.textSecondary)

            if !images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VendorTheme.Space.s) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(RoundedRectangle(cornerRadius: VendorTheme.Radius.control,
                                                                style: .continuous))

                                Button(action: { images.remove(at: index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }

            Button(action: { showPhotoPicker = true }) {
                Label("Add photos", systemImage: "photo.on.rectangle.angled")
                    .font(VendorTheme.Text.cardTitle)
                    .foregroundColor(VendorTheme.textPrimary)
                    .padding(.horizontal, VendorTheme.Space.l)
                    .padding(.vertical, VendorTheme.Space.s)
                    .background(Capsule().fill(VendorTheme.surfaceRaised))
                    .overlay(Capsule().stroke(VendorTheme.separator, lineWidth: 0.5))
            }
            .buttonStyle(VendorPressStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .vendorCard()
    }

    private var submitButton: some View {
        Button(action: submit) {
            Text("Post workshop")
                .font(VendorTheme.Text.cardTitle)
                .foregroundColor(VendorTheme.onAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, VendorTheme.Space.m)
                .background(
                    RoundedRectangle(cornerRadius: VendorTheme.Radius.control, style: .continuous)
                        .fill(VendorTheme.accent)
                )
        }
        .buttonStyle(VendorPressStyle())
    }

    // MARK: - Data

    private func loadFields() {
        isLoadingFields = true
        GCD.async(.Background) {
            LoginService.shared().getWorkshopFilterData { message, success, json in
                GCD.async(.Main) {
                    isLoadingFields = false
                    guard success, let json = json else {
                        errorMessage = message.isEmpty ? "Could not load workshop options." : message
                        return
                    }
                    // workshop_type and work_sector are {title, value}; cities are {id, name}.
                    types = json["workshop_type"].arrayValue.map {
                        VendorJobFilterOption(id: $0["value"].stringValue, name: $0["title"].stringValue)
                    }
                    sectors = json["work_sector"].arrayValue.map {
                        VendorJobFilterOption(id: $0["value"].stringValue, name: $0["title"].stringValue)
                    }
                    cities = json["freelancer_cities"].arrayValue.map {
                        VendorJobFilterOption(id: $0["id"].stringValue, name: $0["name"].stringValue)
                    }
                }
            }
        }
    }

    private func submit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Enter a title"
            return
        }
        guard !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter a description"
            return
        }
        guard let type = selectedType else {
            errorMessage = "Select a bid type"
            return
        }
        guard let sector = selectedSector else {
            errorMessage = "Select a work sector"
            return
        }
        guard let city = selectedCity else {
            errorMessage = "Select a city"
            return
        }
        guard let session = VendorSession.current, !session.id.isEmpty else { return }

        // Re-encode at a sane size; straight off the camera these are several megabytes each and the
        // upload can carry eight of them.
        let payload = images.compactMap { $0.vendorUploadJPEG() }

        isSubmitting = true
        GCD.async(.Background) {
            LoginService.shared().submitWorkshopAd(vendorId: session.id,
                                                   userId: session.user_id,
                                                   userType: session.user_type,
                                                   bidType: type.id,
                                                   workSector: sector.id,
                                                   workCity: city.id,
                                                   title: trimmedTitle,
                                                   description: details,
                                                   images: payload) { message, success in
                GCD.async(.Main) {
                    isSubmitting = false
                    if success {
                        postedMessage = message.isEmpty ? "Workshop posted." : message
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}

// MARK: - Photo picker

/// `PHPickerViewController` wrapper. SwiftUI's own `PhotosPicker` is iOS 16 and the deployment
/// target here is iOS 15.
struct VendorPhotoPicker: UIViewControllerRepresentable {
    let selectionLimit: Int
    let onPicked: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: VendorPhotoPicker

        init(_ parent: VendorPhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }

            // Loads are asynchronous and unordered, so collect into a slot per result and drop the
            // gaps once every provider has reported back.
            var loaded = [UIImage?](repeating: nil, count: results.count)
            let group = DispatchGroup()

            for (index, result) in results.enumerated() {
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage { loaded[index] = image }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [parent] in
                parent.onPicked(loaded.compactMap { $0 })
            }
        }
    }
}

extension UIImage {
    /// Downscale to fit within 1600pt and re-encode as JPEG, so an eight-photo upload stays sane.
    func vendorUploadJPEG(maxDimension: CGFloat = 1600, quality: CGFloat = 0.75) -> Data? {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return jpegData(compressionQuality: quality) }

        let scale = maxDimension / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
