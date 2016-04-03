//
//  ContentController.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 03-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit
import WebKit

protocol ContentDelegate: class {
    func contentWillClose(menu: ContentViewController)
}

class ContentViewController: UIViewController {
    @IBOutlet weak var webViewContainer: UIView!

    let webView = WKWebView()

    weak var delegate: ContentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.backgroundColor = UIColor.backgroundColor
        webView.scrollView.backgroundColor = UIColor.backgroundColor
        webView.opaque = false
        webViewContainer.addSubview(webView)
        webView.constrainToView(webViewContainer, margin: 10)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        webViewContainer.alpha = 0

        UIView.animateWithDuration(0.3) { 
            self.webViewContainer.alpha = 1.0
        }

        webView.layer.borderColor = UIColor.darkAmberColor.CGColor
        webView.layer.borderWidth = 1
    }

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        delegate?.contentWillClose(self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft,.LandscapeRight]
    }
}
