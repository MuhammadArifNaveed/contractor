//
//  WebViewViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/27/21.
//

import UIKit
import WebKit

class WebViewViewController: BaseViewController,WKNavigationDelegate ,TopBarDelegate{
 
    

    @IBOutlet weak var webView: WKWebView!
    var link = ""
    var isFromSideMenu = false
    var containeTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureURLRequest()
        webView.navigationDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let container = self.mainContainer{
            if(!self.isFromSideMenu){
              container.btnBack.setImage(UIImage(named: "Back arrow 3x-2"), for: .normal)
              container.delegate = self
            }
            container.lblTitle.isHidden = false
            container.imgLogo.isHidden = true
            container.lblTitle.text = containeTitle
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let container = self.mainContainer{
            container.btnBack.setImage(UIImage(named: "menu"), for: .normal)
            container.lblTitle.isHidden = true
            container.imgLogo.isHidden = false
            container.lblTitle.text = containeTitle
            
        }
    }
    
    func actionBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //after webView completly load hiding loader.
        self.stopActivity()
    }
    
    func configureURLRequest(){
        //showing the loader
        self.startActivity()
        if let URL = URL(string: self.link){
            let urlRequest = URLRequest(url: URL)
            self.webView.load(urlRequest)
        }
    }
    
}
