//
//  FeedAPI.swift
//  Travelers
//
//  Created by admin on 08/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class FeedAPI{
    var REF_FEED =  Database.database().reference().child("feed")
    
    //get new posts by followed user
    func observeFeed(withId id:String,completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childAdded, with: {
            snapshot in
            let key = snapshot.key
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    //delete posts from home view after unfollowing
    func observeFeedRemoved(withId id:String,completion: @escaping (Post) -> Void){
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            let key = snapshot.key
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
