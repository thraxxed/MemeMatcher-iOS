//
//  SecondViewController.swift
//  MemeMatcher
//
//  Created by Seth Little on 2/17/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var memeImage: UIImageView!
    
    
    var memes = [Meme]()
    
    var memeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        getMemes(for: 1) { (result) in
            switch result {
            case .success(let memes):
                self.memes = memes
                print(self.memes)
                
                let url = URL(string: self.memes[self.memeIndex].image_url)
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.memeImage.image = UIImage(data: data!)
                    }
                }

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
                        // We would use Meme.self for JSON representing a single Meme
                        // object, and [Meme].self for JSON representing an array of
                        // Meme objects
                        let memes = try decoder.decode([Meme].self, from: jsonData)
                        completion?(.success(memes))
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
    
    func loadMemeImage() {
        memeIndex += 1
        if (memeIndex >= self.memes.count) {
            return
        }
        let url = URL(string: self.memes[self.memeIndex].image_url)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.memeImage.image = UIImage(data: data!)
            }
        }
    }
    
    //Mark: Actions
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        print("we swiped right")
        loadMemeImage()
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        print("we swiped left")
        loadMemeImage()
    }
    
    
    @IBAction func heartMeme(_ sender: UIButton) {
        print("we clicked heart")
        loadMemeImage()
    }
    
    @IBAction func dislikeMeme(_ sender: UIButton) {
        print("we clicked x")
        loadMemeImage()
    }
    
    
    
    
    // Functions to download images after API call
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

