import UIKit
import SwiftUI

class VendorQuotationsHostingController: UIHostingController<VendorQuotationsView> {
    init() {
        super.init(rootView: VendorQuotationsView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
