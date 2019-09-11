//
//  HashTagViewController.swift
//  Travelers
//
//  Created by admin on 10/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class HashTagViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [Post] = []
    var tag = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "\(tag)"
        collectionView.dataSource = self
        collectionView.delegate = self
        loadPosts()
    }
    
    func loadPosts(){
        API.HashTag.fetchPosts(withTag: tag) { (postId) in
            API.Post.observePost(withId: postId, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }

}
extension HashTagViewController: UICollectionViewDataSource{
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
    
    //getting the sender that sent before the segue has began
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "HashTag_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
        
    }

}

extension HashTagViewController: UICollectionViewDelegateFlowLayout {
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
extension HashTagViewController: PhotoCollectionViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "HashTag_DetailSegue", sender: postId)
    }
}
