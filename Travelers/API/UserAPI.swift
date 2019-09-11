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
    
    func observeUserByUsername(username: String, completion: @escaping (User) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
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
    
    //observe all users
    func observeUsers(completion: @escaping (User) -> Void){
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user.id != API.User.CURRENT_USER?.uid{
                    completion(user)
                }
            }
        })
    }
    //query users from database
    func queryUser(withText text: String, completion: @escaping (User) -> Void){
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toLast: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any]{
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        })
    }
}
