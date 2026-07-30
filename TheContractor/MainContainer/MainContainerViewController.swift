//
//  MainContainerViewController.swift
//  GarageApp
//
//  Created by iOS Developer on 30/06/2020.
//  Copyright © 2020 Rapidzz. All rights reserved.
//

import UIKit
import SwiftUI

class MainContainerViewController: BaseViewController{
    
  
    @IBOutlet weak var imgLogo: UIImageView?
    @IBOutlet weak var imgProfile: UIImageView?
    @IBOutlet weak var imgCategory: UIImageView?
    @IBOutlet weak var imgHeart: UIImageView?
    @IBOutlet weak var imgLibarary: UIImageView?
    @IBOutlet weak var lblProfile: UIButton?
    @IBOutlet weak var lblEstimation: UIButton?
    @IBOutlet weak var imgEstimation: UIImageView?
    @IBOutlet weak var lblSearch: UIButton?
    @IBOutlet weak var imgSearch: UIImageView?
    @IBOutlet weak var imgWorkshop: UIImageView?
    @IBOutlet weak var lblWorkshop: UIButton?
    @IBOutlet weak var lblHome: UIButton?
    @IBOutlet weak var lblCategory: UIButton?
    @IBOutlet weak var lblFavorite: UIButton?
    @IBOutlet weak var lblLibarary: UIButton?
    @IBOutlet weak var imgHome: UIImageView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var topBarView: UIView?
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var bottomBarView: UIView?
    @IBOutlet weak var btnSeach: UIButton?
    
    // Top bar buttons (created programmatically)
    private var btnQuotationByPhoto: UIButton?
    private var btn24x7Maintenance: UIButton?
    private var btnCartTop: UIButton?
    private var imgAppLogo: UIImageView?
    
    weak var delegate:TopBarDelegate?
    var baseNavigationController:BaseNavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopNavigationBar()
        setupWorkshopTab()
        resetAllBottomViews()
        
        // Companies get Android's VendorHome, not the consumer home screen, and Android's
        // vendor activity has no bottom tab bar at all.
        if Global.shared.isVendor {
            topBarView?.isHidden = true
            bottomBarView?.isHidden = true
            self.showVendorHome()
        } else {
            self.lblHome?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgHome?.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showHomeController()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleGoBackToTabBar), name: .init("GoBackToTabBar"), object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Tab bar / top bar visibility helpers

    /// Call this before showing any side-menu screen. Hides the global top bar and bottom tab bar.
    func hideForSideMenu() {
        topBarView?.isHidden = true
        bottomBarView?.isHidden = true
    }

    /// Call this for every primary tab screen (Home, Workshop, Search, Estimation, Profile).
    private func showBarsForTab() {
        topBarView?.isHidden = false
        bottomBarView?.isHidden = false
    }

    @objc private func handleGoBackToTabBar() {
        showBarsForTab()
        resetAllBottomViews()
        lblHome?.setTitleColor(UIColor(hexFromString: "F2BE36"), for: .normal)
        imgHome?.tintColor = UIColor(hexFromString: "F2BE36")
        showHomeController()
    }
    
  
    
    func setTitle(title:String) {
        
        self.lblTitle?.text = title
    }
    
    // MARK: - Setup Top Navigation Bar Programmatically
    private func setupTopNavigationBar() {
        guard let topBar = topBarView else { return }
        
        // Set background color to match Android yellow (#f2be36)
        topBar.backgroundColor = UIColor(hexFromString: "#f2be36")
        
        // Ensure hamburger menu button is visible and styled
        btnBack?.isHidden = false
        btnBack?.tintColor = .white
        btnBack?.setImage(UIImage(named: "menu"), for: .normal)
        
        // Create horizontal stack view for all elements
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. App Logo (after hamburger menu which is already in storyboard)
        let logoImageView = UIImageView()
        if let logoImage = UIImage(named: "topicon") {
            logoImageView.image = logoImage
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            logoImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            logoImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            self.imgAppLogo = logoImageView
            stackView.addArrangedSubview(logoImageView)
        }
        
        // Spacer to push buttons to the right
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacer)
        
