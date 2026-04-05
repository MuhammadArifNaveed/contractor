import UIKit
import SwiftUI

class VendorEnquiriesHostingController: UIHostingController<VendorEnquiriesView> {
    init() {
        super.init(rootView: VendorEnquiriesView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
