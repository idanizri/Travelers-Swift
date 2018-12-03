//
//  Comment.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
//class that hold the comment information from the database
class Comment{
    var commentText: String?
    var uid: String?
}
extension Comment{
    //transform data that we got from database to a class comment
    static func transformComment(dict: [String: Any]) -> Comment{
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
