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
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(true)
    }
    //deleting the node from the database that indicates the user is following
    func unFollowAction(withUser id: String){
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
}
