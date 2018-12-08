//
//  ProfileViewController.swift
//  Travelers
//
//  Created by admin on 02/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var posts: [Post] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        
        fetchUser()
        
        fetchMyPosts()
        
        collectionView.delegate = self
        
    }
    
    //fetch the posts by the users the current user follow
    func fetchMyPosts(){
        guard let currentUser = API.User.CURRENT_USER else{
            return
        }
        API.My_Posts.REF_MY_POSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            API.Post.observePost(withId: snapshot.key, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }
    
    //fetch the current user that is loged in so we can change the profile view to match the user
    func fetchUser(){
        API.User.observeCurrentUser { (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }
    
    //getting the sender that sent before the segue has began
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_SettingSegue"{
            let settingVC = segue.destination as! SettingTableViewController
            settingVC.delegate = self
        }
        if segue.identifier == "Profile_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }

    }
    
}
extension ProfileViewController: UICollectionViewDataSource{
    //amount of photos that we need to display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    //set the photos of a user in the profile
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        cell.delegate = self
        return cell
    }
    //set the data of the user to the collection view in the profile
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user{
            headerViewCell.user = user
            headerViewCell.delegate2 = self
        }
        return headerViewCell
    }
}

extension ProfileViewController: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC{
    func goToSettingVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
    
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    //make the pictures size so they will fit 3 pictures in one row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension ProfileViewController: nameSettingTableViewControllerDelegate{
    func updateUserInfo() {
        self.fetchUser()
    }
    
    
}
extension ProfileViewController: PhotoCollectionViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Profile_DetailSegue", sender: postId)
    }
}
