//
//  VendorWorkshopAdsView.swift
//  TheContractor
//
//  The two remaining workshop screens on Android's vendor drawer:
//    • "My Workshops"  → `WorkShopAds` with type=vendor (POST workshop/workshops)
//    • "All Workshops" → `VendorAllWorkshopsAds`     (POST workshop/show_workshops_for_interest)
//
//  Both are paginated Open Bid / Close Bid lists over the same workshop-ad row. The All Workshops
//  screen adds Android's "mark interested" action (POST workshop/mark_workshop_interested).
//

import SwiftUI
import SwiftyJSON

// MARK: - My Workshops

struct VendorMyWorkshopsView: View {
    var body: some View {
        VendorWorkshopAdsList(title: "My Workshops", allowsMarkInterested: false) { session, bidType, page, completion in
            LoginService.shared().getVendorWorkshops(vendorId: session.id,
                                                    userId: session.user_id,
                                                    userType: session.user_type,
                                                    bidType: bidType,
                                                    page: page,
                                                    completion: completion)
        }
    }
}

// MARK: - All Workshops

struct VendorAllWorkshopsView: View {
    var body: some View {
        VendorWorkshopAdsList(title: "All Workshops", allowsMarkInterested: true) { session, bidType, page, completion in
            LoginService.shared().getAllWorkshopsForInterest(vendorId: session.id,
                                                            userId: session.user_id,
                                                            userType: session.user_type,
                                                            bidType: bidType,
                                                            page: page,
                                                            completion: completion)
        }
    }
}

// MARK: - Shared paginated list

/// Both screens share Android's structure exactly — only the endpoint and whether the
/// "I'm interested" button appears differ.
struct VendorWorkshopAdsList: View {
    typealias Loader = (_ session: VendorSession,
                        _ bidType: String,
                        _ page: String,
                        _ completion: @escaping (_ message: String, _ success: Bool, _ json: JSON?) -> Void) -> Void

    private enum BidTab: String {
        case open
        case close

        var title: String { self == .open ? "Open Bid" : "Close Bid" }
    }

    let title: String
    let allowsMarkInterested: Bool
    let load: Loader

    @State private var tab: BidTab = .open
    @State private var state: VendorLoadState = .loading
    @State private var workshops: [VendorWorkshopAd] = []
    @State private var page = 1
    @State private var lastPage = 0
    @State private var isLoadingMore = false
    @State private var isMarking = false
    @State private var errorMessage: String?
    @State private var noticeMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VendorTopBar(title: title)

            tabs

            ZStack {
                VendorTheme.canvas
                    .ignoresSafeArea(edges: .bottom)

                switch state {
                case .loading:
                    VendorSkeletonList()
                case .noData:
                    VendorEmptyState(icon: "hammer",
                                     title: "No workshops here",
                                     message: "Try the other bid tab.")
                case .loaded:
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(workshops) { workshop in
                                VStack(spacing: 0) {
                                    VendorWorkshopAdCard(workshop: workshop)

                                    if allowsMarkInterested && !workshop.isInterested {
                                        Button(action: { markInterested(workshop) }) {
                                            Text("I'm Interested")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(VendorTheme.accent)
                                                .cornerRadius(5)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.top, 6)
                                    }
                                }
                                .onAppear {
                                    if workshop.id == workshops.last?.id { loadNextPageIfNeeded() }
                                }
                            }

                            if isLoadingMore {
                                VendorBusyIndicator()
                                    .padding(.vertical, VendorTheme.Space.m)
                            }
                        }
                        .padding(10)
                    }
                }

                if isMarking {
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
        .alert("", isPresented: Binding(get: { noticeMessage != nil }, set: { _ in noticeMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noticeMessage ?? "")
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
                                .fill(tab == candidate ? VendorTheme.accent : Color.clear)
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
        .background(VendorTheme.canvas)
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
            load(session, requestedTab.rawValue, String(page)) { message, success, json in
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

    private func markInterested(_ workshop: VendorWorkshopAd) {
        guard let session = VendorSession.current, !session.id.isEmpty else { return }

        isMarking = true
        GCD.async(.Background) {
            LoginService.shared().markWorkshopInterested(vendorId: session.id,
                                                         userId: session.user_id,
                                                         userType: session.user_type,
                                                         bidType: tab.rawValue,
                                                         workshopAdId: workshop.id) { message, success in
                GCD.async(.Main) {
                    isMarking = false
                    if success {
                        noticeMessage = message.isEmpty ? "Interest registered." : message
                        reload()
                    } else {
                        errorMessage = message.isEmpty ? "Please try again" : message
                    }
                }
            }
        }
    }
}
