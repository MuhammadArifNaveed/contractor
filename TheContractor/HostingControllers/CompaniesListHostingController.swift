//
//  CompaniesListHostingController.swift
//  TheContractor
//
//  UIHostingController wrapper for CompaniesListView
//

import SwiftUI
import UIKit

class CompaniesListHostingController: UIHostingController<CompaniesListView> {
    
    init(categoryId: String? = nil, subCategoryId: String? = nil, title: String = "Companies") {
        let rootView = CompaniesListView(categoryId: categoryId, subCategoryId: subCategoryId, title: title)
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(AppTheme.Colors.background)
    }
}
