import UIKit
import SwiftUI

class FreelanceDashboardHostingController: UIHostingController<FreelanceDashboardView> {
    
    init() {
        super.init(rootView: FreelanceDashboardView())
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        rootView = FreelanceDashboardView(onBack: { [weak self] in
            guard let self else { return }
            if let container = self.navigationController?.parent as? MainContainerViewController {
                container.dismissFreelanceDashboardController()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
