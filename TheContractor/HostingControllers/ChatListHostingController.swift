//
//  ChatListHostingController.swift
//  TheContractor
//
//  Hosting controller for ChatListView
//

import UIKit
import SwiftUI

class ChatListHostingController: UIHostingController<ChatListView> {
    
    init() {
        super.init(rootView: ChatListView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
