//
//  PostAPI.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class PostAPI{
    //refrence of posts in database
    var REF_POSTS = Database.database().reference().child("posts")
    
    //geting all the posts from the database
    func observePosts(completion: @escaping (Post) -> Void){
        REF_POSTS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as?[String: Any]{
                let newPost = Post.transformPost(dict: dict,key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    //getting a user with a specific id
    func observePost(withId id: String, completion: @escaping (Post) -> Void){
        REF_POSTS.child(id).observeSingleEvent(of: DataEventType.value
            , with: {
                snapshot in
                if let dict = snapshot.value as? [String: Any]{
                    let post = Post.transformPost(dict: dict, key: snapshot.key)
                    completion(post)
                }
        })
    }
    
    //checking the amount of likes in database of a specific post and returning it in espacing clouser
    func observeLikeCount(withPostId id: String, completion: @escaping (Int) -> Void){
        REF_POSTS.child(id).observe(.childAdded, with: {
            snapshot in
            if let count = snapshot.value as? Int{
                completion(count)
            }
        })
    }
    
    //increase the amount of like by 1 decrease by 1 using the firebase transaction tool
    func incrementLikes(postId: String, onSuccess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        let postRef = API.Post.REF_POSTS.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = API.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unlike the post and remove self from likes
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    // Like the post and add self to likes
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any]{
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                onSuccess(post)
            }
        }
    }
}
