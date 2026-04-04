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

        observers = [goToLogin, didLogout]
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
        if let container = mainContainer() {
            container.loginUser()
        }
    }

    private func triggerLogout() {
        if let container = mainContainer() {
            container.logoutUser()
        }
    }
}
