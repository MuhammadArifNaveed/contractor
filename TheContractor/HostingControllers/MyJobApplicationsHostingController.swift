//
//  MyJobApplicationsHostingController.swift
//  TheContractor
//
//  Hosting controller for MyJobApplicationsView
//

import UIKit
import SwiftUI

class MyJobApplicationsHostingController: UIHostingController<MyJobApplicationsView> {
    
    init() {
        super.init(rootView: MyJobApplicationsView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
