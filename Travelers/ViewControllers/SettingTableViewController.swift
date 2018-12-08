//
//  SettingTableViewController.swift
//  Travelers
//
//  Created by admin on 08/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
protocol nameSettingTableViewControllerDelegate {
    func updateUserInfo()
}
class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: nameSettingTableViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        fetchCurrentUser()
    }
    
    //get current user and the current user data
    func fetchCurrentUser(){
        API.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            if let photoURLString = user.profileImageURL{
                let photoURL = URL(string: photoURLString)
                self.profileImageView.sd_setImage(with: photoURL) { (image, error, cache, url) in
                    if error != nil{
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                }
            }
        }
    }
    
    //save the changes that the user has changed
    @IBAction func save_Btn_TouchUpInside(_ sender: Any) {
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImag = self.profileImageView.image, let imageData = profileImag.jpegData(compressionQuality: 0.1) {
            AuthService.updateUserInfo(email: emailTextField.text!, username: usernameTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfo()
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage!)
            }
        }
    }
    
    //loging out the current user
    @IBAction func logout_Btn_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    //changing the current profile image
    @IBAction func changeProfile_Btn_TouchUpInside(_ sender: Any) {
        let pickerConbtroller = UIImagePickerController()
        //making the finished picking media available
        pickerConbtroller.delegate = self
        
        present(pickerConbtroller, animated: true, completion: nil)
    }
}
//make the picture above editable
extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //show the camera roll to select a new photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
}
extension SettingTableViewController: UITextFieldDelegate{
    //taping the return button to dismiss the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
