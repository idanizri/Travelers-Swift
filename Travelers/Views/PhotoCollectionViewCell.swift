//
//  PhotoCollectionViewCell.swift
//  Travelers
//
//  Created by admin on 04/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
protocol PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String)

}
class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    var delegate: PhotoCollectionViewCellDelegate?
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    //feed new data that we got from database
    func updateView(){
        if let photoURLString = post?.photoURL{
            let photoURL = URL(string: photoURLString)
            photo?.sd_setImage(with: photoURL) { (image, error, cache, url) in
                if (error != nil){
                    print(error?.localizedDescription)
                }
            }
        }
        
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(photoTapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func photo_TouchUpInside(){
        if let id = post?.id{
            delegate?.goToDetailVC(postId: id)
        }
    }
}
