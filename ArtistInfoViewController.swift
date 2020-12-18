//
//  ArtistInfoViewController.swift
//  ListenUpPOC
//
//  Created by Allen Casey on 10/18/20.
//  Copyright © 2020 Allen Casey. All rights reserved.
//

import UIKit
import WebKit

class ArtistInfoViewController: UIViewController, WKUIDelegate
{
    var passedArtistName: String?
    
    @IBOutlet var webView: WKWebView!
    
    // prepare WebView window
    override func loadView()
    {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // make the artist name query URL-friendly, then build URL string
        passedArtistName = passedArtistName?.replacingOccurrences(of: " ", with: "+")
        passedArtistName = passedArtistName?.replacingOccurrences(of: "&", with: "and")
        var urlString = "https://www.last.fm/music/\(String(describing: passedArtistName!))/+wiki"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        // load specified URL in WebView
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
