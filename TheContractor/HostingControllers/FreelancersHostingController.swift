import UIKit
import SwiftUI

class FreelancersHostingController: UIHostingController<FreelancersView> {
    init() {
        super.init(rootView: FreelancersView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
