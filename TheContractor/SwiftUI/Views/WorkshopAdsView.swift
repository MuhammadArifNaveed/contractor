//
//  WorkshopAdsView.swift
//  TheContractor
//
//  The consumer's own workshop ads — Android's `WorkShopAds` opened from the drawer with `type=user`.
//
//  Posting an ad already worked; nothing could look at one afterwards. The drawer item opened the post
//  form, so an ad, the quotations companies placed on it, and the ability to take it down were all
//  unreachable.
//
//  `WorkShopAds` is a single Android activity used by both sides, so this is the same list the company
//  drawer shows, given a consumer identity: the user's own id goes over the wire as `vendor_id`, which
//  is what `WorkShopAds.getDataFromSP()` does when the stored session is a user rather than a vendor.
//
//  Verified live for the QA account: `workshop/workshops` returns 10 open-bid ads across two pages and
//  one close-bid ad.
//

import SwiftUI

struct WorkshopAdsView: View {
    var body: some View {
        VendorWorkshopAdsList(
            title: "My Workshop Ads",
            identity: .consumer,
            allowsMarkInterested: false,
            allowsStatusToggle: true,
            // Opened over the tab bar like the other consumer drawer screens, so back restores it.
            onBack: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }
        ) { identity, bidType, page, completion in
            LoginService.shared().getVendorWorkshops(vendorId: identity.vendorId,
                                                    userId: identity.userId,
                                                    userType: identity.userType,
                                                    bidType: bidType,
                                                    page: page,
                                                    completion: completion)
        }
    }
}
