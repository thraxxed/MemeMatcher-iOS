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
    
    @IBOutlet weak var userGenderFemale: UIButton!
    
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var ageLabel: UILabel!
    
    var currentGender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageSlider.value = Float(MemeMatcher.currentUser.age)
        ageLabel.text = "\(Int(ageSlider.value))"
        userBioField.text = MemeMatcher.currentUser.bio
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userBioField.text = MemeMatcher.currentUser.bio
        ageSlider.value = Float(MemeMatcher.currentUser.age)
        ageLabel.text = "\(Int(ageSlider.value))"
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
        let gender: String
        init(id: Int, picture: String, bio: String, age: Int, gender: String) {
            self.id = id
            self.picture = picture
            self.bio = bio
            self.age = age
            self.gender = gender
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
        photoImageView.image = selectedImage.resizedTo1MB()
        
        let imageData:Data = UIImagePNGRepresentation(photoImageView.image!)!
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
        
        MemeMatcher.currentUser.age = editUser.age
        
        
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
        MemeMatcher.currentUser.bio = userBioField.text!
        MemeMatcher.currentUser.age = Int(ageLabel.text!)!
        let editedUser = EditUser(id: MemeMatcher.currentUser.id, picture: imageStr, bio: userBioField.text!, age: Int(ageLabel.text!)!, gender: currentGender)
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
    
    @IBAction func changeGenderMale(_ sender: UITapGestureRecognizer) {
        currentGender = "M"
    }
    
    @IBAction func genderFemale(_ sender: UITapGestureRecognizer) {
        currentGender = "F"
    }
    
    
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = UIImagePNGRepresentation(self) else { return nil }
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / 1000.0
        
        while imageSizeKB > 1000 { 
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
                let imageData = UIImagePNGRepresentation(resizedImage)
                else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 1000.0
        }
        
        return resizingImage
    }
}
