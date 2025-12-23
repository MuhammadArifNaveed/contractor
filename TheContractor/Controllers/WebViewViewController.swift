//
//  WebViewViewController.swift
//  TheContractor
//
//  Created by Rana Faheem on 8/27/21.
//

import UIKit
import WebKit

class WebViewViewController: BaseViewController, WKNavigationDelegate, TopBarDelegate {

    @IBOutlet weak var webView: WKWebView!
    var link = ""
    var isFromSideMenu = false
    var containeTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        configureURLRequest()
    }

    func configureURLRequest() {
        startActivity()
        guard let url = URL(string: link) else { return }
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopActivity()
    }

    func actionBack() {
        navigationController?.popViewController(animated: true)
    }
}
