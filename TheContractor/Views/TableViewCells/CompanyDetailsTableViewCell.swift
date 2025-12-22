//
//  CompanyDetailsTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/22/21.
//

import UIKit
import Cosmos

class CompanyDetailsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblRatingCount: UILabel!
    @IBOutlet weak var lblRating: CosmosView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCompany: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureView(company : CompanyViewModel){
        self.lblName.text = company.company_name
        self.lblRating.rating = Double(company.total_rating) ?? 0.0
        self.lblSubtitle.text = company.category_name
        self.lblRatingCount.text = company.review_count
        self.setImageWithUrl(imageView: self.imgCompany, url: company.company_logo)
    }
    
    @IBAction func actionSelectCompany(_ sender: Any) {
    }
    
}
