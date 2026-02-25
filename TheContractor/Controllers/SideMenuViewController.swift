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
            // All menu items are now visible
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let drawer = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(.closed, animated: true)
        let mainVC = (drawer.mainViewController as! UINavigationController).topViewController as! MainContainerViewController
        
        if indexPath.row == 0 {
            return
        }

        let title = currentMenuList[indexPath.row - 1]["title"] as? String ?? ""

        // Vendor menu handlers
        if Global.shared.isVendor {
            handleVendorMenuItem(title: title, mainVC: mainVC)
            return
        }
        
        // User menu handlers
        if title == "Home" {
            mainVC.showHomeController()
        }
        else if title == "Company Finder" {
            mainVC.showSearchController()
        }
        else if title == "Submit Enquiry" {
            // TODO: Navigate to Submit Enquiry screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Submit Enquiry")
        }
        else if title == "Enquiries" {
            // TODO: Navigate to Enquiries list screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Enquiries")
        }
        else if title == "Submit Quotations" {
            // TODO: Navigate to Submit Quotations screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Submit Quotations")
        }
        else if title == "Quotations" {
            // TODO: Navigate to Quotations list screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Quotations")
        }
        else if title == "Complaints" {
            // TODO: Navigate to Complaints screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "Complaints")
        }
        else if title == "Estimations" {
            mainVC.showEsstimationController()
        }
        else if title == "24/7 Companies" {
            // TODO: Navigate to 24/7 Companies screen (will be implemented in separate feature)
            showComingSoonAlert(in: mainVC, feature: "24/7 Companies")
        }
        else if title == "Freelancers" {
            mainVC.showFreelancersController()
        }
        else if title == "Freelancer Dashboard" {
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            }
            else {
                mainVC.loginUser()
            }
        }
        else if title == "Workshop" {
            mainVC.showWorkshopController()
        }
        else if title == "Rate Us" {
            rateApp(in: mainVC)
        }
        else if title == "Share" {
            shareApp(in: mainVC)
        }
        else {
            var link = ""
            if title == "About Us" {
                link = AppLinks.AboutUS
            }
            else if title == "Advertisement" {
                link = AppLinks.Advertisment
            }
            else if title == "Become a Vendor" {
                link = AppLinks.Vendor
            }
            else if title == "Documentations" {
                link = AppLinks.Documentation
            }
            else if title == "Privacy Polices" {
                link = AppLinks.Privacy
            }
            else if title == "Terms & Conditions" {
                link = AppLinks.Terms
            }
            else if title == "Guide" {
                link = AppLinks.Guide
            }
            else if title == "Contact Us" {
                link = AppLinks.ContactUS
            }

            if !link.isEmpty {
                mainVC.showWebController(title: title, link: link)
            }
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
            if Global.shared.isLogedIn {
                mainVC.showFreelanceDashboardController()
            }
            else {
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
            mainVC.logoutVendor()
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

