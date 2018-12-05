//
//  HeaderProfileCollectionReusableView.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
class HeaderProfileCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var user: User?{
        didSet{
            updateView()
        }
    }
    //set the user info to the collection view in the profile view
    func updateView(){
        self.nameLabel.text = user!.username
        if let photoURLString = user!.profileImageURL{
                let photoURL = URL(string: photoURLString)
                self.profileImage?.sd_setImage(with: photoURL) { (image, error, cache, url) in
                    if (error != nil){
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                }
            }
    }
}

