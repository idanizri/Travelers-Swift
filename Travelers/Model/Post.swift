//
//  Post.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseAuth
//class that hold the post information from the database
class Post{
    var caption: String?
    var photoURL: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var ratio: CGFloat?
    var videoURL: String?
    var timestamp: Int?
}
extension Post{
    //transform data that we got from database to a class post
    static func transformPost(dict: [String: Any],key: String) -> Post{
        let post = Post()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoURL = dict["photoURL"] as? String
        post.videoURL = dict["videoURL"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict ["likes"] as? Dictionary<String, Any>
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        //checks if the current user is in the array of likes for a specific post
        if let currentUserId = Auth.auth().currentUser?.uid{
            if post.likes != nil{
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        return post
    }
}