        // 2. "Quotation By Photo" Button (Green)
        let quotationButton = UIButton(type: .system)
        quotationButton.setTitle("Quotation By Photo", for: .normal)
        quotationButton.backgroundColor = UIColor(hexFromString: "#019C53")
        quotationButton.setTitleColor(.white, for: .normal)
        quotationButton.titleLabel?.font = .systemFont(ofSize: 9, weight: .medium)
        quotationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        quotationButton.titleLabel?.minimumScaleFactor = 0.7
        quotationButton.layer.cornerRadius = 4
        quotationButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6)
        quotationButton.translatesAutoresizingMaskIntoConstraints = false
        quotationButton.addTarget(self, action: #selector(actionQuotationByPhoto), for: .touchUpInside)
        self.btnQuotationByPhoto = quotationButton
        stackView.addArrangedSubview(quotationButton)
        
        // 3. "24/7 Maintenance" Button (Red)
        let maintenanceButton = UIButton(type: .system)
        maintenanceButton.setTitle("24/7 Maintenance", for: .normal)
        maintenanceButton.backgroundColor = UIColor.init(hexFromString: "#D51F1F")
        maintenanceButton.setTitleColor(.white, for: .normal)
        maintenanceButton.titleLabel?.font = .systemFont(ofSize: 9, weight: .medium)
        maintenanceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        maintenanceButton.titleLabel?.minimumScaleFactor = 0.7
        maintenanceButton.layer.cornerRadius = 4
        maintenanceButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6)
        maintenanceButton.translatesAutoresizingMaskIntoConstraints = false
        maintenanceButton.addTarget(self, action: #selector(action24x7Maintenance), for: .touchUpInside)
        self.btn24x7Maintenance = maintenanceButton
        stackView.addArrangedSubview(maintenanceButton)
        
        // 4. Cart Button (optional, can be added later if needed)
        // Uncomment if cart functionality is required
        /*
        let cartButton = UIButton(type: .system)
        cartButton.setImage(UIImage(systemName: "cart.fill"), for: .normal)
        cartButton.tintColor = .white
        cartButton.translatesAutoresizingMaskIntoConstraints = false
        cartButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cartButton.addTarget(self, action: #selector(actionCart), for: .touchUpInside)
        self.btnCartTop = cartButton
        stackView.addArrangedSubview(cartButton)
        */
        
        // Add stack view to top bar
        topBar.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 50), // Space for hamburger menu
            stackView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            stackView.heightAnchor.constraint(equalTo: topBar.heightAnchor, multiplier: 0.8)
        ])
    }
    
    // MARK: - Setup Workshop Tab
    private func setupWorkshopTab() {
        // Ensure Workshop tab is visible (it may be hidden in storyboard)
        lblWorkshop?.isHidden = false
        imgWorkshop?.isHidden = false
        
        // Set icon and color
        imgWorkshop?.tintColor = UIColor(hexFromString: "A0A0A0")
        lblWorkshop?.setTitleColor(UIColor(hexFromString: "A0A0A0"), for: .normal)
    }
    
    // MARK: - Top Bar Button Actions
    @objc private func actionQuotationByPhoto() {
        // Navigate to Submit Quotation (with login check matching Android)
        if Global.shared.isLogedIn {
            showSubmitQuotationController()
        } else {
            loginUser()
        }
    }
    
    @objc private func action24x7Maintenance() {
        // Navigate to 24/7 maintenance (no login required matching Android)
        show24x7MaintenanceController()
    }
    
    @objc private func actionCart() {
        // Navigate to cart screen
        showCartController()
    }
    func setbackgroundColor(color:UIColor)  {
        //self.viewBackground.backgroundColor = color
    }

    
    func resetAllBottomViews(){
        let gray = UIColor.init(hexFromString: "A0A0A0")
        self.lblHome?.setTitleColor(gray, for: .normal)
        self.lblWorkshop?.setTitleColor(gray, for: .normal)
        self.lblSearch?.setTitleColor(gray, for: .normal)
        self.lblEstimation?.setTitleColor(gray, for: .normal)
        self.lblProfile?.setTitleColor(gray, for: .normal)
        self.imgHome?.tintColor = gray
        self.imgWorkshop?.tintColor = gray
        self.imgSearch?.tintColor = gray
        self.imgEstimation?.tintColor = gray
        self.imgProfile?.tintColor = gray
        // lblFavorite/imgHeart are the actual Estimation tab outlets (storyboard naming)
        self.lblFavorite?.setTitleColor(gray, for: .normal)
        self.imgHeart?.tintColor = gray
        // Search button outlet not connected - find by title traversal
        setTabButton(withTitle: "Search", color: gray, in: bottomBarView)
        // Also reset ALL imageViews in bottom bar that are tab icons
        resetAllTabImageViews(in: bottomBarView, color: gray)
    }

    // MARK: - Tab color helpers
    private func setTabButton(withTitle title: String, color: UIColor, in view: UIView?) {
        guard let view = view else { return }
        for sub in view.subviews {
            if let btn = sub as? UIButton, btn.title(for: .normal) == title {
                btn.setTitleColor(color, for: .normal)
                btn.tintColor = color
                return
            }
            setTabButton(withTitle: title, color: color, in: sub)
        }
    }

    private func resetAllTabImageViews(in view: UIView?, color: UIColor) {
        guard let view = view else { return }
        for sub in view.subviews {
            if let img = sub as? UIImageView, img.isUserInteractionEnabled == false {
                img.tintColor = color
            }
            resetAllTabImageViews(in: sub, color: color)
        }
    }
    
    @IBAction func actionSearch(_ sender: Any) {
       
    }
    
    func showSearchCompanyController(){
        self.resetAllBottomViews()
        self.lblSearch?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
        self.imgSearch?.tintColor = UIColor.init(hexFromString: "F2BE36")
        self.showSearchController()
    }
    
    
    @IBAction func bottomBarAction(_ sender: UIButton) {
        self.btnBack?.setImage(UIImage(named: "menu"), for: .normal)
        self.showBarsForTab()
        self.resetAllBottomViews()
        if(sender.tag == 0){
            // Home
            self.lblHome?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgHome?.tintColor = UIColor.init(hexFromString: "F2BE36")
           self.showHomeController()
        }
        else if(sender.tag == 1){
            // Workshop
            self.lblWorkshop?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgWorkshop?.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showWorkshopController()
        }
        else if(sender.tag == 2){
            // Search - outlet not connected, find button by title and highlight sibling imageView
            self.lblSearch?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgSearch?.tintColor = UIColor.init(hexFromString: "F2BE36")
            setTabButton(withTitle: "Search", color: UIColor.init(hexFromString: "F2BE36"), in: bottomBarView)
            if let container = sender.superview {
                for sub in container.subviews where sub is UIImageView {
                    (sub as! UIImageView).tintColor = UIColor.init(hexFromString: "F2BE36")
                }
            }
            self.showSearchController()
        }
        else if(sender.tag == 3){
            // Estimation - lblFavorite/imgHeart are the actual storyboard outlets
            self.lblEstimation?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.lblFavorite?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgEstimation?.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.imgHeart?.tintColor = UIColor.init(hexFromString: "F2BE36")
            if let container = sender.superview {
                for sub in container.subviews where sub is UIImageView {
                    (sub as! UIImageView).tintColor = UIColor.init(hexFromString: "F2BE36")
                }
            }
            self.showEsstimationController()
        }
        else{
            // Profile
            self.lblProfile?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgProfile?.tintColor = UIColor.init(hexFromString: "F2BE36")
           self.showProfileController()
        }
    }
    
  

    func setBackButton(isback : Bool = false)  {
        if(isback){
            self.btnBack?.setImage(UIImage(named: "Back arrow 3x-2"), for: .normal)
        }
        else{
            self.btnBack?.setImage(UIImage(named: "menu"), for: .normal)
        }
      
      //  self.btnBack.removeTarget(nil, action: nil, for: .allEvents)

//            self.btnBack.addTarget(self, action: #selector(RegistrationMainContainerViewController.actionBack(_:)), for: .touchUpInside)
    }
    
    func showHomeController()  {
        self.showBarsForTab()
        
        let homeVC = HomeHostingController()
        let controller = BaseNavigationController(rootViewController: homeVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else {
            return
        }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
   
    func showEsstimationController()  {
        self.showBarsForTab()
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "EsstimationVC") as! BaseNavigationController
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else {
            return
        }

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showSearchController()  {
        self.showBarsForTab()
        
        let searchVC = SearchHostingController()
        let controller = BaseNavigationController(rootViewController: searchVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else {
            return
        }

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    func showWorkshopController()  {
        self.showBarsForTab()
        // Workshop requires login (matching Android behavior)
        guard Global.shared.isLogedIn else {
            // Store that user wants to navigate to Workshop after login
            Global.shared.pendingNavigationAfterLogin = "workshop"
            loginUser()
            return
        }
        
        let workshopVC = WorkshopPostHostingController()
        let controller = BaseNavigationController(rootViewController: workshopVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else {
            return
        }

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()

            oldRef.view.removeFromSuperview()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    func showProfileController()  {
        self.showBarsForTab()
        
        let profileVC = ProfileHostingController()
        let controller = BaseNavigationController(rootViewController: profileVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else {
            return
        }

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    // MARK: - New Navigation Methods for Side Menu
    
    func showEnquiriesController() {
        self.hideForSideMenu()
        let enquiriesVC = EnquiriesHostingController()
        let controller = BaseNavigationController(rootViewController: enquiriesVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showQuotationsController() {
        self.hideForSideMenu()
        let quotationsVC = QuotationsHostingController()
        let controller = BaseNavigationController(rootViewController: quotationsVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showComplaintsController() {
        self.hideForSideMenu()
        let complaintsVC = ComplaintsHostingController()
        let controller = BaseNavigationController(rootViewController: complaintsVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showChatListController() {
        self.hideForSideMenu()
        let chatVC = ChatListHostingController()
        let controller = BaseNavigationController(rootViewController: chatVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showCartController() {
        self.hideForSideMenu()
        let cartVC = CartHostingController()
        let controller = BaseNavigationController(rootViewController: cartVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showSubmitQuotationController() {
        self.hideForSideMenu()
        let submitQuotationVC = SubmitQuotationHostingController()
        let controller = BaseNavigationController(rootViewController: submitQuotationVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func show24x7MaintenanceController() {
        self.hideForSideMenu()
        let maintenanceVC = TwentyFourSevenHostingController()
        let controller = BaseNavigationController(rootViewController: maintenanceVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showAdvertiseCompanyController() {
        self.hideForSideMenu()
        let advertiseVC = AdvertiseCompanyHostingController()
        let controller = BaseNavigationController(rootViewController: advertiseVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showAvailableJobsController() {
        self.hideForSideMenu()
        let jobsVC = AvailableJobsHostingController()
        let controller = BaseNavigationController(rootViewController: jobsVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showMyJobApplicationsController() {
        self.hideForSideMenu()
        let applicationsVC = MyJobApplicationsHostingController()
        let controller = BaseNavigationController(rootViewController: applicationsVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showDirectHiringController() {
        self.hideForSideMenu()
        let directHiringVC = DirectHiringHostingController()
        let controller = BaseNavigationController(rootViewController: directHiringVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showFreelanceDashboardController() {
        self.hideForSideMenu()
        let dashboardVC = FreelanceDashboardHostingController()
        let controller = BaseNavigationController(rootViewController: dashboardVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true
        
        guard let containerView = self.containerView else { return }
        
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showWebController(title: String, link: String) {
        self.hideForSideMenu()
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

        guard let containerView = self.containerView else {
            return
        }

        baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    func showFreelancersController() {
        self.hideForSideMenu()
        let freelancersVC = FreelancersHostingController()
        let controller = BaseNavigationController(rootViewController: freelancersVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showCompanyLoginController() {
        self.hideForSideMenu()
        let companyLoginVC = CompanyLoginHostingController()
        let controller = BaseNavigationController(rootViewController: companyLoginVC)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showVendorEnquiriesController() {
        self.hideForSideMenu()
        let vc = VendorEnquiriesHostingController()
        let controller = BaseNavigationController(rootViewController: vc)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showVendorQuotationsController() {
        self.hideForSideMenu()
        let vc = VendorQuotationsHostingController()
        let controller = BaseNavigationController(rootViewController: vc)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showVendorJobsController() {
        self.hideForSideMenu()
        let vc = VendorJobsHostingController()
        let controller = BaseNavigationController(rootViewController: vc)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showVendorWorkshopController() {
        self.hideForSideMenu()
        let vc = VendorWorkshopHostingController()
        let controller = BaseNavigationController(rootViewController: vc)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    func showVendorAddWorkshopController() {
        self.hideForSideMenu()
        let vc = VendorAddWorkshopHostingController()
        let controller = BaseNavigationController(rootViewController: vc)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }
        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
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
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    @IBAction func actionRightButton(_ sender: Any) {
        delegate?.rightButtonAction()
    }
    
    func logoutUser() {
        // Clear all user data including vendor data
        Global.shared.user = nil
        Global.shared.isLogedIn = false
        Global.shared.isVendor = false
        Global.shared.loginType = ""
        Global.shared.user = UserViewModel()
        
        // Clear UserDefaults including vendor data. `clearAllLoginData()` rather than
        // `clearUserData()` because the latter leaves `isCompanyLoggedIn` set, which would send
        // SceneDelegate straight back into the vendor dashboard on the next launch.
        UserDefaultsManager.shared.clearAllLoginData()
        UserDefaults.standard.removeObject(forKey: "vendor")
        UserDefaults.standard.removeObject(forKey: "isVendor")
        UserDefaults.standard.removeObject(forKey: "loginType")
        UserDefaults.standard.synchronize()
        
        GCD.async(.Main, delay: 1) {
            let storyboard = UIStoryboard(name: "Registration", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            if let container = self.navigationController?.parent as? KYDrawerController {
                container.navigationController?.setViewControllers([controller], animated: true)
                container.navigationController?.popToRootViewController(animated: true)
           }
         }
     }
    
    /// Embeds a SwiftUI vendor screen in the container the same way every UIKit screen is embedded,
    /// so the drawer stays reachable. Replacing the drawer's own navigation stack (which the old
    /// `showVendorHome()` did) tore the hamburger out of the hierarchy.
    func showVendorScreen<Content: View>(_ rootView: Content) {
        self.hideForSideMenu()
        let hostingController = UIHostingController(rootView: rootView)
        let controller = BaseNavigationController(rootViewController: hostingController)
        controller.interactivePopGestureRecognizer?.isEnabled = false
        controller.navigationBar.isHidden = true

        guard let containerView = self.containerView else { return }

        if let oldRef = baseNavigationController {
            oldRef.willMove(toParent: nil)
            oldRef.view.removeFromSuperview()
            oldRef.removeFromParent()
        }
        self.baseNavigationController = controller
        addChild(controller)
        controller.view.frame = containerView.bounds
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

    /// Company landing screen — Android's `VendorHome`.
    func showVendorHome() {
        showVendorScreen(VendorHomeView())
    }

    /// Android `VendorRating`.
    func showVendorRatingController() {
        showVendorScreen(VendorReviewsView())
    }

    /// Android `VendorMembership`.
    func showVendorMembershipsController() {
        showVendorScreen(VendorSubscriptionView())
    }

    /// Android `VendorMyMembership`.
    func showVendorMyMembershipController() {
        showVendorScreen(VendorMyMembershipView())
    }

    /// Android `VendorInterestedWorkshops`.
    func showVendorInterestedWorkshopsController() {
        showVendorScreen(VendorInterestedWorkshopsView())
    }

    /// Android `WorkShopAds` with `type=vendor`.
    func showVendorMyWorkshopsController() {
        showVendorScreen(VendorMyWorkshopsView())
    }

    /// Android `VendorAllWorkshopsAds`.
    func showVendorAllWorkshopsController() {
        showVendorScreen(VendorAllWorkshopsView())
    }

    /// Android `VendorApplicants` — the drawer item "Available Applicant".
    func showVendorAvailableApplicantsController() {
        showVendorScreen(VendorAvailableApplicantsView())
    }

    /// Android `VendorDashboardFreelancer`.
    func showVendorFreelancerDashboardController() {
        showVendorScreen(VendorFreelancersView())
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
