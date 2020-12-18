//
//  HomeViewController.swift
//  ListenUpPOC
//
//  Created by student on 11/24/20.
//  Copyright © 2020 Allen Casey. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var topArtistTableView: UITableView!
    
    var topArtists = [TArtist]()
    var selectedArtistName = ""
    
    // Array of placeholder images for the top artists
    var albumImageURLs = ["https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png",
                            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // create top artist URL and execute query
        let topArtistsURL = URL(string: "http://ws.audioscrobbler.com/2.0/?method=chart.gettopartists&api_key=9b8f3b4a955d8c582b72e37ef7dae021&format=json&limit=10")
        if topArtistsURL != nil
        {
            downloadData(url: topArtistsURL!)
        }
    }
    
    // Deselect TableView cell upon returning
    override func viewWillAppear(_ animated: Bool)
    {
        if let index = self.topArtistTableView.indexPathForSelectedRow
        {
            self.topArtistTableView.deselectRow(at: index, animated: true)
        }
    }
    
    // reset text field on return to page
    override func viewDidAppear(_ animated: Bool)
   {
       searchTextField.text = ""
       selectedArtistName = ""
   }

    /* MARK: JSON Download & Decode */
    func downloadData(url: URL)
    {
        let task = URLSession.shared.dataTask(with: url, completionHandler:
        {(data, response, error) in
            if let downloaded_data = data
            {
                self.decodeData(downloaded_data: downloaded_data)
                
                let group = DispatchGroup()
                var index = 0
                
                for artist in self.topArtists
                {
                    group.enter()
                    self.downloadAlbumData(artistName: artist.name, index: index)
                    index += 1
                    group.leave()
                }
               
                group.notify(queue: .main)
                {
                    self.topArtistTableView.reloadData()
                }
            }
            else if let error=error
            {
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
            topArtists = downloaded_info.artists.artist
        }
        catch
        {
            print("Error in decoding")
        }
    }
    
    func downloadAlbumData(artistName: String, index: Int)
    {
        
        var name = artistName.replacingOccurrences(of: " ", with: "+")
        name = name.replacingOccurrences(of: "&", with: "and")
        
        let albumUrl = URL(string: "http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=\(name)&api_key=9b8f3b4a955d8c582b72e37ef7dae021&format=json")
        
        let task = URLSession.shared.dataTask(with: albumUrl!, completionHandler:
        {(data, response, error) in
            if let downloaded_data = data
            {
                self.decodeAlbumData(downloaded_data: downloaded_data, index: index)
            }
            else if let error=error
            {
                print(error)
            }
        })
        task.resume()
    }
    
    func decodeAlbumData(downloaded_data: Data, index: Int)
    {
        do
        {
            let downloaded_info = try JSONDecoder().decode(AlbumData.self, from: downloaded_data)
            self.albumImageURLs[index] = downloaded_info.topalbums.album[0].image[3].text
            DispatchQueue.main.async
            {
                self.topArtistTableView.reloadData()
            }
        }
        catch
        {
            print("Error in album decoding")
        }
    }
    
    func downloadData2(url: URL)
    {
        let task = URLSession.shared.dataTask(with: url, completionHandler:
        {(data, response, error) in
            if let downloaded_data = data
            {
                self.decodeData2(downloaded_data: downloaded_data)
            }
            else if let error=error {
                print(error)
            }
        })
        task.resume()
    }

    func decodeData2(downloaded_data: Data)
    {
        do
        {
            let downloaded_info = try JSONDecoder().decode(ArtistData.self, from: downloaded_data)  //ArtistData in Similar Artists controller
            selectedArtistName = downloaded_info.similarartists.attr.artist
            DispatchQueue.main.async
            {
                self.topArtistTableView.reloadData()
            }
        }
        catch
        {
            print("Error in decoding")
            self.selectedArtistName = self.searchTextField.text!
        }
    }
        
    // MARK: - TableView Definition
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Today's Top Artists"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return topArtists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topArtistCell", for: indexPath)
        let cell_lbl = cell.viewWithTag(1) as! UILabel
        let cell_img = cell.viewWithTag(2) as! UIImageView
        cell_lbl.text = topArtists[indexPath.row].name
        let img_url = URL(string: albumImageURLs[indexPath.row + (albumImageURLs.count - 10)])
        URLSession.shared.dataTask(with: img_url!, completionHandler: {(data, response, error) in
            if error != nil
            {
                print(error!)
                return
            }
            DispatchQueue.main.async
            {
                cell_img.image=UIImage(data: data!)
            } }).resume()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedArtistName = topArtists[indexPath.row].name
        self.performSegue(withIdentifier: "homeToInfoSegue", sender: self)
    }
        
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="homeToSimilarArtistSegue"
        {
            let seg = segue.destination as! SimilarArtistTableViewController
            seg.passedArtist = searchTextField.text!
        }
        if segue.identifier == "homeToInfoSegue"
        {
            let seg = segue.destination as! ArtistInfoViewController
            seg.passedArtistName = selectedArtistName
        }
    }
        
    // MARK: - Button Options
    @IBAction func similarArtistsButton(_ sender: Any)
    {
        guard searchTextField.text!.count != 0 else
        {
            // Display alert if artist field left blank
            let alert = UIAlertController(title: "Missing Artist", message: "Please enter an artist", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:
            {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        // go to similar artist table view
        performSegue(withIdentifier: "homeToSimilarArtistSegue", sender: self)
    }
    
    @IBAction func artistInfoButton(_ sender: Any)
    {
        guard searchTextField.text!.count != 0 else
        {
            // Display alert if artist field left blank
            let alert = UIAlertController(title: "Missing Artist", message: "Please enter an artist", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:
            {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        // The following performs an error check on possible typos, effective but not fullproof
        var name = searchTextField.text!
        name = name.replacingOccurrences(of: " ", with: "+")
        name = name.replacingOccurrences(of: "&", with: "and")
        let url = URL(string: "http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=\(name)&api_key=9b8f3b4a955d8c582b72e37ef7dae021&limit=5&format=json")
        if url != nil
        {
            downloadData2(url: url!)
        }
        while selectedArtistName.count == 0 {}  // Waiting for JSON to load
        performSegue(withIdentifier: "homeToInfoSegue", sender: self)
    }
}
