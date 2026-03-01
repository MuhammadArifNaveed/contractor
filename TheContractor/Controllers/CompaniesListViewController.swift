//
//  CompaniesListViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/22/21.
//

import UIKit

class CompaniesListViewController: BaseViewController ,TopBarDelegate{
   
    

    @IBOutlet weak var tableView: UITableView!
    var companyList = CompanyListViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let container = self.mainContainer{
            container.setBackButton(isback: true)
            container.delegate = self
            container.imgLogo?.isHidden = true
            container.lblTitle?.isHidden = false
            container.lblTitle?.text = "Company List"
        }
    }
    
   
    func actionBack() {
        if let container = self.mainContainer{
            container.setBackButton()
            container.imgLogo?.isHidden = false
            container.lblTitle?.isHidden = true
            container.lblTitle?.text = ""
        }
        self.navigationController?.popViewController(animated: true)
    }

}
extension CompaniesListViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companyList.companyList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyHeaderTableViewCell") as! CompanyHeaderTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyDetailsTableViewCell", for: indexPath) as! CompanyDetailsTableViewCell
        cell.configureView(company: self.companyList.companyList[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CompanyDetailsViewController") as! CompanyDetailsViewController
        vc.companyDetails = self.companyList.companyList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
