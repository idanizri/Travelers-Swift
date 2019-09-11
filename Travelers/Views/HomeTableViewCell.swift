//
//  HomeTableViewCell.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import AVFoundation
import KILabel
protocol HomeTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}
class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var isMuted = true
    var delegate: HomeTableViewCellDelegate?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
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
        
        let nameLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(nameLabelTapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    
    //touching the namelabel in the people cell
    @objc func nameLabel_TouchUpInside(){
        if let id = user?.id{
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    //perform the segue from the home view to the comments of that post
    @objc func commentImageView_TouchUpInside(){
        if let id = post?.id{
            delegate?.goToCommentVC(postId: id)
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
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.characters.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            let mention = String(string.characters.dropFirst())
            API.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
            //delegate?.goToProfileUserVC(userId: id)
        }
        if let photoURLString = post!.photoURL{
            if let ratio = post?.ratio{
                heightConstraintPhoto.constant = UIScreen.main.bounds.width / ratio
                layoutIfNeeded()
            }
            let photoURL = URL(string: photoURLString)
            postImageView?.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if (error != nil){
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
        }
        
        if let videoURLString = post?.videoURL, let _ = URL(string: videoURLString) {
            self.volumeView.isHidden = false
            let videoURL = URL(string: videoURLString)
            player = AVPlayer(url: videoURL!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = postImageView.frame
            playerLayer?.frame.size.width = UIScreen.main.bounds.width
            self.contentView.layer.addSublayer(playerLayer!)
            self.volumeView.layer.zPosition = 1
            player?.play()
            player?.isMuted = isMuted
        }
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            if diff.second! <= 0{
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0{
                timeText = (diff.second! == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0{
                timeText = (diff.minute! == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0{
                timeText = (diff.hour! == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0{
                timeText = (diff.day! == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth! == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            timeLabel.text = timeText
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
        volumeView.isHidden = true
        profileImageView.image = UIImage(named: "placeholderImg")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    @IBAction func volumeBtn_TouchUpInside(_ sender: UIButton) {
        if isMuted{
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Icon_Volume"), for: UIControl.State.normal)
        }else{
            volumeButton.setImage(UIImage(named: "Icon_Mute"), for: UIControl.State.normal)
            isMuted = !isMuted
        }
        player?.isMuted = isMuted
    }

}
