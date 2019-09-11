//
//  HashTagAPI.swift
//  Travelers
//
//  Created by admin on 10/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class HashTagAPI{
    //refrence to comments in database
    var REF_HASHTAG = Database.database().reference().child("hashtag")
    
    func fetchPosts(withTag tag:String, completion: @escaping (String) -> Void){
        REF_HASHTAG.child(tag.lowercased()).observe(.childAdded, with: {
            snapshot in
            completion(snapshot.key)
        })
    }
}
