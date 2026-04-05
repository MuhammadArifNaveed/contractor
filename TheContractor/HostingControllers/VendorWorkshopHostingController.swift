import UIKit
import SwiftUI

class VendorWorkshopHostingController: UIHostingController<VendorWorkshopView> {
    init() {
        super.init(rootView: VendorWorkshopView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
