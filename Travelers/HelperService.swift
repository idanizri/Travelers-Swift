//
//  HelperService.swift
//  Travelers
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
//this class is created for helping sending data to storage
class HelperService  {
    
    //uplaoding given data to the storage and sending to a function that sends the data to database
    static func uploadDataToServer(data: Data, videoURL: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void){
        if let videoURL = videoURL {
            uploadVideoToFirebaseStorage(videouURL: videoURL) { (videoURL) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageURL) in
                    sendDataToDatabase(photoURL: thumbnailImageURL, videoURL: videoURL, ratio: ratio, caption: caption, onSuccess: onSuccess)
                })
            }
        }else{
            uploadImageToFirebaseStorage(data: data) { (photoURL) in
                self.sendDataToDatabase(photoURL: photoURL, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videouURL: URL, onSuccess: @escaping (_ videoURL: String) -> Void){
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(videoIdString)
        storageRef.putFile(from: videouURL, metadata: nil) { (metadata, error) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let videoURL = url?.absoluteString else {
                    // Uh-oh, an error occurred!
                    return
                }
                onSuccess(videoURL)
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageURL: String) -> Void){
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
                onSuccess(photoURL)
            }
        })
    }
    
    //sending the new uploading photo to the database
    static func sendDataToDatabase(photoURL: String, videoURL: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void){
        let newPostId = API.Post.REF_POSTS.childByAutoId().key
        let newPostRefrence = API.Post.REF_POSTS.child(newPostId!)
        
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashtagRef = API.HashTag.REF_HASHTAG.child(word.lowercased())
                print(word)
                print(newHashtagRef.description())
                newHashtagRef.child(newPostId!).setValue(true)
            }
        }
        
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var dict = ["uid": currentUserId, "photoURL": photoURL, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String : Any]
        
        if let videoURL = videoURL {
            dict["videoURL"] = videoURL
        }
        
        newPostRefrence.setValue(dict) { (error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            API.Feed.REF_FEED.child((API.User.CURRENT_USER?.uid)!).child(newPostId!).setValue(true)
            API.Follow.REF_FOLLOWERS.child((API.User.CURRENT_USER?.uid)!).observeSingleEvent(of: .value, with: {
                snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    API.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId!)" : true])
                    let _ = API.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationRefrence = API.Notification.REF_NOTIFICATION.child(child.key).child(newPostId!)
                    newNotificationRefrence.setValue(["from": (API.User.CURRENT_USER?.uid)!, "type": "feed", "objectId": newPostId!, "timestamp": timestamp])
                })
            })
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
