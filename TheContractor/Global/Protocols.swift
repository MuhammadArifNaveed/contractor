//
//  Protocols.swift
//  UgoCab
//
//  Created by Gulfam Khan on 29/10/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import Foundation

//MARK:- TopBarDelegate
protocol TopBarDelegate: class {
    func actionBack()
    func rightButtonAction()
    func rightButtonOptionAction(tag : Int)
    func opneRightMenu()
}

extension TopBarDelegate {
    func rightButtonAction() {}
    func rightButtonOptionAction(tag : Int) {}
    func opneRightMenu() {}
}

