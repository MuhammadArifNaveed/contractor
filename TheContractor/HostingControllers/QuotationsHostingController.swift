//
//  QuotationsHostingController.swift
//  TheContractor
//
//  Hosting controller for QuotationsListView
//

import UIKit
import SwiftUI

class QuotationsHostingController: UIHostingController<QuotationsListView> {
    
    init() {
        super.init(rootView: QuotationsListView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
