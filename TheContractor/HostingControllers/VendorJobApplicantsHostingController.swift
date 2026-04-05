import UIKit
import SwiftUI

class VendorJobApplicantsHostingController: UIHostingController<VendorJobApplicantsView> {
    init() {
        super.init(rootView: VendorJobApplicantsView(jobId: ""))
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
