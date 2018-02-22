//
//  MatchTableViewController.swift
//  MemeMatcher
//
//  Created by Zach Smith on 2/21/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class MatchTableViewController: UITableViewController, UITextFieldDelegate {

    
    //MARK Properties:
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dummyMatch: Match = Match(id: -1, username: "ddd", bio: "", age: -1, picture_url: "")
        
        matches.append(dummyMatch)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        getMatches(for: 1) { (result) in
            switch result {
            case .success(let matches):
                self.matches = matches
                print(self.matches)
                
            case .failure(let error):
                print(error )
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
    
    struct Match: Codable {
        let id: Int
        let username: String
        let bio: String
        let age: Int
        let picture_url: String
    }
    
    var matches = [Match]()
    
    
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
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
        
//        let user = User(id: MemeMatcher.currentUser.id)
        
//        let encoder = JSONEncoder()
//        do {
//            let jsonData = try encoder.encode(user)
//            request.httpBody = jsonData
//            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
//        } catch {
//            completion?(error as! MatchTableViewController.Result<[MatchTableViewController.Match]>)
//        }
        
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
    }

    let cellIdentifier = "MatchTableViewCell"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MatchTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let match = matches[indexPath.row]
        print("we're in the cellidntifier function")
        cell.matchUsername.text = match.username

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
