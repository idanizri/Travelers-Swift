//
//  MyPostsAPI.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class MyPostsAPI{
    var REF_MY_POSTS = Database.database().reference().child("myPosts")
    
    func fetchMyPosts(userId: String,completion: @escaping (String) -> Void){
        REF_MY_POSTS.child(userId).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
    
    //check the count of children in the node my posts
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void){
        REF_MY_POSTS.child(userId).observe(.value, with: {
            snapshot in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
