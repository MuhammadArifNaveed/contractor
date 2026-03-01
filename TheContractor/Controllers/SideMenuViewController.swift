//
//  SideMenuViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/24/21.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var currentMenuList: [[String: String]] {
        return Global.shared.isVendor ? VendorMenu.MENULIST : SideMenu.MENULIST
    }
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMenuList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderTableViewCell") as! SideMenuHeaderTableViewCell
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            cell.configureView(side: currentMenuList[indexPath.row - 1])
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 120
        }
        else{
            return 60
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let drawer = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(.closed, animated: true)
        let mainVC = (drawer.mainViewController as! UINavigationController).topViewController as! MainContainerViewController
        
        // Skip header row
        if indexPath.row == 0 { return }
        
        let menuItem = currentMenuList[indexPath.row - 1]
        let title = menuItem["title"] ?? ""
        
        // Handle different menu types
        if Global.shared.isVendor {
            handleVendorMenuItem(title: title, mainVC: mainVC)
        } else {
            handleUserMenuItem(title: title, mainVC: mainVC, indexPath: indexPath)
        }
    }
    
    private func handleUserMenuItem(title: String, mainVC: MainContainerViewController, indexPath: IndexPath) {
        switch title {
        case "Select Language":
            showComingSoonAlert(in: mainVC, feature: "Language Selection")
            
        case "Home":
            mainVC.showHomeController()
            
        case "Inbox":
            mainVC.showChatListController()
            
        case "Company Finder":
            mainVC.showSearchCompanyController()
            
        case "Submit Enquiry":
            mainVC.showCartController()
            
        case "Enquiries":
            if Global.shared.isLogedIn {
                mainVC.showEnquiriesController()
            } else {
                mainVC.loginUser()
            }
            
        case "Submit Quotation":
            if Global.shared.isLogedIn {
                mainVC.showSubmitQuotationController()
            } else {
                mainVC.loginUser()
            }
            
        case "Quotations":
            if Global.shared.isLogedIn {
                mainVC.showQuotationsController()
            } else {
                mainVC.loginUser()
            }
            
        case "Complaints":
            if Global.shared.isLogedIn {
                mainVC.showComplaintsController()
            } else {
                mainVC.loginUser()
            }
            
        case "Estimations":
            mainVC.showEsstimationController()
            
        case "24/7 Maintenance":
            mainVC.show24x7MaintenanceController()
            
        case "Advertise Company":
            mainVC.showAdvertiseCompanyController()
            
        case "Available Jobs":
            mainVC.showAvailableJobsController()
            
        case "My Job Applies":
            if Global.shared.isLogedIn {
                mainVC.showMyJobApplicationsController()
            } else {
                mainVC.loginUser()
            }
            
        case "Direct Hiring":
            if Global.shared.isLogedIn {
                mainVC.showDirectHiringController()
            } else {
                mainVC.loginUser()
            }
            
        case "Freelancers":
            mainVC.showFreelancersController()
            
        case "Freelancer Dashboard":
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            } else {
                mainVC.loginUser()
            }
            
        case "Workshop Ad":
            mainVC.showWorkshopController()
            
        case "About Us":
            mainVC.showWebController(title: "About Us", link: AppLinks.AboutUS)
            
        case "Advertisement":
            mainVC.showWebController(title: "Advertisement", link: AppLinks.Advertisment)
            
        case "Become a Vendor":
            mainVC.showWebController(title: "Become a Vendor", link: AppLinks.Vendor)
            
        case "Privacy Policy":
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
            if Global.shared.isLogedIn {
                mainVC.logoutUser()
            } else {
                mainVC.loginUser()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleVendorMenuItem(title: String, mainVC: MainContainerViewController) {
        if title == "Home" {
            mainVC.showHomeController()
        }
        else if title == "Inbox" {
            mainVC.showChatListController()
        }
        else if title == "Vendor Rating" {
            // TODO: Navigate to Vendor Rating (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Vendor Rating")
        }
        else if title == "Enquiries" {
            mainVC.showEnquiriesController()
        }
        else if title == "Quotations" {
            mainVC.showQuotationsController()
        }
        else if title == "Post Workshop" {
            // TODO: Navigate to Post Workshop (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Post Workshop")
        }
        else if title == "My Workshops" {
            // TODO: Navigate to My Workshops (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "My Workshops")
        }
        else if title == "All Workshops" {
            mainVC.showWorkshopController()
        }
        else if title == "Interested Workshops" {
            // TODO: Navigate to Interested Workshops (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Interested Workshops")
        }
        else if title == "Jobs Portal" {
            // TODO: Navigate to Jobs Portal (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Jobs Portal")
        }
        else if title == "Available Applicant" {
            // TODO: Navigate to Available Applicant (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Available Applicant")
        }
        else if title == "Freelancers" {
            mainVC.showFreelancersController()
        }
        else if title == "Freelancer Dashboard" {
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            } else {
                mainVC.loginUser()
            }
        }
        else if title == "Memberships" {
            // TODO: Navigate to Memberships (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Memberships")
        }
        else if title == "My Membership" {
            // TODO: Navigate to My Membership (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "My Membership")
        }
        else if title == "Vendor Logout" {
            // Temporarily disabled - logoutVendor removed
            // mainVC.logoutVendor()
            showComingSoonAlert(in: mainVC, feature: "Vendor Logout")
        }
    }
    
    private func showComingSoonAlert(in viewController: UIViewController, feature: String) {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "\(feature) will be available in an upcoming update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
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

