//
//  EnquiriesHostingController.swift
//  TheContractor
//
//  Hosting controller for EnquiriesListView
//

import UIKit
import SwiftUI

class EnquiriesHostingController: UIHostingController<EnquiriesListView> {
    
    init() {
        super.init(rootView: EnquiriesListView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
