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

    private var freelanceDashboardPreviousController: BaseNavigationController?
    private var freelanceDashboardPreviousTopBarHidden: Bool = false
    private var freelanceDashboardPreviousBottomBarHidden: Bool = false
    
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
        self.bottomBarView.isHidden = false
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
        self.bottomBarView.isHidden = false
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
        self.bottomBarView.isHidden = false
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
        self.bottomBarView.isHidden = false
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
        self.bottomBarView.isHidden = false
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

        self.bottomBarView.isHidden = false

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
        self.bottomBarView.isHidden = false
        
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

    func showFreelanceDashboardController() {
        if let oldRef = baseNavigationController {
            freelanceDashboardPreviousController = oldRef
            freelanceDashboardPreviousTopBarHidden = topBarView.isHidden
            freelanceDashboardPreviousBottomBarHidden = bottomBarView.isHidden
        }

        self.topBarView.isHidden = true
        self.bottomBarView.isHidden = true

        let dashboardVC = FreelanceDashboardHostingController()
        let controller = BaseNavigationController(rootViewController: dashboardVC)
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

    func dismissFreelanceDashboardController() {
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }

        if let previous = freelanceDashboardPreviousController {
            self.topBarView.isHidden = freelanceDashboardPreviousTopBarHidden
            self.bottomBarView.isHidden = freelanceDashboardPreviousBottomBarHidden

            baseNavigationController = previous
            addChild(previous)
            previous.view.frame = containerView.bounds
            containerView.addSubview(previous.view)
            previous.didMove(toParent: self)
        }
        else {
            showHomeController()
        }

        freelanceDashboardPreviousController = nil
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
    /// Logs out the current user (user or company).
    /// - Parameter showSuccessAlert: if true, shows a 3-second auto-dismissing
    ///   "logged out" message on the login screen after navigation.
    func logoutUser(showSuccessAlert: Bool = false) {
      
        Global.shared.user = nil
        Global.shared.companyVendor = nil
        Global.shared.isLogedIn = false
        Global.shared.loginType = ""
        UserDefaultsManager.shared.clearAllLoginData()

        GCD.async(.Main) {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

            // Case 1: Login -> (nav) -> KYDrawerController stack
            if let drawer = self.navigationController?.parent as? KYDrawerController,
               let outerNav = drawer.navigationController {
                outerNav.setViewControllers([loginVC], animated: true)

                if showSuccessAlert {
                    self.showLogoutSuccessAlert(on: loginVC)
                }
                return
            }

            // Case 2: App launched directly into KYDrawerController (SceneDelegate)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {

                let nav = UINavigationController(rootViewController: loginVC)
                nav.navigationBar.isHidden = true
                window.rootViewController = nav
                window.makeKeyAndVisible()

                if showSuccessAlert {
                    self.showLogoutSuccessAlert(on: loginVC)
                }
            }
        }
     }

    private func showLogoutSuccessAlert(on controller: UIViewController) {
        // Small delay to ensure navigation has finished before presenting.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(
                title: LocalStrings.success,
                message: "You have been logged out successfully",
                preferredStyle: .alert
            )
            controller.present(alert, animated: true, completion: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

    func loginUser() {
        Global.shared.user = nil
        Global.shared.companyVendor = nil
        Global.shared.isLogedIn = false
        Global.shared.loginType = ""
        UserDefaultsManager.shared.clearAllLoginData()

        GCD.async(.Main) {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

            // Case 1: App was launched from Login inside a navigation controller
            // and KYDrawerController was pushed on top. In this case we can
            // simply reset the outer navigation controller's stack.
            if let drawer = self.navigationController?.parent as? KYDrawerController,
               let outerNav = drawer.navigationController {
                outerNav.setViewControllers([loginVC], animated: true)
                return
            }

            // Case 2: App was launched directly into KYDrawerController (e.g. via
            // SceneDelegate auto-login). In this case there may not be an outer
            // navigation controller, so we replace the window's root controller
            // with a fresh navigation controller containing the login screen.
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {

                let nav = UINavigationController(rootViewController: loginVC)
                nav.navigationBar.isHidden = true
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
     }
    
}
