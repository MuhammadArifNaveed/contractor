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
            if let containerView = containerView {
                containerView.backgroundColor = UIColor(hexFromString: "F4F4F6")
                installStatusBarUnderlay(below: containerView)
            }
            self.showVendorHome()
        } else {
            if let topBarView = topBarView {
                installStatusBarUnderlay(below: topBarView)
            }
            self.lblHome?.setTitleColor(UIColor.init(hexFromString: "F2BE36"), for: .normal)
            self.imgHome?.tintColor = UIColor.init(hexFromString: "F2BE36")
            self.showHomeController()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleGoBackToTabBar), name: .init("GoBackToTabBar"), object: nil)
        // A SwiftUI tab screen that hits a signed-in-only action asks for the login screen this way.
        // "GoToLogin" is observed by ProfileHostingController, which is not installed while another
        // tab is showing, so it cannot serve that purpose.
        NotificationCenter.default.addObserver(self, selector: #selector(handleRequestLogin), name: .init("RequestLogin"), object: nil)
    }

    @objc private func handleRequestLogin() {
        loginUser()
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
        
        // The two actions used to be saturated green and red rectangles carrying 9pt text that
        // shrank further to fit — three competing colours in one bar, below any legible size, and
        // under the 44pt tap minimum. They are now consistent white pills: same shape, same type,
        // the colour kept only on the icon so the actions stay recognisable.
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // The storyboard ships its own logo image view in this bar. Leaving it visible put two copies
        // of the mark on top of each other.
        imgLogo?.isHidden = true

        // Logo. The asset is letterboxed on an opaque white background, which reads as a sticker
        // pasted onto the yellow, so it is clipped to a rounded rect to look deliberate.
        let logoImageView = UIImageView(image: UIImage(named: "logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.layer.cornerRadius = 5
        logoImageView.layer.cornerCurve = .continuous
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: 92).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.imgAppLogo = logoImageView
        stackView.addArrangedSubview(logoImageView)

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacer)

        let quotationButton = makeTopBarAction(
            title: "Quote",
            systemImage: "camera.fill",
            tint: UIColor(hexFromString: "#019C53"),
            action: #selector(actionQuotationByPhoto))
        self.btnQuotationByPhoto = quotationButton
        stackView.addArrangedSubview(quotationButton)

        let maintenanceButton = makeTopBarAction(
            title: "24/7",
            systemImage: "wrench.and.screwdriver.fill",
            tint: UIColor(hexFromString: "#D51F1F"),
            action: #selector(action24x7Maintenance))
        self.btn24x7Maintenance = maintenanceButton
        stackView.addArrangedSubview(maintenanceButton)

        topBar.addSubview(stackView)

        NSLayoutConstraint.activate([
            // Clears the hamburger, which lives in the storyboard.
            stackView.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 52),
            stackView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 38)
        ])
    }

    /// Fills the strip between the screen edge and the top bar with the accent, so the status bar and
    /// the bar below it read as one surface.
    ///
    /// Neither bar reaches the screen edge on its own: the consumer `topBarView` starts at the safe
    /// area, and for companies it is hidden entirely and the SwiftUI bar sits inside `containerView`,
    /// which begins below the hidden slot. Either way the two yellows were separated by a white seam.
    /// Tinting the whole view instead would bleed yellow into the hidden tab bar's slot at the bottom.
    private func installStatusBarUnderlay(below anchorView: UIView) {
        view.backgroundColor = UIColor(hexFromString: "F4F4F6")

        let underlay = UIView()
        underlay.backgroundColor = UIColor(hexFromString: "F2BE36")
        underlay.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(underlay, at: 0)

        NSLayoutConstraint.activate([
            underlay.topAnchor.constraint(equalTo: view.topAnchor),
            underlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            underlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            underlay.bottomAnchor.constraint(equalTo: anchorView.topAnchor)
        ])
    }

    /// One shape for every top-bar action: white pill, tinted icon, 12pt semibold label, 38pt tall
    /// with generous horizontal padding.
    private func makeTopBarAction(title: String, systemImage: String, tint: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: systemImage,
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)),
                        for: .normal)
        button.tintColor = tint
        button.setTitleColor(UIColor(hexFromString: "#1A1400"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 19
        button.layer.cornerCurve = .continuous
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 38).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        controller.didMove(toParent: self)
    }
   
    /// The Estimation tab — Android's `EstimationFragment`. The storyboard screen this replaces could
    /// only calculate a figure; it had no way to ask for the free consultation the calculation is for.
    func showEsstimationController()  {
        self.showBarsForTab()
        showTabScreen(EstimationView())
    }

    /// Embeds a SwiftUI screen as a bottom-tab root, leaving the tab bars up rather than hiding them
    /// the way `showVendorScreen` does for a drawer item.
    ///
    /// `containerView` is pinned to all four edges of the root view — it runs the full height of the
    /// screen, with the top and bottom bars drawn *over* it. A screen embedded at `containerView.bounds`
    /// therefore has its first ~45pt hidden behind the yellow bar. The older tab screens work around
    /// that by drawing their own copy of the bar underneath it (which is where the doubled logo came
    /// from); this pins the content between the two bars instead, so a SwiftUI tab screen needs to know
    /// nothing about them.
    func showTabScreen<Content: View>(_ rootView: Content) {
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
        containerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: topBarView?.bottomAnchor ?? containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomBarView?.topAnchor ?? containerView.bottomAnchor)
        ])
        controller.didMove(toParent: self)
    }

    /// The user's own estimate requests — Android's `Estimations`, opened from the drawer and from the
    /// profile screen. Both used to open the calculator, leaving submitted requests unreachable.
    func showEstimationRequestsController() {
        showVendorScreen(EstimationRequestsView())
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        controller.didMove(toParent: self)
    }
    /// The consumer's own workshop ads — Android's `WorkShopAds` with `type=user`. Login-gated the
    /// same way the post form is.
    func showConsumerWorkshopAdsController() {
        guard Global.shared.isLogedIn else {
            Global.shared.pendingNavigationAfterLogin = "workshopAds"
            loginUser()
            return
        }
        showVendorScreen(WorkshopAdsView())
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        controller.didMove(toParent: self)
    }
    
    /// Consumer Inbox — Android's `ChatConnection` + `Chat`, on Firestore. The screen this replaces said
    /// "not available yet"; before that it called `Home/get_chats`, which the backend has never served.
    func showChatListController() {
        showVendorScreen(InboxView(role: .user,
                                   onBack: { NotificationCenter.default.post(name: .init("GoBackToTabBar"), object: nil) }))
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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
        
        GCD.async(.Main, delay: 1) { [weak self] in
            self?.showLoginScreen()
        }
     }

    /// Puts the login screen on screen, whichever way the drawer happens to be installed.
    ///
    /// Both sign-out and the "you need an account for this" prompt used to do this inline, by casting
    /// `navigationController?.parent` to `KYDrawerController` and then driving
    /// `container.navigationController`. **That inner optional is nil whenever the drawer is the window's
    /// root view controller** — which is how `CompanyLoginView` installs it (`window.rootViewController =
    /// drawer`) and how `SceneDelegate` installs it for an already-signed-in launch. The cast succeeded,
    /// both navigation calls went to nil, and the app silently stayed exactly where it was: signing out of
    /// a company and then asking for the consumer login did nothing at all until the app was relaunched.
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as? LoginViewController else { return }

        // The drawer was pushed onto the storyboard's own login stack — reuse it, which is what shipped
        // and what still happens on a cold launch with no stored session.
        if let drawerNavigation = (navigationController?.parent as? KYDrawerController)?.navigationController {
            drawerNavigation.setNavigationBarHidden(true, animated: false)
            drawerNavigation.setViewControllers([controller], animated: true)
            return
        }

        // The drawer is the window's root, so there is no stack to reuse and one has to be built.
        // `LoginViewController` does not work without it: Skip, Forgot password, Sign up, Login as a
        // company and `enterApp()` all push onto `self.navigationController`.
        guard let window = view.window else { return }
        let navigation = UINavigationController(rootViewController: controller)
        navigation.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navigation
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve,
                          animations: nil, completion: nil)
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
        // Pinned rather than frame-set: `containerView.bounds` is only correct at the instant it is
        // read, and the container is still settling here because `hideForSideMenu()` has just
        // changed which bars are visible. A one-shot frame left every hosted screen with a stale
        // height, which is what made the yellow top bar sit at a different offset per screen.
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
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

    /// Android `Freelancers` with `from=vendor`, plus the hire path.
    func showVendorHireFreelancerController() {
        showVendorScreen(VendorHireFreelancerView())
    }

    /// The vendor inbox is Firebase Firestore on Android and iOS has no Firebase set up, so this is a
    /// placeholder rather than a screen wired to the wrong endpoint. See COMPANY_SIDE_ROADMAP.md.
    /// Company Inbox — Android's `VendorChatConnection` + `VendorChat`. Same collections as the consumer
    /// side; only the uuid the inbox filters on and what `sent_by` records differ.
    func showVendorInboxComingSoon() {
        showVendorScreen(InboxView(role: .company))
    }

    /// Android `VendorPostWorkshop`.
    func showVendorPostWorkshopController() {
        showVendorScreen(VendorPostWorkshopView())
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
        GCD.async(.Main, delay: 1) { [weak self] in
            self?.showLoginScreen()
        }
     }
    
}
