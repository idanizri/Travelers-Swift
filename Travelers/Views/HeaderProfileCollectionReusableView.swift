//
//  HeaderProfileCollectionReusableView.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}
protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC()
}
class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2:HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
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
        
        API.My_Posts.fetchCountMyPosts(userId: user!.id!) { (count) in
            self.myPostsCountLabel.text = "\(count)"
        }
        
        API.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followersCountLabel.text = "\(count)"
        }
        
        API.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        
        
        if user?.id == API.User.CURRENT_USER?.uid{
            followButton.setTitle("Edit Profile", for: UIControl.State.normal)
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControl.Event.touchUpInside)
        }else{
            updateStateFollowButton()
        }
    }
    
    @objc func goToSettingVC(){
        delegate2?.goToSettingVC()
    }
    
    func updateStateFollowButton(){
        if user!.isFollowing!{
            
            configureUnFollowButton()
        }else{
            configureFollowButton()
        }
    }
    
    //when touching the follow button
    func configureFollowButton(){
        
        //setting the follow button looks
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        
        
        self.followButton.setTitle("Follow", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    //when touching the unfollow button
    func configureUnFollowButton(){
        
        //setting the following button looks
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        followButton.backgroundColor = UIColor.clear
        
        
        self.followButton.setTitle("Following", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    //create a new node in the database that indicates that the user is following
    @objc func followAction(){
        if user!.isFollowing == false{
            API.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing! = true
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    //deleting the node from the database that indicates the user is following
    @objc func unFollowAction(){
        if user!.isFollowing == true{
            API.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }
}

