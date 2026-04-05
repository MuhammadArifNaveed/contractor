import UIKit
import SwiftUI

class VendorJobsHostingController: UIHostingController<VendorJobsView> {
    init() {
        super.init(rootView: VendorJobsView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
