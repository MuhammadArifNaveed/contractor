//
//  SubmitQuotationHostingController.swift
//  TheContractor
//
//  Hosting controller for SubmitQuotationView
//

import UIKit
import SwiftUI

class SubmitQuotationHostingController: UIHostingController<SubmitQuotationView> {
    
    init() {
        super.init(rootView: SubmitQuotationView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
