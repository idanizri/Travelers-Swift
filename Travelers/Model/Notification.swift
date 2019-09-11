//
//  Notification.swift
//  Travelers
//
//  Created by admin on 11/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
class Notification{
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
}
extension Notification{
    //transform data that we got from database to a class post
    static func transformNotification(dict: [String: Any],key: String) -> Notification{
        let notification = Notification()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict ["from"] as? String
        return notification
    }
}
