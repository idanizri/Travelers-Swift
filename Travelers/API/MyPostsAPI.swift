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
}
