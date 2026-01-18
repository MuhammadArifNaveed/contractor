//
//  FreelancersHostingController.swift
//  TheContractor
//
//  Created by Warp AI
//

import UIKit
import SwiftUI

class FreelancersHostingController: UIHostingController<FreelancersView> {
    
    init() {
        super.init(rootView: FreelancersView())
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
