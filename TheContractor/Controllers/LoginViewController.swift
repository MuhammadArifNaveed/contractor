//
//  LoginViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/26/21.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add "Login as a Company" button programmatically so no storyboard changes are needed.
        setupLoginAsCompanyButton()
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
        let number = "+971\(self.txtNumber.text ?? "")"
        let params : ParamsAny = ["user_phone" : number,"user_password": self.txtPin.text ?? "" , "device_type" :"ios","firebase_token" : "testtoken123"]
        self.userLogin(params: params)
    }
    
    @IBAction func actionForgetPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordViewController") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func actionNotMember(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VerifyNumberViewController") as! VerifyNumberViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func actionLoginAsCompany(_ sender: Any) {
        let controller = CompanyLoginHostingController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
extension LoginViewController{
    func userLogin(params : ParamsAny){
        self.startActivity()
        GCD.async(.Background){
            LoginService.shared().getUserLogin(params: params) { (message, success) in
                GCD.async(.Main){
                    self.stopActivity()
                    if(success){
                        let storyBoard = UIStoryboard.init(name: "Drawer", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "KYDrawerController") as! KYDrawerController
                        Global.shared.isLogedIn = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else{
                        self.showAlertView(message: message)
                    }
                }
            }
        }
    }
}
