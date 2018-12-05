//
//  UserAPI.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class UserAPI{
    //refrence to users in database
    var REF_USERS = Database.database().reference().child("users")
    
    var REF_CURRENT_USER : DatabaseReference?{
        guard let currentUser = Auth.auth().currentUser else{
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
    
    var CURRENT_USER: FirebaseAuth.User?{
        if let currentUser = Auth.auth().currentUser{
            return currentUser
        }
        return nil
    }
    
    //get the loged in user
    func observeCurrentUser(completion: @escaping (User) -> Void){
        guard let currentUser = Auth.auth().currentUser else{
            return
        }
        let uid = currentUser.uid
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    //getting a user with a specific id
    func observeUser(withId uid: String, completion: @escaping (User) -> Void){
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (User) -> Void){
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
}
