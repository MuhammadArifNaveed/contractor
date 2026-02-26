//  WebContentView.swift
import SwiftUI
import WebKit
struct WebContentView: View {
    let url: String
    let title: String
    var body: some View {
        WebView(urlString: url)
            .navigationTitle(title)
    }
}
struct WebView: UIViewRepresentable {
    let urlString: String
    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) { webView.load(URLRequest(url: url)) }
    }
}
