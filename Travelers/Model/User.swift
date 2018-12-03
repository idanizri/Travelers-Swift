//
//  User.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import Foundation
//class that will help us hold the user infrormation from the database
class User{
    var email: String?
    var profileImageURL: String?
    var username: String?
}
extension User{
    static func transformUser(dict: [String:Any]) -> User{
        let user = User()
        user.email = dict["email"] as? String
        user.username = dict["username"] as? String
        user.profileImageURL = dict["profileImageURL"] as? String
        return user
    }
}
