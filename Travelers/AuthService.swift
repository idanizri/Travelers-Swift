//
//  AuthService.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//this class is here to help us decouple between the controller and the model
class AuthService {
    
    //sign in to the user in the remote Authentication
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil{
                onError(error?.localizedDescription)
                return
            }
            //the user we got
            guard (authResult?.user) != nil else { return }
            onSuccess()
        }
    }
    
    //sign up user to the remote Authentication
    static func signUp(email: String, password: String,username: String,imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil{
                onError(error?.localizedDescription)
            }
            
            //the user we got
            guard let user = authResult?.user else { return }
            let uid = user.uid
            
            //put the profile photo in the storage
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_Image").child(uid)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    onError(error?.localizedDescription)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    guard let profileImageURL = url?.absoluteString else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    self.setUserInformation(profileImageURL: profileImageURL, username: username, email: email, uid: uid, onSuccess: onSuccess)
                }
            })
        }
    }
    //set the user information in the database and not just the autentication
    static func setUserInformation(profileImageURL: String, username: String, email: String, uid: String,onSuccess: @escaping () -> Void){
        //put user at the database
        let ref = Database.database().reference()
        let usersRefrence = ref.child("users")
        let newUserRefrence = usersRefrence.child(uid)
        newUserRefrence.setValue(["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageURL": profileImageURL])
        onSuccess()
    }
    
    //change the user information like the profile image the username and the email that is givven to us from the edit profile view
    static func updateUserInfo(email: String, username: String,imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        
        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil{
               onError(error?.localizedDescription)
            }else{
                let uid = API.User.CURRENT_USER?.uid
                //put the profile photo in the storage
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_Image").child(uid!)
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        onError(error?.localizedDescription)
                        return
                    }
                    storageRef.downloadURL { (url, error) in
                        guard let profileImageURL = url?.absoluteString else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        self.updateDatabase(profileImageURL: profileImageURL, username: username, email: email, onSuccess: onSuccess, onError: onError)
                        self.setUserInformation(profileImageURL: profileImageURL, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                    }
                })
            }
        })
    }
    
    //modify the data that is in the database
    static func updateDatabase(profileImageURL: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        let dict = ["username": username, "username_lowercase": username.lowercased(), "email": email, "profileImageURL": profileImageURL]
        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil{
                onError(error?.localizedDescription)
            }
            onSuccess()
        })
    }
    
    //sign out the user credetials from the database
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        do{
        try Auth.auth().signOut()
        onSuccess()
        }catch let logoutError{
        onError(logoutError.localizedDescription)
        }
    }
}
