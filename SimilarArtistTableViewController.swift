//
//  SimilarArtistTableViewController.swift
//  ListenUpPOC
//
//  Created by Allen Casey on 10/18/20.
//  Copyright © 2020 Allen Casey. All rights reserved.


/* MARK: JSON Structs */
struct TopArtists: Codable
{
    let artists: TArtists
}

struct TArtists: Codable
{
    let artist: [TArtist]
    let attr: TAttr

    enum CodingKeys: String, CodingKey
    {
        case artist
        case attr = "@attr"
    }
}

struct TArtist: Codable
{
    let name, playcount, listeners, mbid: String
    let url: String
    let streamable: String
    let image: [TImage]
}

struct TImage: Codable
{
    let text: String
    let size: TSize

    enum CodingKeys: String, CodingKey
    {
        case text = "#text"
        case size
    }
}

enum TSize: String, Codable
{
    case extralarge = "extralarge"
    case large = "large"
    case medium = "medium"
    case mega = "mega"
    case small = "small"
}

struct TAttr: Codable
{
    let page, perPage, totalPages, total: String
}

struct ArtistData: Codable
{
    let similarartists: Similarartists
}

struct AlbumData: Codable {
    let topalbums: Topalbums
}

struct Topalbums: Codable {
    let album: [Album]
    let attr: Attr

    enum CodingKeys: String, CodingKey {
        case album
        case attr = "@attr"
    }
}

struct Album: Codable {
    let name: String
    let playcount: Int
    let mbid: String?
    let url: String
    let artist: ArtistClass
    let image: [Image]
}

struct ArtistClass: Codable {
    let name: String
    let mbid: String?
    let url: String
}

struct Similarartists: Codable
{
    let artist: [Artist]
    let attr: Attr

    enum CodingKeys: String, CodingKey
    {
        case artist
        case attr = "@attr"
    }
}

struct Artist: Codable
{
    let name, mbid, match: String?
    let url: String
    let image: [Image]
    let streamable: String
}

struct Image: Codable
{
    let text: String
    let size: String

    enum CodingKeys: String, CodingKey
    {
        case text = "#text"
        case size
    }
}

struct Attr: Codable
{
    let artist: String
}

import UIKit

class SimilarArtistTableViewController: UITableViewController
{
    
    var passedArtist: String?           // artist name received from HomeViewController
    var similarArtists = [Artist]()     // array of similar artists for JSON decoding
    var selectedArtistName: String?     // name of artist selected by user from TableView
    
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
        self.title = "Artists Similar To \(passedArtist!)"
        
        // make the artist name query URL-friendly
        passedArtist = passedArtist?.replacingOccurrences(of: " ", with: "+")
        passedArtist = passedArtist?.replacingOccurrences(of: "&", with: "and")
        
        // build URL and make query
        let url = URL(string: "http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=\(passedArtist!)&api_key=9b8f3b4a955d8c582b72e37ef7dae021&limit=10&format=json")
        
        if url != nil
        {
            downloadData(url: url!)
        }
    }
    
    // MARK: JSON Download & Decode
    func downloadData(url: URL)
    {
        let task = URLSession.shared.dataTask(with: url, completionHandler:
        {(data, response, error) in
            if let downloaded_data = data
            {
                self.decodeData(downloaded_data: downloaded_data)
                
                let group = DispatchGroup()
                
                // get album imagery for each similar artist
                var index = 0
                for artist in self.similarArtists {
                    group.enter()
                    self.downloadAlbumData(artistName: artist.name!, index: index)
                    index += 1
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    self.tableView.reloadData()
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
            let downloaded_info = try JSONDecoder().decode(ArtistData.self, from: downloaded_data)
            similarArtists = downloaded_info.similarartists.artist
        }
        catch
        {
            print("Error in decoding")
        }
    }
    
    func downloadAlbumData(artistName: String, index: Int)
    {
        // make string for query more URL-friendly
        var name = artistName.replacingOccurrences(of: " ", with: "+")
        name = name.replacingOccurrences(of: "&", with: "and")
        var urlString = "http://ws.audioscrobbler.com/2.0/?method=artist.gettopalbums&artist=\(name)&api_key=9b8f3b4a955d8c582b72e37ef7dae021&format=json"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let albumUrl = URL(string: urlString)
        
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
            
            var albumIndex = 0
            var albumName = ""
            
            while albumName == "" {
                albumName = downloaded_info.topalbums.album[albumIndex].image[3].text
                albumIndex += 1
            }
            
            self.albumImageURLs[index] = albumName
            
            if (index == albumImageURLs.count - 1) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        catch
        {
            print("Error in decoding")
        }
    }
    
    /* MARK: TableView Configuration */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if similarArtists.count == 0
        {
            return "Could not find the artist you entered."
        }
        return ""
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return similarArtists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artist_info_cell", for: indexPath)

        let cell_lbl = cell.viewWithTag(1) as! UILabel
        let cell_img = cell.viewWithTag(2) as! UIImageView
        cell_lbl.text = similarArtists[indexPath.row].name
        
        if similarArtists.count == 0
        {
            cell_lbl.text = "Could not find artist"
        }

        let img_url = URL(string: albumImageURLs[indexPath.row + (albumImageURLs.count - 10)])

        // load artist image to cell
        URLSession.shared.dataTask(with: img_url!, completionHandler:
        {(data, response, error) in

            if error != nil
            {
                print(error!)
                return
            }

            DispatchQueue.main.async
            {
                cell_img.image=UIImage(data: data!)
            }

        }).resume()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    /* MARK: Segue Stuff */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier=="similar_artist_info_segue"
        {
            let seg = segue.destination as! ArtistInfoViewController
            seg.passedArtistName = selectedArtistName
        }
    }
    
    // if user clicks on artist cell, go to artist info page and send that artist's name
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedArtistName = similarArtists[indexPath.row].name
        self.performSegue(withIdentifier: "similar_artist_info_segue", sender: self)
    }
}
