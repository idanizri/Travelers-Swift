//
//  CommentTableViewCell.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import KILabel
protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userId: String)
    func goToHashTag(tag: String)
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: KILabel!
    
    
    var delegate: CommentTableViewCellDelegate?
    var comment: Comment?{
        didSet{
            updateView()
        }
    }
    var user: User?{
        didSet{
            setupUserInfo()
        }
    }
    
    //update the comment when a user has updated
    func updateView(){
        commentLabel.text = comment?.commentText
        
        commentLabel.hashtagLinkTapHandler = { label, string, range in
            let tag = String(string.characters.dropFirst())
            self.delegate?.goToHashTag(tag: tag)
        }

        commentLabel.userHandleLinkTapHandler = { label, string, range in
            let mention = String(string.characters.dropFirst())
            API.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user.id!)
            })
        }
    }
    
    //update the profie image and the username in the view
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
        commentLabel.text = ""
        nameLabel.text = ""
        profileImage.image = UIImage(named: "placeholderImg")
        
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
    
    //when we scroll fast the comment we want to place a placeholder initially before changing the data
    override func prepareForReuse() {
        profileImage.image = UIImage(named: "placeholderImg")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
