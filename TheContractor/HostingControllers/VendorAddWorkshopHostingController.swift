import UIKit
import SwiftUI

class VendorAddWorkshopHostingController: UIHostingController<VendorAddWorkshopItemView> {
    init() {
        super.init(rootView: VendorAddWorkshopItemView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
