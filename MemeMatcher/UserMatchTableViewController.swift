//
//  UserMatchTableViewController.swift
//  MemeMatcher
//
//  Created by Zach Smith on 2/21/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

var currentMatch = ""

class UserMatchTableViewController: UITableViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MemeMatcher.getMatches(for: 1) { (result) in
            switch result {
            case .success(let matches):
                MemeMatcher.matches = matches
            case .failure(let error):
                fatalError("error: \(error.localizedDescription)")
            }
        }
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
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    let cellIdentifier = "UserMatches"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserMatches else {
            fatalError("The dequeued cell is not an instance of UserMatches.")
        }
        
        let match = MemeMatcher.matches[indexPath.row]
        cell.matchId.text = String(match.id)
        cell.userMatcherinos.text = match.username
        cell.userAgerino.text = String(match.age)
        if (matchIndex >= matches.count-1) {
            return cell
        }
        
        let adjustedUrl = "https:" + matches[matchIndex].picture_url
        let url = URL(string: adjustedUrl)
        matchIndex += 1

        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell.userImagerino.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "chatSegue":
            guard let selectedMatchCell = sender as? UserMatches else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            MemeMatcher.currentMatch = selectedMatchCell.matchId.text!
        default:
            return
        }
    }

}
