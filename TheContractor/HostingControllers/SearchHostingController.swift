//
//  SearchHostingController.swift
//  TheContractor
//
//  UIHostingController for SearchCompaniesView
//

import UIKit
import SwiftUI

class SearchHostingController: UIHostingController<SearchCompaniesView> {
    init() {
        super.init(rootView: SearchCompaniesView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
