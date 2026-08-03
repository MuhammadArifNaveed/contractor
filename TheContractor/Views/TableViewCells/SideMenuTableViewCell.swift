//
//  SideMenuTableViewCell.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/24/21.
//

import UIKit

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var imgMenu: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureView(side: [String : String]){
        self.lblMenu.text = side["title"]

        // Prefer the SF Symbol. The asset catalogue has no distinct art for most menu entries —
        // eight vendor rows all pointed at "become-a-vendor" and five consumer rows at
        // "advertisement" — and symbols stay crisp at any size, tint with the row, and adapt to
        // dark mode. The bundled asset stays as a fallback for any row without a symbol.
        if let symbol = side["symbol"],
           let image = UIImage(systemName: symbol,
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)) {
            self.imgMenu.image = image
            self.imgMenu.tintColor = UIColor(hexFromString: "1A1400")
        } else if let asset = side["image"] {
            self.imgMenu.image = UIImage(named: asset)
            self.imgMenu.tintColor = nil
        }
        self.imgMenu.contentMode = .scaleAspectFit
    }
    
    

}
