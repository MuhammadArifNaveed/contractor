//
//  SideMenuViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/24/21.
//

import UIKit
import SwiftUI

class SideMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Defer reload to avoid layout warning
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshMenu),
            name: NSNotification.Name("RefreshSideMenu"),
            object: nil
        )
    }
    
    @objc private func refreshMenu() {
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SideMenuViewController : UITableViewDelegate , UITableViewDataSource{

    private var activeMenuList: [[String: String]] {
        if Global.shared.isVendor { return VendorMenu.MENULIST }
        return Global.shared.isLogedIn ? SideMenu.USER_MENU : SideMenu.GUEST_MENU
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeMenuList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderTableViewCell") as! SideMenuHeaderTableViewCell
            let userName = Global.shared.user?.name ?? ""
            cell.configure(isLoggedIn: Global.shared.isLogedIn, userName: userName)

            cell.onLoginTap = { [weak self] in
                self?.closeThenNavigate { $0.loginUser() }
            }
            cell.onLoginAsCompanyTap = { [weak self] in
                self?.closeThenNavigate { $0.showCompanyLoginController() }
            }
            cell.onViewProfileTap = { [weak self] in
                // Android's nav header sends companies to VendorProfile and users to the consumer
                // profile; the header is shared between both account types.
                self?.closeThenNavigate { mainVC in
                    if Global.shared.isVendor {
                        mainVC.showVendorScreen(VendorProfileView())
                    } else {
                        mainVC.showProfileController()
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            cell.configureView(side: activeMenuList[indexPath.row - 1])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 130 : 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 { return }
        
        let title = activeMenuList[indexPath.row - 1]["title"] ?? ""

        closeThenNavigate { mainVC in
            if Global.shared.isVendor {
                self.handleVendorMenuItem(title: title, mainVC: mainVC)
            } else {
                self.handleUserMenuItem(title: title, mainVC: mainVC)
            }
        }
    }

    // MARK: - Close drawer then execute navigation
    private func closeThenNavigate(_ action: @escaping (MainContainerViewController) -> Void) {
        guard let drawer = self.navigationController?.parent as? KYDrawerController,
              let mainVC = (drawer.mainViewController as? UINavigationController)?.topViewController as? MainContainerViewController
        else { return }
        drawer.setDrawerState(.closed, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            action(mainVC)
        }
    }

    // MARK: - User menu handler
    private func handleUserMenuItem(title: String, mainVC: MainContainerViewController) {
        if title != "Home" && title != "Logout" && title != "Rate Us" && title != "Share" {
            mainVC.hideForSideMenu()
        }
        switch title {
        case "Home":
            mainVC.showHomeController()

        case "Inbox":
            mainVC.showChatListController()

        case "Company Finder":
            mainVC.showSearchCompanyController()

        case "Submit Enquiry":
            mainVC.showCartController()

        case "Enquiries":
            mainVC.showEnquiriesController()

        case "Submit Quotation":
            mainVC.showSubmitQuotationController()

        case "Quotations":
            mainVC.showQuotationsController()

        case "Complaints":
            mainVC.showComplaintsController()

        case "Estimations":
            // Android's drawer opens the request list, not the calculator (the calculator is the tab).
            mainVC.showEstimationRequestsController()

        case "24/7 Maintenance":
            mainVC.show24x7MaintenanceController()

        case "Advertise Company":
            mainVC.showAdvertiseCompanyController()

        case "Available Jobs":
            mainVC.showAvailableJobsController()

        case "My Job Applies":
            mainVC.showMyJobApplicationsController()

        case "Direct Hiring":
            mainVC.showDirectHiringController()

        case "Freelancers":
            mainVC.showFreelancersController()

        case "Freelancer Dashboard":
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            } else {
                mainVC.loginUser()
            }

        // Android's drawer opens the ad list here (`WorkShopAds` with type=user); the Workshop tab is
        // where an ad gets posted. Both used to open the post form.
        case "My Workshop Ads", "Workshop Ad":
            mainVC.showConsumerWorkshopAdsController()

        // Android shows both of these to guests as well as signed-in users.
        case "Select Language":
            mainVC.showVendorScreen(LanguageSelectionView())

        case "Documentation", "Documentations":
            mainVC.showWebController(title: "Documentation", link: AppLinks.Documentation)

        case "About Us":
            mainVC.showWebController(title: "About Us", link: AppLinks.AboutUS)

        case "Advertisement":
            mainVC.showWebController(title: "Advertisement", link: AppLinks.Advertisment)

        case "Register your Company", "Become a Vendor":
            mainVC.showWebController(title: "Register your Company", link: AppLinks.Vendor)

        case "Privacy Policy", "Privacy Polices":
            mainVC.showWebController(title: "Privacy Policy", link: AppLinks.Privacy)

        case "Terms & Conditions":
            mainVC.showWebController(title: "Terms & Conditions", link: AppLinks.Terms)

        case "Guide":
            mainVC.showWebController(title: "Guide", link: AppLinks.Guide)

        case "Contact Us":
            mainVC.showWebController(title: "Contact Us", link: AppLinks.ContactUS)

        case "Rate Us":
            rateApp(in: mainVC)

        case "Share":
            shareApp(in: mainVC)

        case "Logout":
            mainVC.logoutUser()

        default:
            break
        }
    }

    // MARK: - Vendor menu handler
    private func handleVendorMenuItem(title: String, mainVC: MainContainerViewController) {
        if title != "Home" && title != "Vendor Logout" {
            mainVC.hideForSideMenu()
        }
        switch title {
        case "Home":
            mainVC.showVendorHome()
        case "Profile":
            mainVC.showVendorScreen(VendorProfileView())
        case "Inbox":
            mainVC.showVendorInboxComingSoon()
        case "Rating":
            mainVC.showVendorRatingController()
        case "Enquiries":
            mainVC.showVendorEnquiriesController()
        case "Quotations":
            mainVC.showVendorQuotationsController()
        case "Post Workshop":
            mainVC.showVendorPostWorkshopController()
        case "My Workshops":
            mainVC.showVendorMyWorkshopsController()
        case "All Workshops":
            mainVC.showVendorAllWorkshopsController()
        case "Interested Workshops":
            mainVC.showVendorInterestedWorkshopsController()
        case "Jobs Portal":
            mainVC.showVendorJobsController()
        case "Available Applicant":
            mainVC.showVendorAvailableApplicantsController()
        // Android's "Freelancers" reuses the consumer freelancer list with from=vendor;
        // "Freelancer Dashboard" is the vendor-only counts grid.
        case "Freelancers":
            mainVC.showVendorHireFreelancerController()
        case "Freelancer Dashboard":
            mainVC.showVendorFreelancerDashboardController()
        case "Memberships":
            mainVC.showVendorMembershipsController()
        case "My Membership":
            mainVC.showVendorMyMembershipController()
        case "Vendor Logout":
            mainVC.logoutUser()
        default:
            break
        }
    }
    
    private func rateApp(in viewController: UIViewController) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id YOUR_APP_ID") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func shareApp(in viewController: UIViewController) {
        let appURL = URL(string: "https://apps.apple.com/app/id YOUR_APP_ID")!
        let shareText = "Check out The Contractor app!"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText, appURL],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
}


