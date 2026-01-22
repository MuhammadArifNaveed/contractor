//
//  SideMenuViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/24/21.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
extension SideMenuViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SideMenu.MENULIST.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderTableViewCell") as! SideMenuHeaderTableViewCell
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            cell.configureView(side: SideMenu.MENULIST[indexPath.row - 1])
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 120
        }
        else{
            let title = SideMenu.MENULIST[indexPath.row - 1]["title"] as? String ?? ""
            let hiddenItems: Set<String> = [
                "Company Finder",
                "Submit Enquiry",
                "Enquiries",
                "Submit Quotations",
                "Quotations",
                "Complaints",
                "Estimations",
                "24/7 Companies",
                "Rate Us",
                "Share"
            ]
            return hiddenItems.contains(title) ? 0 : 60
            
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let drawer = self.navigationController?.parent as! KYDrawerController
        drawer.setDrawerState(.closed, animated: true)
        let mainVC = (drawer.mainViewController as! UINavigationController).topViewController as! MainContainerViewController
     //   mainVC.resetAllBottomViews()
        if indexPath.row == 0 {
            return
        }

        let title = SideMenu.MENULIST[indexPath.row - 1]["title"] as? String ?? ""

        if title == "Home" {
            mainVC.showHomeController()
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
}

