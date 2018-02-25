//
//  ChatView.swift
//  MemeMatcher
//
//  Created by Hyun Chu on 2/22/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit



class ChatView: UIViewController {
    
    
    var messages = [Message]()
    
    //MARK: Properties
    
    @IBOutlet weak var sendChatButton: UIButton!
    
    @IBOutlet weak var messageInputField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch messages
        getMessages(for: 1) { (result) in
            switch result {
            case .success(let messages):
                self.messages = messages
                var yOffset = 0
                for message in self.messages {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                    label.center = CGPoint(x: 160, y: 80 + yOffset)
                    if (message.author_id == MemeMatcher.currentUser.id) {
                        label.textAlignment = .right
                    } else {
                        label.textAlignment = .left
                    }
                    label.text = message.body
                    self.view.addSubview(label)
                    yOffset += 30
                }
                print(self.messages)
            case .failure(let error):
                print(error )
                fatalError("error: \(error.localizedDescription)")
            }
        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct Message: Codable {
        let id: Int
        let user1_id: Int
        let user2_id: Int
        let body: String
        let author_id: Int
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    struct formMessage: Codable {
        let body: String
        let id: String
        init(body: String, id: String) {
            self.body = body
            self.id = id
        }
    }
    
    
    func getMessages(for id: Int, completion: ((Result<[Message]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/messages"
        
        urlComponents.queryItems = [URLQueryItem(name: "id", value: "\(MemeMatcher.currentMatch)")]
        
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
                    let decoder = JSONDecoder()
                    do {
                        let messages = try decoder.decode([Message].self, from: jsonData)
                        completion?(.success(messages))
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
    
    //MARK: Actions
    
    @IBAction func postMessage(_ sender: UITapGestureRecognizer) {
        print(messageInputField.text!)
        if (messageInputField.text == "") {
            print("did not post message because input was empty")
            return
        }
        
        let fm = formMessage(body: messageInputField.text!,
                             id: MemeMatcher.currentMatch)
        sendPostMessage(message: fm) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        messageInputField.text = ""
    }
    
    func sendPostMessage(message: formMessage, completion:((Error?) -> Void)?){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/messages"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(message)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}