//
//  ProfileTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/27/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewLogin: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureView(){
        if(Global.shared.isLogedIn){
            self.viewLogin.isHidden = true
            self.viewProfile.isHidden = false
            self.lblUserName.text = Global.shared.user.name + " " + Global.shared.user.name
            self.lblPhone.text = Global.shared.user.phone
        }
        else{
            self.viewLogin.isHidden = false
            self.viewProfile.isHidden = true
            
        }
    }

}
