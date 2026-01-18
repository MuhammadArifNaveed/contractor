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
    
    func configureView() {
        // Treat both flags and actual stored user object as the source of truth.
        let isLoggedInUser = Global.shared.isLogedIn && Global.shared.user != nil

        viewLogin.isHidden = isLoggedInUser
        viewProfile.isHidden = !isLoggedInUser

        guard isLoggedInUser, let user = Global.shared.user else {
            // No user available – show empty / default state and avoid crashes.
            lblUserName.text = ""
            lblPhone.text = ""
            return
        }

        // Safely build full name from available components.
        let firstName = user.name
        let lastName = user.surname
        let fullName: String
        if !firstName.isEmpty && !lastName.isEmpty {
            fullName = "\(firstName) \(lastName)"
        } else if !firstName.isEmpty {
            fullName = firstName
        } else if !lastName.isEmpty {
            fullName = lastName
        } else {
            fullName = ""
        }

        lblUserName.text = fullName
        lblPhone.text = user.phone
    }

}
