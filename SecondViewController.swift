//
//  SecondViewController.swift
//  ListenUpPOC
//
//  Created by Allen Casey on 10/17/20.
//  Copyright © 2020 Allen Casey. All rights reserved.
//

struct SearchedArtistData: Codable {
    let artist: SearchedArtist
}

// MARK: - Artist
struct SearchedArtist: Codable {
    let name, mbid: String
    let url: String
    let image: [Image]
    let streamable, ontour: String
    let stats: Stats
    let similar: Similar
    let tags: Tags
    let bio: Bio
}

// MARK: - Bio
struct Bio: Codable {
    let links: Links
    let published, summary, content: String
}

// MARK: - Links
struct Links: Codable {
    let link: Link
}

// MARK: - Link
struct Link: Codable {
    let text, rel: String
    let href: String

    enum CodingKeys: String, CodingKey {
        case text = "#text"
        case rel, href
    }
}

// MARK: - Similar
struct Similar: Codable {
    let artist: [ArtistElement]
}

// MARK: - ArtistElement
struct ArtistElement: Codable {
    let name: String
    let url: String
    let image: [Image]
}

// MARK: - Stats
struct Stats: Codable {
    let listeners, playcount: String
}

// MARK: - Tags
struct Tags: Codable {
    let tag: [Tag]
}

// MARK: - Tag
struct Tag: Codable {
    let name: String
    let url: String
}

import UIKit

class SecondViewController: UIViewController {
    
    var artistName: String?
    var artistBio: String?
    var artistListenerCount: Int?
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="show_artist_info_segue" {
            let seg = segue.destination as! ArtistInfoViewController
            seg.passedArtistName = artistName
            seg.passedArtistBio = artistBio
            seg.passedArtistListenerCount = artistListenerCount
        }
    }

    @IBAction func getArtistInfoButton(_ sender: Any) {
        
        guard searchTextField.text!.count != 0 else {
            
            let alert = UIAlertController(title: "Missing Artist", message: "Please enter an artist", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true)
            
            return
        }
        
        performSegue(withIdentifier: "show_artist_info_segue", sender: self)
    }
    
    func downloadData(url: URL) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if let downloaded_data = data {
                self.decodeData(downloaded_data: downloaded_data)
            } else if let error=error {
                print(error)
            }
        })
        task.resume()
    }
    
    func decodeData(downloaded_data: Data) {
        do {
            let downloaded_info = try JSONDecoder().decode(SearchedArtistData.self, from: downloaded_data)
            artistName = downloaded_info.artist.name
            artistBio = downloaded_info.artist.bio.content
            artistListenerCount = Int(downloaded_info.artist.stats.listeners)!
            
        } catch {
            print("Error in decoding")
        }
    }
    
}

