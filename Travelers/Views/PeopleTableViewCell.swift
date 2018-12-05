//
//  PeopleTableViewCell.swift
//  Travelers
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    //when a new user is set for a cell it will automaticlly update the cell view
    var user: User?{
        didSet{
            updateView()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL{
            let photoURL = URL(string: photoURLString)
            profileImage.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if error != nil{
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
        
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
        }
    }
    
    //deleting the node from the database that indicates the user is following
    @objc func unFollowAction(){
        if user!.isFollowing == true{
            API.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user!.isFollowing! = false
        }
    }
}
