//
//  SignUpViewController.swift
//  Travelers
//
//  Created by admin on 02/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //set the email text field looks
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        emailTextField.textColor = UIColor.white
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        
        //set the password text field looks
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        passwordTextField.textColor = UIColor.white
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerPassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        
        //set the username text field looks
        usernameTextField.backgroundColor = UIColor.clear
        usernameTextField.tintColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1, alpha: 0.6)])
        usernameTextField.textColor = UIColor.white
        let bottomLayerUsername = CALayer()
        bottomLayerUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        bottomLayerUsername.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(bottomLayerUsername)
        
        
        //set profileImage as round
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        
        
        //make the profile image view tapable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
    }
    
    //changing the photo of the profile image when a user taped it
    @objc func handleSelectProfileImageView(){
        let pickerConbtroller = UIImagePickerController()
        //making the finished picking media available
        pickerConbtroller.delegate = self
        
        present(pickerConbtroller, animated: true, completion: nil)
    }
    
    //return to the sign in view
    @IBAction func dismiss_OnClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //the user touched the sign up button to sign up
    @IBAction func SignUpBtn_TouchUpInside(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
            }
            
            //the user we got
            guard let user = authResult?.user else { return }
            let uid = user.uid
            
            //put user at the database
            let ref = Database.database().reference()
            
            //put the profile photo in the storage
            let storageRef = Storage.storage().reference(forURL: "gs://travelers-b2bd8.appspot.com").child("profile_Image").child(uid)
            if let profileImag = self.selectedImage, let imageData = profileImag.jpegData(compressionQuality: 0.1) {
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let profileImageURL = url?.absoluteString else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        let usersRefrence = ref.child("users")
                        let newUserRefrence = usersRefrence.child(uid)
                        newUserRefrence.setValue(["username": self.usernameTextField.text!, "email": self.emailTextField.text!, "profileImageURL": profileImageURL])
                    }
                })
            }
        }
        
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        if let image = info[.originalImage] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
