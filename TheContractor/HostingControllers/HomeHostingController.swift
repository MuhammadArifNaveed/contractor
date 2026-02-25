//
//  HomeHostingController.swift
//  TheContractor
//
//  UIHostingController wrapper for HomeView
//

import SwiftUI
import UIKit

class HomeHostingController: UIHostingController<HomeView> {
    
    init() {
        super.init(rootView: HomeView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(AppTheme.Colors.background)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
