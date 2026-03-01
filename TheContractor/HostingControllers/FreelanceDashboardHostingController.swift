//
//  FreelanceDashboardHostingController.swift
//  TheContractor
//
//  Hosting controller for FreelanceDashboardView
//

import UIKit
import SwiftUI

// Simple wrapper view for FreelanceDashboard
struct FreelanceDashboardWrapper: View {
    var body: some View {
        Text("Freelance Dashboard")
            .font(.largeTitle)
            .navigationBarHidden(true)
    }
}

class FreelanceDashboardHostingController: UIHostingController<FreelanceDashboardWrapper> {
    
    init() {
        super.init(rootView: FreelanceDashboardWrapper())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
