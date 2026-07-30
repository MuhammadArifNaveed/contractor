import UIKit
import SwiftUI

/// Android's "Available Applicant" drawer item (`VendorApplicants`). The per-job applications list
/// is a different screen and is pushed from the job detail, so it is not wrapped here.
class VendorJobApplicantsHostingController: UIHostingController<VendorAvailableApplicantsView> {
    init() {
        super.init(rootView: VendorAvailableApplicantsView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
