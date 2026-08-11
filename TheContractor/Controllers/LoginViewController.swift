//
//  LoginViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/26/21.
//

import UIKit
import SwiftUI

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var txtPin: UITextField!
    @IBOutlet weak var txtNumber: UITextField!




    override func viewDidLoad() {
        super.viewDidLoad()
        installLoginScreen()
    }

    /// Covers the storyboard scene with `ConsumerLoginView`. The scene's own logo, fields and Login
    /// button stay in the hierarchy underneath — the outlets are still wired, so nothing that touches
    /// them has to change — but nothing sees them.
    private func installLoginScreen() {
        let screen = ConsumerLoginView(
            onLogin: { [weak self] phone, pin in self?.performLogin(phone: phone, pin: pin) },
            onSkip: { [weak self] in self?.actionSkip(self as Any) },
            onCreateAccount: { [weak self] in self?.actionNotMember(self as Any) },
            onForgotPassword: { [weak self] in self?.actionForgetPassword(self as Any) },
            onCompanyLogin: { [weak self] in self?.actionLoginAsCompany(self as Any) })

        let host = UIHostingController(rootView: screen)
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        host.didMove(toParent: self)
    }



    @IBAction func actionSkip(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Drawer", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "KYDrawerController") as! KYDrawerController
        Global.shared.isLogedIn = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// Kept for the storyboard connection; the visible screen is `ConsumerLoginView`, which calls
    /// `performLogin` directly.
    @IBAction func actionLogin(_ sender: Any) {
        performLogin(phone: txtNumber?.text ?? "", pin: txtPin?.text ?? "")
    }

    func performLogin(phone phoneNumber: String, pin password: String) {
        // Validate inputs (matching Android's Login.java exactly)
        if phoneNumber.isEmpty {
            self.showAlertView(message: "Enter phone number")
            return
        }

        if password.isEmpty {
            self.showAlertView(message: "Enter 4 digits pin code")
            return
        }

        // Same rule as sign-up, which is why it lives in one place: an account created under one
        // prefix could not sign in under another.
        let formattedPhone = PhoneNumber.e164(phoneNumber)

        let params : ParamsAny = [
            "user_phone": formattedPhone,
            "user_password": password,
            "device_type": "ios",
            "firebase_token": Global.shared.firebaseTokenForRequest
        ]
        self.userLogin(params: params)
    }
    
    /// Used to push `ForgetPasswordViewController`, which took a number and a new password on one screen
    /// and posted them to `Account/update_password` — an endpoint that asks for no proof of ownership, so
    /// knowing someone's number was enough to take their account. `ForgotPasswordView` puts Android's
    /// Firebase phone verification in front of it.
    @IBAction func actionForgetPassword(_ sender: Any) {
        let reset = ForgotPasswordView(
            onFinished: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.showAlertView(message: "Password changed. Sign in with your new password.")
            },
            onCancel: { [weak self] in self?.navigationController?.popViewController(animated: true) })
        let controller = UIHostingController(rootView: reset)
        controller.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /// Used to push `VerifyNumberViewController`, a storyboard shell with a back button and no
    /// behaviour, so sign-up was a dead end. Now the real flow.
    @IBAction func actionNotMember(_ sender: Any) {
        let signUp = SignUpView(
            onRegistered: { [weak self] in self?.enterApp() },
            onCancel: { [weak self] in self?.navigationController?.popViewController(animated: true) })
        let controller = UIHostingController(rootView: signUp)
        controller.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func actionLoginAsCompany(_ sender: Any) {
        let companyLoginView = CompanyLoginView()
        let controller = UIHostingController(rootView: companyLoginView)
        controller.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
extension LoginViewController{

    /// Into the app with a session already stored — the tail of both sign-in and sign-up.
    func enterApp() {
        let storyBoard = UIStoryboard.init(name: "Drawer", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "KYDrawerController") as! KYDrawerController
        Global.shared.isLogedIn = true
        self.navigationController?.pushViewController(vc, animated: true)

        // Navigate to pending screen if any
        if let pending = Global.shared.pendingNavigationAfterLogin {
            Global.shared.pendingNavigationAfterLogin = nil
            GCD.async(.Main, delay: 0.5) {
                if let mainContainer = vc.mainViewController as? MainContainerViewController {
                    switch pending {
                    case "workshop":
                        mainContainer.showWorkshopController()
                    case "workshopAds":
                        mainContainer.showConsumerWorkshopAdsController()
                    default:
                        break
                    }
                }
            }
        }
    }

    func userLogin(params : ParamsAny){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getUserLogin(params: params) { (message, success) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        self.enterApp()
                    }
                    else{
                        self.showAlertView(message: message)
                    }
                }
            }
        }
    }
}
