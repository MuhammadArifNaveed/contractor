//
//  FreelanceDashboardHostingController.swift
//  TheContractor
//
//  Hosting controller for FreelanceDashboardView
//

import UIKit
import SwiftUI

class FreelanceDashboardHostingController: UIHostingController<FreelanceDashboardView> {

    init() {
        super.init(rootView: FreelanceDashboardView(onBack: nil))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
