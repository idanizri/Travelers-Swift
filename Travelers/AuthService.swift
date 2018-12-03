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
        newUserRefrence.setValue(["username": username, "email": email, "profileImageURL": profileImageURL])
        onSuccess()
    }
}
