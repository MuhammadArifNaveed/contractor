//
//  WorkshopPostHostingController.swift
//  TheContractor
//
//  Hosting controller for WorkshopPostView
//

import UIKit
import SwiftUI

class WorkshopPostHostingController: UIHostingController<WorkshopPostView> {
    
    init() {
        super.init(rootView: WorkshopPostView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
