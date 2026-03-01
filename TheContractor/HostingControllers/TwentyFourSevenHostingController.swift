//
//  TwentyFourSevenHostingController.swift
//  TheContractor
//
//  Hosting controller for TwentyFourSevenCompaniesView
//

import UIKit
import SwiftUI

class TwentyFourSevenHostingController: UIHostingController<TwentyFourSevenCompaniesView> {
    
    init() {
        super.init(rootView: TwentyFourSevenCompaniesView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
