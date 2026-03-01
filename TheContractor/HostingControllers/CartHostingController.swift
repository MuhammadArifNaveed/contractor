//
//  CartHostingController.swift
//  TheContractor
//
//  Hosting controller for CartView
//

import UIKit
import SwiftUI

class CartHostingController: UIHostingController<CartView> {
    
    init() {
        super.init(rootView: CartView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
