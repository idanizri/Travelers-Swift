//
//  Post_CommentAPI.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class Post_CommentAPI{
    //refrence to comments in database
    var REF_POSTS_COMMENTS = Database.database().reference().child("posts-comments")
    
}
