//
//  UITableView+Extension.swift
//  OrderAteDelivery
//
//  Created by Gulfam Khan on 18/10/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import UIKit


extension UITableView {
    func setNoDataMessage(_ message:String = LocalStrings.NoDataFound) {
        let view = NoDataView.initializeFromNib()
        view.messageLabel.text = message
        self.backgroundView = view
    }
    
    func removeBackground () {
        self.backgroundView = nil
    }
}

extension UICollectionView {
    func setNoDataMessage(_ message:String = LocalStrings.NoDataFound) {
        let view = NoDataView.initializeFromNib()
        view.messageLabel.text = message
        self.backgroundView = view
    }
    
    func removeBackground () {
        self.backgroundView = nil
    }
}
