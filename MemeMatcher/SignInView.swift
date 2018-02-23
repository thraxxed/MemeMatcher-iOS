//
//  ThirdViewController.swift
//  MemeMatcher
//
//  Created by Hyun Chu on 2/18/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit
import CoreLocation

class ThirdViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var signinNameTextField: UITextField!
    @IBOutlet weak var signinPasswordTextField: UITextField!
    
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cloudy")!)
        
        // CALCULATE LOCATION
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        
        var currentLocation: CLLocation!
        
        currentLocation = locManager.location
        
        MemeMatcher.longitude = currentLocation.coordinate.longitude
        MemeMatcher.latitude = currentLocation.coordinate.latitude

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct User: Codable {
        let username: String
        let password: String
    }
    
    struct EditUser: Codable {
        let id: Int
        let longitude: Double
        let latitude: Double
        init(id: Int) {
            self.id = id
            self.latitude = MemeMatcher.latitude
            self.longitude = MemeMatcher.longitude
        }
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func patchUser(editUser: EditUser, completion:((Error?) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/users/\(MemeMatcher.currentUser.id)"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(editUser)
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
        }
        task.resume()
    }
    
    func submitUser(user: User, completion:((Error?) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/session"
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
                let age = (currentUserJSON! as AnyObject)["age"]!!
                let gender = (currentUserJSON! as AnyObject)["gender"]!!
                let bio = (currentUserJSON! as AnyObject)["bio"]!!
                
                let username2 = username as! String
                let id2 = id as! Int
                let picture_url2 = picture_url as! String
                let age2 = age as! Int
                let gender2 = gender as! String
                let bio2 = bio as! String
                
                MemeMatcher.currentUser = MemeMatcher.User(id: id2, username: username2, picture_url: picture_url2,
                                                           latitude: MemeMatcher.latitude, longitude: MemeMatcher.longitude, age: age2,
                                                           gender:gender2, bio: bio2)
                
                getMatches(for: 1) { (result) in
                    switch result {
                    case .success(let matches):
                        MemeMatcher.matches = matches
                        print(MemeMatcher.matches)
                    case .failure(let error):
                        print(error)
                        fatalError("error: \(error.localizedDescription)")
                    }
                }
                
                let editedUser = EditUser(id: id2)
                self.patchUser(editUser: editedUser) { (error) in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
                
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "successfulSignIn", sender: self)
                }
            } else {
                print("no readable data received in response")
            }
        }
        
        task.resume()
    }
    
    //MARK: Actions
    
    @IBAction func createSessionTap(_ sender: UITapGestureRecognizer) {
        
        let myUser = User(username: signinNameTextField.text!, password: signinPasswordTextField.text!)
        submitUser(user: myUser) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
