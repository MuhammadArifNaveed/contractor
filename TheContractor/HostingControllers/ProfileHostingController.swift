//
//  ProfileHostingController.swift
//  TheContractor
//
//  UIHostingController for UserProfileView
//

import UIKit
import SwiftUI

class ProfileHostingController: UIHostingController<UserProfileView> {
    private var observers: [NSObjectProtocol] = []

    init() {
        super.init(rootView: UserProfileView())
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func setupNotificationObservers() {
        let goToLogin = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("GoToLogin"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.triggerLogin()
        }

        let didLogout = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserDidLogout"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.triggerLogout()
        }
        
        let navToQuotations = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToQuotations"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToQuotations()
        }
        
        let navToComplaints = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToComplaints"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToComplaints()
        }
        
        let navToCart = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToCart"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToCart()
        }
        
        let navToJobApplications = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToJobApplications"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToJobApplications()
        }
        
        let navToEnquiries = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToEnquiries"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToEnquiries()
        }
        
        let navToEditProfile = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToEditProfile"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToEditProfile()
        }
        
        let navToChangePassword = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToChangePassword"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToChangePassword()
        }
        
        let navToSubmitQuotation = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToSubmitQuotation"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToSubmitQuotation()
        }
        
        let navTo24x7 = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateTo24x7Maintenance"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateTo24x7Maintenance()
        }
        
        let navToEstimations = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NavigateToEstimations"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.navigateToEstimations()
        }

        observers = [goToLogin, didLogout, navToQuotations, navToComplaints, navToCart, 
                     navToJobApplications, navToEnquiries, navToEditProfile, navToChangePassword,
                     navToSubmitQuotation, navTo24x7, navToEstimations]
    }

    private func mainContainer() -> MainContainerViewController? {
        var vc: UIViewController? = self
        while let parent = vc?.parent {
            if let container = parent as? MainContainerViewController { return container }
            vc = parent
        }
        return nil
    }

    private func triggerLogin() {
        print("🔐 triggerLogin called")
        if let container = mainContainer() {
            print("🔐 Container found, calling loginUser")
            container.loginUser()
        } else {
            print("🔐 Container not found, using fallback navigation")
            // Fallback: the login screen lives in Registration.storyboard. This used to name a "Main"
            // storyboard, which does not exist in this project, so the fallback could only fail.
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }

    private func triggerLogout() {
        if let container = mainContainer() {
            container.logoutUser()
        }
    }
    
    private func navigateToQuotations() {
        if let container = mainContainer() {
            container.showQuotationsController()
        }
    }
    
    private func navigateToComplaints() {
        if let container = mainContainer() {
            container.showComplaintsController()
        }
    }
    
    private func navigateToCart() {
        if let container = mainContainer() {
            container.showCartController()
        }
    }
    
    private func navigateToJobApplications() {
        if let container = mainContainer() {
            container.showMyJobApplicationsController()
        }
    }
    
    private func navigateToEnquiries() {
        if let container = mainContainer() {
            container.showEnquiriesController()
        }
    }
    
    private func navigateToEditProfile() {
        let editProfileView = EditProfileView()
        let hostingController = UIHostingController(rootView: editProfileView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func navigateToChangePassword() {
        let changePasswordView = ChangePasswordView()
        let hostingController = UIHostingController(rootView: changePasswordView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func navigateToSubmitQuotation() {
        if let container = mainContainer() {
            container.showSubmitQuotationController()
        }
    }
    
    private func navigateTo24x7Maintenance() {
        if let container = mainContainer() {
            container.show24x7MaintenanceController()
        }
    }
    
    private func navigateToEstimations() {
        // Android's ProfileFragment opens the request list here, same as the drawer.
        if let container = mainContainer() {
            container.showEstimationRequestsController()
        }
    }
}
