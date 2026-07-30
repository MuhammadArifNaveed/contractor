//  VendorWorkshopView.swift
import SwiftUI
import SwiftyJSON
struct VendorWorkshopView: View {
    @StateObject private var viewModel = VendorWorkshopViewModel()
    private let yellow = Color(red: 242/255, green: 190/255, blue: 54/255)
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                Text("Workshop Items").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Button(action: { viewModel.addItem() }) {
                    Image(systemName: "plus").font(.system(size: 18, weight: .medium)).foregroundColor(.white).frame(width: 44, height: 44)
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal, 4).frame(height: 56).background(yellow)
            ZStack {
                if viewModel.isLoading && viewModel.items.isEmpty { LoadingView(message: "Loading...") }
                else if viewModel.items.isEmpty { EmptyStateView(icon: "wrench", title: "No Items", message: "No workshop items") }
                else {
                    List(viewModel.items.indices, id: \.self) { i in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: viewModel.items[i].image)) { img in img.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 60, height: 60).cornerRadius(8)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.items[i].title).font(AppTheme.Fonts.semibold(16))
                                Text(viewModel.items[i].price).font(AppTheme.Fonts.bold(14)).foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                    }
                }
            }
            .onAppear { viewModel.loadItems() }
        }
        .navigationBarHidden(true)
    }
}
class VendorWorkshopViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var items: [WorkshopItem] = []
    func loadItems() {
        isLoading = true
        LoginService.shared().makePostAPICall(with: "https://contractor.bidcont.com/rest/Home/vendor_workshop_items", params: [:]) { [weak self] _, success, json, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success, let arr = json?["items"].array {
                    self?.items = arr.map { WorkshopItem(id: $0["id"].stringValue, title: $0["title"].stringValue, price: $0["price"].stringValue, image: $0["image"].stringValue) }
                }
            }
        }
    }
    func addItem() { print("Add item") }
}

// MARK: - Interested Workshops
//
// Port of Android's `VendorInterestedWorkshops` (drawer item "Interested Workshops"):
// POST workshop/workshop_my_page with `vendor_id`, `user_id`, `user_type`, `bid_type`, `page`;
// response keys `workshops` and `total_page`. Two tabs — Open Bid and Close Bid — each of which
// resets to page 1, and an infinite scroll that stops at `total_page`.

struct VendorInterestedWorkshopsView: View {
    private enum BidTab: String {
        case open
        case close

        var title: String { self == .open ? "Open Bid" : "Close Bid" }
    }

    @State private var tab: BidTab = .open
    @State private var state: VendorLoadState = .loading
    @State private var workshops: [VendorWorkshopAd] = []
    @State private var page = 1
    @State private var lastPage = 0
    @State private var isLoadingMore = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: "Interested Workshops")

            tabs

            ZStack {
                VendorHomeStyle.background
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                case .noData:
                    Text("Data Not Found")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(workshops) { workshop in
                                VendorWorkshopAdCard(workshop: workshop)
                                    .onAppear {
                                        if workshop.id == workshops.last?.id { loadNextPageIfNeeded() }
                                    }
                            }

                            if isLoadingMore {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: VendorHomeStyle.appColor))
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(10)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear { if workshops.isEmpty { reload() } }
    }

    /// Android styles the active tab with `button_bacground` (filled yellow) and the other with
    /// `outline_black_button_bacground`.
    private var tabs: some View {
        HStack(spacing: 10) {
            ForEach([BidTab.open, BidTab.close], id: \.rawValue) { candidate in
                Button(action: { select(candidate) }) {
                    Text(candidate.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(tab == candidate ? VendorHomeStyle.appColor : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(tab == candidate ? Color.clear : Color.black, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(10)
        .background(VendorHomeStyle.background)
    }

    private func select(_ candidate: BidTab) {
        guard candidate != tab else { return }
        tab = candidate
        reload()
    }

    private func reload() {
        page = 1
        lastPage = 0
        workshops = []
        state = .loading
        fetch()
    }

    private func loadNextPageIfNeeded() {
        guard !isLoadingMore, page < lastPage else { return }
        page += 1
        isLoadingMore = true
        fetch()
    }

    private func fetch() {
        guard let session = VendorSession.current, !session.id.isEmpty else {
            state = .noData
            isLoadingMore = false
            return
        }

        let requestedTab = tab
        GCD.async(.Background) {
            LoginService.shared().getInterestedWorkshops(vendorId: session.id,
                                                         userId: session.user_id,
                                                         userType: session.user_type,
                                                         bidType: requestedTab.rawValue,
                                                         page: String(page)) { message, success, json in
                GCD.async(.Main) {
                    isLoadingMore = false

                    // A tab switch mid-flight makes this response stale.
                    guard requestedTab == tab else { return }

                    guard success, let json = json else {
                        if workshops.isEmpty {
                            state = .noData
                            errorMessage = message.isEmpty ? "Please try again" : message
                        }
                        return
                    }

                    lastPage = json["total_page"].int ?? Int(json["total_page"].stringValue) ?? 0
                    workshops += json["workshops"].arrayValue.map(VendorWorkshopAd.init)
                    state = workshops.isEmpty ? .noData : .loaded
                }
            }
        }
    }
}

// MARK: - Workshop ad model and card

/// Android `WorkshopAdModel`, reduced to what `VendorInterestedWorkshopAdAdapter` binds.
struct VendorWorkshopAd: Identifiable {
    let id: String
    let adId: String
    let title: String
    let description: String
    let workSector: String
    let cityName: String
    let name: String
    let surname: String
    let createdAt: String
    let imagePaths: [String]
    let statusName: String
    let statusColor: String
    let interested: String

    var posterName: String {
        [name, surname].filter { !$0.isEmpty }.joined(separator: " ")
    }

    /// `show_workshops_for_interest` marks rows the company has already bid on.
    var isInterested: Bool {
        let flag = interested.lowercased()
        return flag == "1" || flag == "yes" || flag == "true"
    }

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.adId = json["ad_id"].stringValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.workSector = json["work_sector"].stringValue
        self.cityName = json["city_name"].stringValue
        self.name = json["name"].stringValue
        self.surname = json["surname"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.imagePaths = json["images"].arrayValue.map { $0["image_path"].stringValue }
        self.statusName = json["status_name"].stringValue
        self.statusColor = json["status_color"].stringValue
        self.interested = json["interested"].stringValue
    }
}

/// Android `interested_workshop_ad_custom_row.xml`.
struct VendorWorkshopAdCard: View {
    let workshop: VendorWorkshopAd

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(workshop.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text(workshop.adId)
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.4))
            }

            if !workshop.statusName.isEmpty {
                VendorStatusBadge(name: workshop.statusName, color: workshop.statusColor)
            }

            Text(workshop.posterName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)

            Text([workshop.workSector, workshop.cityName].filter { !$0.isEmpty }.joined(separator: " · "))
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.35))

            if !workshop.description.isEmpty {
                Text(workshop.description)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(VendorHomeStyle.formatWorkshopDate(workshop.createdAt))
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.45))

            if !workshop.imagePaths.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(workshop.imagePaths, id: \.self) { path in
                            AsyncImage(url: VendorHomeStyle.workshopImageURL(path)) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFill()
                                } else {
                                    ZStack {
                                        Color(white: 0.92)
                                        Image(systemName: "photo")
                                            .font(.system(size: 18))
                                            .foregroundColor(Color(white: 0.6))
                                    }
                                }
                            }
                            .frame(width: 90, height: 70)
                            .clipped()
                            .cornerRadius(5)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}
