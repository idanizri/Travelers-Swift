//
//  NotificationAPI.swift
//  Travelers
//
//  Created by admin on 11/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
import FirebaseDatabase
class NotificationAPI{
    //refrence to comments in database
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id:String,completion: @escaping (Notification) -> Void){
        REF_NOTIFICATION.child(id).observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let newNotification = Notification.transformNotification(dict: dict, key: snapshot.key)
                completion(newNotification)
            }
        })
    }
}
