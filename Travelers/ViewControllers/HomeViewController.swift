//
//  HomeViewController.swift
//  Travelers
//
//  Created by admin on 02/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import SDWebImage
class HomeViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //adjust the size of the cell so every post will fit there
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.dataSource = self
        loadPosts()
    }
    
    //loading all the posts from the database
    func loadPosts(){
        
        API.Feed.observeFeed(withId: API.User.CURRENT_USER!.uid) { (post) in
            guard let postUid = post.uid else{
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.posts.append(post)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            })
        }
        
        //filter unfollowed posts from users
        API.Feed.observeFeedRemoved(withId: API.User.CURRENT_USER!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id}
            self.users = self.users.filter {$0.id != post.uid}
            self.tableView.reloadData()
        }
    }
    
    //fetching the user from the database so we can couple the post photo to the user
    func fetchUser(uid: String,completed: @escaping () -> Void){
        API.User.observeUser(withId: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }
    
    //getting the sender that sent before the segue has began
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue"{
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }
    
    
}
extension HomeViewController: UITableViewDataSource {
    //seting the amount of cells we want to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    //set the cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! HomeTableViewCell
        cell.user = users[indexPath.row]
        cell.post = posts[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
}
extension HomeViewController: HomeTableViewCellDelegate{
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    
}
