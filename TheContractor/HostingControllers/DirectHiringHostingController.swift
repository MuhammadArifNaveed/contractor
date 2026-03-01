//
//  DirectHiringHostingController.swift
//  TheContractor
//
//  Hosting controller for DirectHiringView
//

import UIKit
import SwiftUI

class DirectHiringHostingController: UIHostingController<DirectHiringView> {
    
    init() {
        super.init(rootView: DirectHiringView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
