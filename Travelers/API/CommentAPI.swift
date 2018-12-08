//
//  CommentAPI.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class CommentAPI{
    //refrence to comments in database
    var REF_COMMENTS = Database.database().reference().child("comments")
    
    
    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void){
        REF_COMMENTS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let comment = Comment.transformComment(dict: dict)
                completion(comment)
            }
        })
    }
}
