//
//  QuotationDetailsTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/23/21.
//

import UIKit

class QuotationDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblSubCategory: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
