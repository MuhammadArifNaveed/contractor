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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
