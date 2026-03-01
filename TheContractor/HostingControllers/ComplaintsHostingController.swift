//
//  ComplaintsHostingController.swift
//  TheContractor
//
//  Hosting controller for ComplaintsListView
//

import UIKit
import SwiftUI

class ComplaintsHostingController: UIHostingController<ComplaintsListView> {
    
    init() {
        super.init(rootView: ComplaintsListView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
