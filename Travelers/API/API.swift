//
//  API.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
struct API{
    static var User = UserAPI()
    static var Post = PostAPI()
    static var Comment = CommentAPI()
    static var Post_Comment = Post_CommentAPI()
    static var My_Posts = MyPostsAPI()
    static var Follow = FollowAPI()
    static var Feed = FeedAPI()
    static var HashTag = HashTagAPI()
    static var Notification = NotificationAPI()
}
