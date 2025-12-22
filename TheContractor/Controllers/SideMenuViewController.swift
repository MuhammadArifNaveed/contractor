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
        else if(indexPath.row > 1 && indexPath.row < 11){
            return 0
        }
        else if(indexPath.row == 19 || indexPath.row == 20){
            return 0
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
     //   mainVC.resetAllBottomViews()
        if(indexPath.row == 1){
//            mainVC.lblHome.setTitleColor(UIColor.init(hexFromString: "FF525C"), for: .normal)
//            mainVC.imgHome.tintColor = UIColor.init(hexFromString: "FF525C")
           mainVC.showHomeController()
        }
        else if(indexPath.row > 10 && indexPath.row < 19){
             let title =  SideMenu.MENULIST[indexPath.row - 1]["title"] as! String
            var link = ""
            if(indexPath.row == 11){

                link = AppLinks.AboutUS
            }
            else if(indexPath.row == 12){
                link = AppLinks.Advertisment
            }
            else if(indexPath.row == 13){
                link = AppLinks.Vendor
            }
            else if(indexPath.row == 14){
                link = AppLinks.Documentation
            }
            else if(indexPath.row == 15){
                link = AppLinks.Privacy
            }
            else if(indexPath.row == 16){
                link = AppLinks.Terms
            }
            else if(indexPath.row == 17){
                link = AppLinks.Guide
            }
            else if(indexPath.row == 18){
                link = AppLinks.ContactUS
            }
            mainVC.showWebController(title: title, link: link)
           
        }
    }
}

