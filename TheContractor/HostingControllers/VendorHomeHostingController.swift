//
//  VendorHomeHostingController.swift
//  TheContractor
//
//  UIHostingController wrapper for VendorHomeView
//

import UIKit
import SwiftUI

class VendorHomeHostingController: UIHostingController<VendorHomeView> {
    
    init() {
        super.init(rootView: VendorHomeView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
