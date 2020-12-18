//
//  RandomArtistViewController.swift
//  ListenUpPOC
//
//  Created by student on 11/24/20.
//  Copyright © 2020 Allen Casey. All rights reserved.
//

import UIKit
import WebKit

class RandomArtistViewController: UIViewController, WKUIDelegate
{
    @IBOutlet var webView: WKWebView!
    
    var randomArtists = [TArtist]()
    var selectedArtistName = ""
    
    override func loadView()
    {
        // prepare WebView window
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    // Refresh page when refresh button pressed in Nav Bar
    @IBAction func refreshView(_ sender: Any) {
        viewDidAppear(true)
    }
    
    // Generate random artist & load to WebView
    override func viewDidAppear(_ animated: Bool)
    {
        var myURL: URL?
        
        repeat
        {
            // build URL to query for a random "page" of artists in the database
            let url = URL(string: "http://ws.audioscrobbler.com/2.0/?method=chart.gettopartists&api_key=9b8f3b4a955d8c582b72e37ef7dae021&format=json&limit=10&page=\(Int.random(in: 1...999))")
            
            // load page query to the randomArtist array
            if url != nil
            {
                downloadData(url: url!)
            }
            
            // Waiting for the JSON to load
            while randomArtists.count == 0 {}
            
            // pick a random entry in the random artist array
            selectedArtistName = randomArtists[Int.random(in: 0...(randomArtists.count - 1))].name
            
            // make the artist name query URL-friendly, then build URL
            selectedArtistName = selectedArtistName.replacingOccurrences(of: " ", with: "+")
            selectedArtistName = selectedArtistName.replacingOccurrences(of: "&", with: "and")
            myURL = URL(string:"https://www.last.fm/music/\(String(describing: selectedArtistName))/+wiki")
            
        } while (myURL == nil)
        
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func downloadData(url: URL)
    {
        let task = URLSession.shared.dataTask(with: url, completionHandler:
        {(data, response, error) in
            if let downloaded_data = data
            {
                self.decodeData(downloaded_data: downloaded_data)
            } else if let error=error {
                print(error)
            }
        })
        task.resume()
    }
    
    func decodeData(downloaded_data: Data)
    {
        do
        {
            let downloaded_info = try JSONDecoder().decode(TopArtists.self, from: downloaded_data)
            randomArtists = downloaded_info.artists.artist
        }
        catch
        {
            print("Error in decoding")
        }
    }
}
