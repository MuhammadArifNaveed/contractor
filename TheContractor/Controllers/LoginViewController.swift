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

    private lazy var loginAsCompanyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login as a Company", for: .normal)
        button.titleLabel?.font = AppFonts.CenturyGolthicRegularWith(size: 16)
        button.setTitleColor(AppColors.yellow, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.yellow.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: #selector(actionLoginAsCompany(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = AppFonts.CenturyGolthicRegularWith(size: 14)
        button.setTitleColor(AppColors.yellow, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(actionForgetPassword(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New here? Create an account", for: .normal)
        button.titleLabel?.font = AppFonts.CenturyGolthicRegularWith(size: 14)
        button.setTitleColor(AppColors.yellow, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(actionNotMember(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginAsCompanyButton()
        setupForgotPasswordButton()
        setupCreateAccountButton()
    }

    private func setupCreateAccountButton() {
        view.addSubview(createAccountButton)
        NSLayoutConstraint.activate([
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            createAccountButton.bottomAnchor.constraint(equalTo: forgotPasswordButton.topAnchor, constant: -4),
            createAccountButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupForgotPasswordButton() {
        view.addSubview(forgotPasswordButton)
        NSLayoutConstraint.activate([
            forgotPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: loginAsCompanyButton.topAnchor, constant: -12),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupLoginAsCompanyButton() {
        view.addSubview(loginAsCompanyButton)

        NSLayoutConstraint.activate([
            loginAsCompanyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginAsCompanyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginAsCompanyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            loginAsCompanyButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    @IBAction func actionSkip(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Drawer", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "KYDrawerController") as! KYDrawerController
        Global.shared.isLogedIn = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionLogin(_ sender: Any) {
        let phoneNumber = self.txtNumber.text ?? ""
        let password = self.txtPin.text ?? ""

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
            "firebase_token": Global.shared.fcmToken.isEmpty ? "testtoken123" : Global.shared.fcmToken
        ]
        self.userLogin(params: params)
    }
    
    @IBAction func actionForgetPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordViewController") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
                    if pending == "workshop" {
                        mainContainer.showWorkshopController()
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
