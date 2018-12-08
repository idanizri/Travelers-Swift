//
//  FollowAPI.swift
//  Travelers
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FollowAPI{
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    //create a new node in the database that indicates that the user is following
    func followAction(withUser id: String){
        API.My_Posts.REF_MY_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                for key in dict.keys{
                    Database.database().reference().child("feed").child((API.User.CURRENT_USER?.uid)!).child(key).setValue(true)
                }
            }
        })
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(true)
    }
    //deleting the node from the database that indicates the user is following
    func unFollowAction(withUser id: String){
        API.My_Posts.REF_MY_POSTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                for key in dict.keys{
                    Database.database().reference().child("feed").child((API.User.CURRENT_USER?.uid)!).child(key).removeValue()
                }
            }
        })
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }
    
    //check for a specific user if following
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void){
        REF_FOLLOWERS.child(userId).child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            }else{
                completed(true)
            }
        })
    }
    //get the count of children of node following in for a spesific user
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void){
        REF_FOLLOWING.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    
    //get the count of children of node followers in for a spesific user
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void){
        REF_FOLLOWERS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
