//
//  ProfileViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/27/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}

extension ProfileViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileMenu.MENULIST.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
            cell.selectionStyle = .none
            cell.configureView()
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            cell.selectionStyle = .none
            cell.configureView(side: ProfileMenu.MENULIST[indexPath.row - 1])
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 90
        }
        else if(indexPath.row == 12 && !Global.shared.isLogedIn){
            return 0
        }
        else if(indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
            return 0
        }
        else{
            return 60
            
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0){
            if let container = self.mainContainer{
                container.loginUser()
            }
        }
        else if(indexPath.row > 3 && indexPath.row < 12){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
            vc.containeTitle = ProfileMenu.MENULIST[indexPath.row - 1]["title"] as! String
           
            if(indexPath.row == 4){
                
                vc.link = AppLinks.AboutUS
            }
            else if(indexPath.row == 5){
                vc.link = AppLinks.Advertisment
            }
            else if(indexPath.row == 6){
                vc.link = AppLinks.Vendor
            }
            else if(indexPath.row == 7){
                vc.link = AppLinks.Documentation
            }
            else if(indexPath.row == 8){
                vc.link = AppLinks.Privacy
            }
            else if(indexPath.row == 9){
                vc.link = AppLinks.Terms
            }
            else if(indexPath.row == 10){
                vc.link = AppLinks.Guide
            }
            else if(indexPath.row == 11){
                vc.link = AppLinks.ContactUS
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if(indexPath.row == 12){
            if let container = self.mainContainer{
                container.logoutUser()
            }
        }
        
    }
}


