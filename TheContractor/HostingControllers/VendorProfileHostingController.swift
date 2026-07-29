//
//  VendorProfileHostingController.swift
//  TheContractor
//
//  UIHostingController wrapper for VendorProfileView
//

import UIKit
import SwiftUI

class VendorProfileHostingController: UIHostingController<VendorProfileView> {
    
    init() {
        super.init(rootView: VendorProfileView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
