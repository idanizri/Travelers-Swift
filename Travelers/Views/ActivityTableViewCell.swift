//
//  ActivityTableViewCell.swift
//  Travelers
//
//  Created by admin on 11/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
protocol ActivityTableViewCellDelegate {
    func goToDetailVC(postId: String)
    //func goToProfileVC(userId: String)
}
class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: ActivityTableViewCellDelegate?
    
    var notification: Notification?{
        didSet{
            updateView()
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    
    func updateView(){
        switch notification!.type! {
        case "feed":
            descriptionLabel.text = "added a new post"
            let postId = notification!.objectId!
            API.Post.observePost(withId: postId) { (post) in
                if let photoURLString = post.photoURL{
                    let photoURL = URL(string: photoURLString)
                    self.photo.sd_setImage(with: photoURL) { (image, error, cache, url) in
                        if error != nil{
                            ProgressHUD.showError(error?.localizedDescription)
                        }
                    }
                }

            }
        default:
            print("default")
        }
        
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            if diff.second! <= 0{
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0{
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0{
                timeText = "\(diff.minute!)m"
            }
            if diff.hour! > 0 && diff.day! == 0{
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0{
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            timeLabel.text = timeText
        }
        
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(photoTapGesture)
        isUserInteractionEnabled = true
        
    }
    
    @objc func cell_TouchUpInside(){
        if let id = notification?.objectId{
            delegate?.goToDetailVC(postId: id)
        }
    }
    
    func setupUserInfo(){
        nameLabel.text = user?.username
        if let photoURLString = user?.profileImageURL{
            let photoURL = URL(string: photoURLString)
            profileImage.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if error != nil{
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
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

}
