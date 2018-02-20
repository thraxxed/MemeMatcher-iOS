//
//  FourthViewController.swift
//  MemeMatcher
//
//  Created by Zach Smith on 2/19/18.
//  Copyright © 2018 Seth Little. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK Properties:
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var submitUpdate: UIButton!
    @IBOutlet weak var userBioField: UITextField!
    @IBOutlet weak var userGenderMale: UIStackView!
    
    
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var ageLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageSlider.value = Float(MemeMatcher.currentUser.age)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct EditUser: Codable {
        let id: Int
        let picture: String
        let bio: String
        let age: Int
        init(id: Int, picture: String, bio: String, age: Int) {
            self.id = id
            self.picture = picture
            self.bio = bio
            self.age = age
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        let imageData:Data = UIImagePNGRepresentation(selectedImage)!
        imageStr = imageData.base64EncodedString()
        
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    var imageStr = ""
    
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
        DispatchQueue.main.async(){
            self.performSegue(withIdentifier: "successfulUserUpdate", sender: self)
        }
        task.resume()
    }

    
    //MARK Actions:
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func updateUserProfile(_ sender: UITapGestureRecognizer) {
        let editedUser = EditUser(id: MemeMatcher.currentUser.id, picture: imageStr, bio: userBioField.text!, age: Int(ageLabel.text!)!)
        patchUser(editUser: editedUser) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        ageLabel.text = "\(currentValue)"
    }
    

}
