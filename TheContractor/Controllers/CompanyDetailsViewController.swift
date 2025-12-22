//
//  CompanyDetailsViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/23/21.
//

import UIKit
import Cosmos

class CompanyDetailsViewController: BaseViewController ,TopBarDelegate{

    @IBOutlet weak var lblCompanyDescription: UITextView!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgLogi: UIImageView!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var lblRating: CosmosView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ViewOpeningHour: UIView!
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var viewReviews: UIView!
    @IBOutlet weak var viewOpeningHours: UIView!
    @IBOutlet weak var viewDetail: UIView!
    @IBOutlet weak var tableView: UITableView!
    var companyDetails = CompanyViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblReview.isHidden = true
        self.tableView.setNoDataMessage("No opening hours available")
        self.viewReviews.isHidden = true
        self.viewDetail.isHidden = false
        self.viewOpeningHours.isHidden = true
        self.viewDescription.isHidden = false
        self.ViewOpeningHour.isHidden = true
        configureCompanyDetails()
        

        // Do any additional setup after loading the view.
    }
    
  
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let container = self.mainContainer{
                container.setBackButton(isback: true)
                container.delegate = self
                container.imgLogo.isHidden = true
                container.lblTitle.isHidden = false
                container.lblTitle.text = "Company Details"
            }
        }
        
       
        func actionBack() {
            if let container = self.mainContainer{
                container.setBackButton()
                container.imgLogo.isHidden = false
                container.lblTitle.isHidden = true
                container.lblTitle.text = ""
            }
            self.navigationController?.popViewController(animated: true)
        }
      

    
    func configureCompanyDetails(){
        self.setImageWithUrl(imageView: self.imgLogi, url: companyDetails.company_logo)
        self.lblName.text = companyDetails.company_name
        self.lblRating.rating = Double(companyDetails.total_rating) ?? 0
        self.lblReviewCount.text = companyDetails.review_count
        self.lblSubtitle.text = companyDetails.category_name
        self.lblCompanyDescription.text = companyDetails.company_discription
        self.lblCity.isHidden = true
        self.lblArea.isHidden = true
    }
    @IBAction func actionReviews(_ sender: Any) {
        self.viewReviews.isHidden = false
        self.viewDetail.isHidden = true
        self.viewOpeningHours.isHidden = true
        self.viewDescription.isHidden = false
        self.ViewOpeningHour.isHidden = true
        self.lblReview.isHidden = false
        self.viewDescription.isHidden = true

    }
    
    @IBAction func actionDetails(_ sender: Any) {
        self.viewReviews.isHidden = true
        self.viewDetail.isHidden = false
        self.viewOpeningHours.isHidden = true
        self.viewDescription.isHidden = false
        self.ViewOpeningHour.isHidden = true
        self.lblReview.isHidden = true
    }
    
    @IBAction func actionOpeningHours(_ sender: Any) {
        self.viewReviews.isHidden = true
        self.viewDetail.isHidden = true
        self.viewOpeningHours.isHidden = false
        self.viewDescription.isHidden = true
        self.ViewOpeningHour.isHidden = false
        self.lblReview.isHidden = true
    }
    
}

extension CompanyDetailsViewController : UITableViewDataSource , UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpeningTableViewCell", for: indexPath) as! OpeningTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
