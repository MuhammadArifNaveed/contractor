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
        tableView.reloadData()
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
            showComingSoonAlert(in: mainVC, feature: "Inbox")
            
        case "Company Finder":
            mainVC.showSearchCompanyController()
            
        case "Submit Enquiry":
            showComingSoonAlert(in: mainVC, feature: "Submit Enquiry")
            
        case "Enquiries":
            showComingSoonAlert(in: mainVC, feature: "Enquiries")
            
        case "Submit Quotation":
            showComingSoonAlert(in: mainVC, feature: "Submit Quotation")
            
        case "Quotations":
            showComingSoonAlert(in: mainVC, feature: "Quotations")
            
        case "Complaints":
            showComingSoonAlert(in: mainVC, feature: "Complaints")
            
        case "Estimations":
            mainVC.showEsstimationController()
            
        case "24/7 Maintenance":
            showComingSoonAlert(in: mainVC, feature: "24/7 Maintenance")
            
        case "Advertise Company":
            showComingSoonAlert(in: mainVC, feature: "Advertise Company")
            
        case "Available Jobs":
            showComingSoonAlert(in: mainVC, feature: "Available Jobs")
            
        case "My Job Applies":
            showComingSoonAlert(in: mainVC, feature: "My Job Applies")
            
        case "Direct Hiring":
            showComingSoonAlert(in: mainVC, feature: "Direct Hiring")
            
        case "Freelancers":
            mainVC.showFreelancersController()
            
        case "Freelancer Dashboard":
            showComingSoonAlert(in: mainVC, feature: "Freelancer Dashboard")
            
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
            // TODO: Navigate to Inbox (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Inbox")
        }
        else if title == "Vendor Rating" {
            // TODO: Navigate to Vendor Rating (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Vendor Rating")
        }
        else if title == "Enquiries" {
            // TODO: Navigate to Vendor Enquiries (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Enquiries")
        }
        else if title == "Quotations" {
            // TODO: Navigate to Vendor Quotations (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Quotations")
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
            // Temporarily disabled - showFreelanceDashboardController removed
            /*
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            }
            else {
                mainVC.loginUser()
            }
            */
            showComingSoonAlert(in: mainVC, feature: "Freelancer Dashboard")
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

