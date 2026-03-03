//
//  MainContainerViewController.swift
//  GarageApp
//
//  Created by iOS Developer on 30/06/2020.
//  Copyright © 2020 Rapidzz. All rights reserved.
//

import UIKit

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
      //  self.btnSeach.isHidden = true
        setupTopNavigationBar()
        setupWorkshopTab()
        resetAllBottomViews()
        self.lblHome?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
        self.imgHome?.tintColor = UIColor.init(hexFromString: "F2BE36")
        self.showHomeController()
    
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
        
    self.lblHome?.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblWorkshop?.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblSearch?.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblEstimation?.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.lblProfile?.setTitleColor(UIColor.init(hexFromString: "A0A0A0"), for: .normal)
    self.imgHome?.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgWorkshop?.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgSearch?.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgEstimation?.tintColor = UIColor.init(hexFromString: "A0A0A0")
    self.imgProfile?.tintColor = UIColor.init(hexFromString: "A0A0A0")
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
            // Search
            self.lblSearch?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgSearch?.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showSearchController()
        }
        else if(sender.tag == 3){
            // Estimation
            self.lblEstimation?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgEstimation?.tintColor = UIColor.init(hexFromString: "F2BE36")
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
        // Keep the top bar visible for home screen to show navigation buttons
        self.topBarView?.isHidden = false
        
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
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "SearchVC") as! BaseNavigationController
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
    func showWorkshopController()  {
        // Workshop requires login (matching Android behavior)
        guard Global.shared.isLogedIn else {
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
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        var controller = BaseNavigationController()
        controller = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! BaseNavigationController
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
    
    // MARK: - New Navigation Methods for Side Menu
    
    func showEnquiriesController() {
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        self.topBarView?.isHidden = false
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
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "Freelancers will be available in an upcoming update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
