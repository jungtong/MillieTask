import UIKit
import SnapKit
import WebKit

final class WebViewController: UIViewController {
    init(newsInfo: NewsVO) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen

        let navigationItem = UINavigationItem()
        navigationItem.title = newsInfo.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))

        let navigationBar = UINavigationBar()
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)

        let webView = WKWebView()
        self.view.addSubview(webView)

        if let targetUrl = URL(string: newsInfo.url) {
            webView.load(URLRequest(url: targetUrl))
        }
        else {
            print("url error. \(newsInfo.url)")
        }

        // update UI
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(44)
        }

        webView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func backButtonPressed() {
        self.dismiss(animated: true)
    }
}
