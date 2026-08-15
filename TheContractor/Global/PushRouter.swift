//
//  PushRouter.swift
//  TheContractor
//
//  What happens when a push notification is tapped. Android does this in
//  `Notifications/MyFirebaseMessagingService.displayNotification`: it reads `type` from the data
//  payload to decide which side the notification is for (`user` or `vendor`), checks that side is
//  signed in, then builds an implicit intent whose action *is* the payload's `action` string. The
//  manifest maps each action to a detail activity:
//
//      user_inbox        -> Chat                          (chatUUID + the vendor fields)
//      workshop          -> WorkshopAdDetail              (id)
//      vendor_workshop   -> VendorWorkshopDetail          (id)
//      quotation         -> QuotationsDetails             (id)
//      vendor_quotation  -> VendorQuotationDetail         (id)
//      enquiry           -> EnquiryDetail                 (id)
//      vendor_enquiry    -> VendorEnquiryDetail           (id)
//      complaint         -> ComplaintDetail               (id)
//      estimation        -> EstimationsDetail             (id)
//      vendor_membership -> VendorMyMembershipDetail      (id)
//
//  Every other action falls through to whichever home the payload's `type` belongs to, which is what
//  an unmatched implicit intent effectively does on Android.
//
//  Two destinations land on a list rather than the record, and it is worth being plain about why:
//  `EnquiryDetailView` and the estimation detail are built around a model the list already holds, not
//  an id, so there is nothing to fetch a single record with. The list is one tap away from the record
//  and is honest about what it can do; inventing a fetch would mean inventing an endpoint.
//
//  **Untested against real traffic.** The backend pushes with `thecontractor-uae` credentials and this
//  build registers tokens against `contractor-e1442`, so no notification reaches the app yet. See
//  RESUME_HERE.md §1. `PushRouter.handle(_:)` takes a plain dictionary precisely so the routing can be
//  exercised without a delivered push.
//

import UIKit
import SwiftUI

enum PushRouter {

    /// Set when a tap arrives before the container exists — a cold launch from a notification, where
    /// the delegate callback beats the window's root controller into being. Flushed by
    /// `MainContainerViewController` once it is on screen.
    private static var pending: [AnyHashable: Any]?

    /// The payload from a tapped notification. Firebase nests custom data at the top level of
    /// `userInfo` for data messages and alongside `aps` for notification messages, so keys are read
    /// straight off `userInfo` either way.
    static func handle(_ userInfo: [AnyHashable: Any]) {
        guard let container = currentContainer() else {
            pending = userInfo
            return
        }
        route(userInfo, in: container)
    }

    /// Called by the container once it is on screen, for a tap that arrived before it existed.
    static func flushPending() {
        guard let userInfo = pending, let container = currentContainer() else { return }
        pending = nil
        route(userInfo, in: container)
    }

    // MARK: - Routing

    private static func route(_ userInfo: [AnyHashable: Any], in container: MainContainerViewController) {
        func string(_ key: String) -> String { userInfo[key] as? String ?? "" }

        let type = string("type")
        let action = string("action")
        let id = string("id")

        // Android checks the stored object for the side the push is addressed to and drops the user on
        // that side's login when it is empty. A vendor notification arriving on a phone signed in as a
        // consumer must not open a vendor screen with someone else's session.
        switch type {
        case "vendor":
            guard VendorSession.current != nil else {
                container.showCompanyLoginController()
                return
            }
        case "user":
            guard Global.shared.user != nil else {
                container.loginUser()
                return
            }
        default:
            // No `type` at all: nothing can be verified about who it is for, so open the app and stop.
            return
        }

        // Android's unmatched implicit intent goes nowhere. Opening the right home is friendlier and
        // cannot show the wrong account's data. This is also where a detail action with no `id` lands —
        // there is nothing to open, and a detail screen fetching an empty id would just show an error.
        func home() {
            if type == "vendor" {
                container.showVendorHome()
            } else {
                container.showHomeController()
            }
        }

        switch action {
        case "user_inbox":
            openChat(chatUUID: string("chatUUID"), type: type, in: container)

        case "workshop", "vendor_workshop":
            id.isEmpty ? home() : container.showVendorScreen(VendorWorkshopDetailView(workshopId: id))

        case "quotation":
            id.isEmpty ? home() : container.showVendorScreen(QuotationDetailView(quotationId: id))

        case "vendor_quotation":
            id.isEmpty ? home() : container.showVendorScreen(VendorQuotationDetailView(quotationId: id))

        case "vendor_enquiry":
            id.isEmpty ? home() : container.showVendorScreen(VendorEnquiryDetailView(enquiryId: id))

        case "complaint":
            id.isEmpty ? home() : container.showVendorScreen(ComplaintDetailView(complaintId: id))

        // No detail screen takes an id for these three, so the list is the closest true destination.
        case "enquiry":
            container.showEnquiriesController()

        case "estimation":
            container.showEstimationRequestsController()

        case "vendor_membership":
            container.showVendorMyMembershipController()

        default:
            home()
        }
    }

    /// `user_inbox` carries `chatUUID`, `vendorId`, `vendorName`, `vendorUUID` and `vendorSerialNo` —
    /// enough to name a thread but not to reconstruct the stored connection document, which also holds
    /// the user side's fields and the `last_message` state. Looking the document up by `chat_uuid` is
    /// the only way to open the same thread the inbox would; if it is not there (a push for a thread
    /// this account cannot see, or Firestore unreachable), the inbox itself is the fallback.
    private static func openChat(chatUUID: String, type: String, in container: MainContainerViewController) {
        let role: ChatRole = type == "vendor" ? .company : .user

        guard !chatUUID.isEmpty else {
            showInbox(role: role, in: container)
            return
        }

        ChatService.shared.connection(chatUUID: chatUUID) { connection in
            guard let connection = connection else {
                showInbox(role: role, in: container)
                return
            }
            container.showVendorScreen(ChatThreadView(connection: connection, role: role))
        }
    }

    private static func showInbox(role: ChatRole, in container: MainContainerViewController) {
        if role == .company {
            container.showVendorInboxComingSoon()
        } else {
            container.showChatListController()
        }
    }

    // MARK: - Finding the container

    /// The app roots on a `KYDrawerController` whose `mainViewController` is a navigation controller
    /// holding the container. This is the same walk `SideMenuViewController.closeThenNavigate` does,
    /// starting from the window instead of from the drawer's child.
    private static func currentContainer() -> MainContainerViewController? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let drawer = window?.rootViewController as? KYDrawerController,
              let navigation = drawer.mainViewController as? UINavigationController,
              let container = navigation.topViewController as? MainContainerViewController
        else { return nil }

        drawer.setDrawerState(.closed, animated: false)
        return container
    }
}
