//
//  HomeTableViewCell.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var homeVC: HomeViewController?
    var post: Post?{
        didSet{
            updateView()
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.text = ""
        captionLabel.text = ""
        
        //make the comment picture tapable
        let commentTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(commentTapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        //make the comment picture tapable
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(likeTapGesture)
        likeImageView.isUserInteractionEnabled = true
    }
    
    //perform the segue from the home view to the comments of that post
    @objc func commentImageView_TouchUpInside(){
        if let id = post?.id{
            homeVC?.performSegue(withIdentifier: "CommentSegue", sender: id)
        }
    }
    //perform a like or unlike
    @objc func likeImageView_TouchUpInside(){
        API.Post.incrementLikes(postId:  post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //when a new post is feeded to the cell it will automaticly update the changes
    func updateView(){
        captionLabel.text = post!.caption
        if let photoURLString = post!.photoURL{
            let photoURL = URL(string: photoURLString)
            postImageView?.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if (error != nil){
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
        

        self.updateLike(post: self.post!)
        
    }
    
    //update the amount of like for a post and check if the current user did liked or didn't like the post
    func updateLike(post: Post){
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        guard let count = post.likeCount else{
            likeCountButton.setTitle("Be the first to like this", for: UIControl.State.normal)
            return
        }
        if count != 0 {
            likeCountButton.setTitle("\(count) likes", for: UIControl.State.normal)
        }else{
            likeCountButton.setTitle("Be the first to like this", for: UIControl.State.normal)
        }

    }
    
    //setup the user information of a post he shared
    func setupUserInfo(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL{
            let photoURL = URL(string: photoURLString)
            profileImageView.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if error != nil{
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
    }
    
    //when we scrol fast and reuse data we want to place a placeholder before the changes are commited
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: "placeholderImg")
    }
    

}
