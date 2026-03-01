//
//  AdvertiseCompanyHostingController.swift
//  TheContractor
//
//  Hosting controller for AdvertiseCompanyView
//

import UIKit
import SwiftUI

class AdvertiseCompanyHostingController: UIHostingController<AdvertiseCompanyView> {
    
    init() {
        super.init(rootView: AdvertiseCompanyView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
