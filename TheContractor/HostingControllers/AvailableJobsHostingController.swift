//
//  AvailableJobsHostingController.swift
//  TheContractor
//
//  Hosting controller for AvailableJobsView
//

import UIKit
import SwiftUI

class AvailableJobsHostingController: UIHostingController<AvailableJobsView> {
    
    init() {
        super.init(rootView: AvailableJobsView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
