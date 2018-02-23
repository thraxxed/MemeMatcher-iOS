//
//  UserMatchTableViewController.swift
//  MemeMatcher
//
//  Created by Zach Smith on 2/21/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class UserMatchTableViewController: UITableViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MemeMatcher.getMatches(for: 1) { (result) in
            switch result {
            case .success(let matches):
                MemeMatcher.matches = matches
                print(MemeMatcher.matches)
            case .failure(let error):
                print(error)
                fatalError("error: \(error.localizedDescription)")
            }
        }
        
        print("zzz")
        print(MemeMatcher.matches)
        
    }
    
    struct User: Codable {
        let id: Int
        init(id: Int) {
            self.id = id
        }
    }
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    var matchIndex = 0
    
    func getMatches(for id: Int, completion: ((Result<[Match]>) -> Void)?) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "meme-matcher.herokuapp.com"
        urlComponents.path = "/api/users"
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    let decoder = JSONDecoder()
                    do {
                        let matches = try decoder.decode([Match].self, from: jsonData)
                        completion?(.success(matches))
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("yo")
        print(matches.count)
        return matches.count
//        return 1
    }
    
    let cellIdentifier = "UserMatches"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserMatches else {
            fatalError("The dequeued cell is not an instance of UserMatches.")
        }
        
        let match = MemeMatcher.matches[indexPath.row]
        print("we're in the cellidntifier function")
        cell.userMatcherinos.text = match.username
        cell.userAgerino.text = String(match.age)
        if (matchIndex >= matches.count-1) {
            return cell
        }
        
        let shit = "https:" + matches[matchIndex].picture_url
        print(shit)
        let url = URL(string: shit)
        matchIndex += 1

        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.userImagerino.image = UIImage(data: data!)
            }
        }
        
        return cell
    }

}
