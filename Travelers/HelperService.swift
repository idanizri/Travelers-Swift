//
//  HelperService.swift
//  Travelers
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseStorage
//this class is created for helping sending data to storage
class HelperService  {
    
    //uplaoding given data to the storage and sending to a function that sends the data to database
    static func uploadDataToServer(data: Data, caption: String, onSuccess: @escaping () -> Void){
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIdString)
         storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let photoURL = url?.absoluteString else {
                    // Uh-oh, an error occurred!
                    return
                }
                self.sendDataToDatabase(photoURL: photoURL, caption: caption, onSuccess: onSuccess)
            }
        })
    }
    
    //sending the new uploading photo to the database
    static func sendDataToDatabase(photoURL: String, caption: String, onSuccess: @escaping () -> Void){
        let newPostId = API.Post.REF_POSTS.childByAutoId().key
        let newPostRefrence = API.Post.REF_POSTS.child(newPostId!)
        
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newPostRefrence.setValue(["uid": currentUserId, "photoURL": photoURL, "caption": caption, "likeCount": 0]) { (error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            API.Feed.REF_FEED.child((API.User.CURRENT_USER?.uid)!).child(newPostId!).setValue(true)
            
            let myPostRef = API.My_Posts.REF_MY_POSTS.child(currentUserId).child(newPostId!)
            myPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            onSuccess()
        }
    }
}
