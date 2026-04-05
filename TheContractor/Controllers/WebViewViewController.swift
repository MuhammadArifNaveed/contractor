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

    private let topBarHeight: CGFloat = 56

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCustomTopBar()
        setupWebView()
        configureURLRequest()
    }

    // MARK: - Custom yellow top bar (title + back button)
    private func setupCustomTopBar() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let barHeight = topBarHeight + safeTop
        let barFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: barHeight)

        let topBar = UIView(frame: barFrame)
        topBar.backgroundColor = UIColor(red: 242/255, green: 190/255, blue: 54/255, alpha: 1)
        topBar.autoresizingMask = [.flexibleWidth]
        view.addSubview(topBar)

        // Back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.frame = CGRect(x: 8, y: safeTop, width: 44, height: topBarHeight)
        backButton.addTarget(self, action: #selector(actionBackTapped), for: .touchUpInside)
        topBar.addSubview(backButton)

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = containeTitle
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.frame = CGRect(x: 56, y: safeTop, width: view.bounds.width - 70, height: topBarHeight)
        topBar.addSubview(titleLabel)
    }

    // MARK: - WKWebView below top bar
    private func setupWebView() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let webViewTop = topBarHeight + safeTop
        let webViewFrame = CGRect(x: 0, y: webViewTop,
                                  width: view.bounds.width,
                                  height: view.bounds.height - webViewTop)
        webView = WKWebView(frame: webViewFrame)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }

    func configureURLRequest() {
        startActivity()
        guard let url = URL(string: link) else { return }
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        stopActivity()
    }

    @objc private func actionBackTapped() {
        NotificationCenter.default.post(name: Notification.Name("GoBackToTabBar"), object: nil)
    }

    func actionBack() {
        navigationController?.popViewController(animated: true)
    }
}
