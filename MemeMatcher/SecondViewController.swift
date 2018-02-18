//
//  SecondViewController.swift
//  MemeMatcher
//
//  Created by Seth Little on 2/17/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var memeImage: UIImageView!
    
    
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getMemes(for: 1) { (result) in
            switch result {
            case .success(let memes):
                self.memes = memes
                print(self.memes)
                let url = URL(string: self.memes[0].image_url)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                self.memeImage.image = UIImage(data: data!)

            case .failure(let error):
                print(error )
                fatalError("error: \(error.localizedDescription)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    struct Meme: Codable {
        let id: Int
        let image_url: String
    }
    
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func getMemes(for id: Int, completion: ((Result<[Meme]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/memes"
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    // Now we have jsonData, Data representation of the JSON returned to us
                    // from our URLRequest...
                    
                    // Create an instance of JSONDecoder to decode the JSON data to our
                    // Codable struct
                    let decoder = JSONDecoder()
                    
                    do {
                        // We would use Post.self for JSON representing a single Post
                        // object, and [Post].self for JSON representing an array of
                        // Post objects
                        let posts = try decoder.decode([Meme].self, from: jsonData)
                        completion?(.success(posts))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
//
//    func getDocumentsURL() -> URL {
//        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            return url
//        } else {
//            fatalError("Could not retrieve documents directory")
//        }
//    }
//
//    func savePostsToDisk(memes: [Meme]) {
//        // 1. Create a URL for documents-directory/posts.json
//        let url = getDocumentsURL().appendingPathComponent("memes.json")
//        // 2. Endcode our [Post] data to JSON Data
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(memes)
//            // 3. Write this data to the url specified in step 1
//            try data.write(to: url, options: [])
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
//
//    func getPostsFromDisk() -> [Meme] {
//        // 1. Create a url for documents-directory/posts.json
//        let url = getDocumentsURL().appendingPathComponent("memes.json")
//        let decoder = JSONDecoder()
//        do {
//            // 2. Retrieve the data on the file in this path (if there is any)
//            let data = try Data(contentsOf: url, options: [])
//            // 3. Decode an array of Posts from this Data
//            let memes = try decoder.decode([Meme].self, from: data)
//            return memes
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
    
    
    //Mark: Actions
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.memeImage.image = UIImage(data: data)
            }
        }
    }
}

