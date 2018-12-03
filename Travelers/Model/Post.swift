//
//  Post.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
//class that hold the post information from the database
class Post{
    var caption: String?
    var photoURL: String?
    var uid: String?
}
extension Post{
    //transform data that we got from database to a class post
    static func transformPost(dict: [String: Any]) -> Post{
        let post = Post()
        post.caption = dict["caption"] as? String
        post.photoURL = dict["photoURL"] as? String
        post.uid = dict["uid"] as? String
        return post
    }
}
