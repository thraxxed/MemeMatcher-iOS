//
//  ThirdViewController.swift
//  MemeMatcher
//
//  Created by Hyun Chu on 2/18/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var signinNameTextField: UITextField!
    @IBOutlet weak var signinPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
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
                
                let username2 = username as! String
                let id2 = id as! Int
                let picture_url2 = picture_url as! String
                
                MemeMatcher.currentUser = MemeMatcher.User(id: id2, username: username2, picture_url: picture_url2,
                                                           latitude: MemeMatcher.latitude, longitude: MemeMatcher.longitude)
                
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
