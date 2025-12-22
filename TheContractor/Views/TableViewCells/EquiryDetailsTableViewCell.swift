//
//  EquiryDetailsTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/23/21.
//

import UIKit

class EquiryDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblSecondDate: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgEnquiry: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
