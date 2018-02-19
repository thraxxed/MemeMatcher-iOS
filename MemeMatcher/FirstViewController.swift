//
//  FirstViewController.swift
//  MemeMatcher
//
//  Created by Seth Little on 2/17/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit
import CoreLocation

class User {
    var id: Int
    var username: String
    var picture_url: String
    init(id: Int, username: String, picture_url: String) {
        self.id = id
        self.username = username
        self.picture_url = picture_url
    }
}

var longitude: Double = -1
var latitude: Double = -1

let nullUser: User = User(id: -1, username: "NULL_USER", picture_url: "")
var currentUser: User = nullUser

class FirstViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: Properties
    
    @IBOutlet weak var signupNameTextField: UITextField!
    @IBOutlet weak var signupPasswordTextField: UITextField!
    
    var locManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "lul")!).withAlphaComponent(0.98)
        
        // CALCULATE LOCATION
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        
        var currentLocation: CLLocation!
        
        currentLocation = locManager.location
        
        MemeMatcher.longitude = currentLocation.coordinate.longitude
        MemeMatcher.latitude = currentLocation.coordinate.latitude
        
        print("hey!")
        print(MemeMatcher.longitude)
        print(MemeMatcher.latitude)
        
        // END OF LOCATION STUFF
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct User: Codable {
        let username: String
        let password: String
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func submitUser(user: User, completion:((Error?) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/users"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(user)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            completion?(error)
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                
                let currentUserJSON = try? JSONSerialization.jsonObject(with: data)
                if ((currentUserJSON! as AnyObject)["username"] == nil) {
                    return
                }
                let username = (currentUserJSON! as AnyObject)["username"]!!
                let id = (currentUserJSON! as AnyObject)["id"]!!
                let picture_url = (currentUserJSON! as AnyObject)["picture_url"]!!
                
                let username2 = username as! String
                let id2 = id as! Int
                let picture_url2 = picture_url as! String
                
                MemeMatcher.currentUser = MemeMatcher.User(id: id2, username: username2, picture_url: picture_url2)
            
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "successfulSignUp", sender: self)
                }
            } else {
                print("no readable data received in response")
            }
        }
        
        task.resume()
    }
    
    @IBAction func createAccountTap(_ sender: UITapGestureRecognizer) {
        let myUser = User(username: signupNameTextField.text!, password: signupPasswordTextField.text!)
        submitUser(user: myUser) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
}

