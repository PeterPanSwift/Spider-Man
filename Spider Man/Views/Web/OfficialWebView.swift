import SwiftUI
import WebKit

struct OfficialWebView: View {
    private let officialURL = URL(
        string: "https://www.sonypictures.com/movies/spidermanbrandnewday"
    )!

    var body: some View {
        WebView(url: officialURL)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Sony Pictures")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct TrailerWebView: View {
    let title: String
    let url: URL

    var body: some View {
        WebView(url: url)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }
}
