//
//  MainContainerViewController.swift
//  GarageApp
//
//  Created by iOS Developer on 30/06/2020.
//  Copyright © 2020 Rapidzz. All rights reserved.
//

import UIKit

class MainContainerViewController: BaseViewController{
    
  
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblProfile: UIButton!
    @IBOutlet weak var lblFavorite: UIButton!
    @IBOutlet weak var imgHeart: UIImageView!
    @IBOutlet weak var lblLibarary: UIButton!
    @IBOutlet weak var imgLibarary: UIImageView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UIButton!
    @IBOutlet weak var lblHome: UIButton!
    @IBOutlet weak var imgHome: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var btnSeach: UIButton!
    
    weak var delegate:TopBarDelegate?
    var baseNavigationController:BaseNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.btnSeach.isHidden = true
        resetAllBottomViews()
        self.lblHome.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
        self.imgHome.tintColor = UIColor.init(hexFromString: "F2BE36")
        self.showHomeController()
    
    }
    
  
    
    func setTitle(title:String) {
        
        self.lblTitle.text = title
    }
    func setbackgroundColor(color:UIColor)  {
        //self.viewBackground.backgroundColor = color
    }

    
    func resetAllBottomViews(){
        
    self.lblHome.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblCategory.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblLibarary.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblFavorite.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblProfile.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.imgHome.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgCategory.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgLibarary.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgHeart.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgProfile.tintColor = UIColor.init(hexFromString: "A0A0A0")
    }
    
    @IBAction func actionSearch(_ sender: Any) {
       
    }
    
    func showSearchCompanyController(){
        self.resetAllBottomViews()
        self.lblLibarary.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
        self.imgLibarary.tintColor = UIColor.init(hexFromString: "F2BE36")
        self.showSearchController()
    }
    
    
    @IBAction func bottomBarAction(_ sender: UIButton) {
        self.btnBack.setImage(UIImage(named: "menu"), for: .normal)
        self.resetAllBottomViews()
        if(sender.tag == 0){
            self.lblHome.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgHome.tintColor = UIColor.init(hexFromString: "F2BE36")
           self.showHomeController()
            
            
        }
        else if(sender.tag == 1){
            self.lblCategory.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgCategory.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showWorkshopController()
            
        }
        else if(sender.tag == 2){
            self.lblLibarary.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgLibarary.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showSearchController()
            
        }
        else if(sender.tag == 3){
            
            self.lblFavorite.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgHeart.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showEsstimationController()
        }
        else{
            self.lblProfile.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgProfile.tintColor = UIColor.init(hexFromString: "F2BE36")
           self.showProfileController()
        }
    }
    
  

    func setBackButton(isback : Bool = false)  {
        if(isback){
            self.btnBack.setImage(UIImage(named: "Back arrow 3x-2"), for: .normal)
        }
        else{
            self.btnBack.setImage(UIImage(named: "menu"), for: .normal)
        }
      
      //  self.btnBack.removeTarget(nil, action: nil, for: .allEvents)

//            self.btnBack.addTarget(self, action: #selector(RegistrationMainContainerViewController.actionBack(_:)), for: .touchUpInside)
    }
    
    func showHomeController()  {
        self.topBarView.isHidden = false
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
   
    func showEsstimationController()  {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "EsstimationVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showSearchController()  {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "SearchVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    func showWorkshopController()  {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "WorkshopVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    func showProfileController()  {
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showWebController(title: String, link: String) {

        let storyBoard = UIStoryboard(name: "Home", bundle: nil)

        let controller = storyBoard.instantiateViewController(
            withIdentifier: "WebVC"
        ) as! BaseNavigationController

        guard let vc = controller.topViewController as? WebViewViewController else {
            return
        }

        vc.isFromSideMenu = true
        vc.containeTitle = title
        vc.link = link

        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }

        baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showFreelancersController() {
        // Hide the top bar for Freelancers screen (it has its own navigation)
        self.topBarView.isHidden = true
        
        let freelancersVC = FreelancersHostingController()
        let controller = BaseNavigationController(rootViewController: freelancersVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        
        baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    

    
    
    
   
    
      

    //MARK:- Action methods
    @IBAction func actionBack(_ sender:UIButton){
        if let del = self.delegate{
            del.actionBack()
        }
        else{
            if let drawerController = navigationController?.parent as? KYDrawerController {
                drawerController.setDrawerState(.opened, animated: true)
            }
        }
    }
    
    @IBAction func actionSideMenu(_ sender: Any) {
        
//        if let drawerController = navigationController?.parent as? KYDrawerController {
//            drawerController.setDrawerState(.opened, animated: true)
//        }
    }
    @IBAction func actionRightButton(_ sender: Any) {
        delegate?.rightButtonAction()
    }
    
    func logoutUser() {
      
        Global.shared.user = nil
        Global.shared.isLogedIn = false
        Global.shared.user = UserViewModel()
        UserDefaultsManager.shared.clearUserData()
        GCD.async(.Main, delay: 1) {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            if let container = self.navigationController?.parent as? KYDrawerController {
                container.navigationController?.setViewControllers([controller], animated: true)
                container.navigationController?.popToRootViewController(animated: true)
           }
         }
     }
    func loginUser() {
        Global.shared.user = nil
        UserDefaultsManager.shared.clearUserData()
        GCD.async(.Main, delay: 1) {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            if let container = self.navigationController?.parent as? KYDrawerController {
                container.navigationController?.setViewControllers([controller], animated: true)
                container.navigationController?.popToRootViewController(animated: true)
           }
         }
     }
    
}
