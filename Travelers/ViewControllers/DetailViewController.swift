//
//  DetailViewController.swift
//  Travelers
//
//  Created by admin on 09/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var postId = ""
    var post = Post()
    var user = User()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPost()
    }
    func loadPost(){
        API.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else{
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    //fetching the user from the database so we can couple the post photo to the user
    func fetchUser(uid: String,completed: @escaping () -> Void){
        API.User.observeUser(withId: uid) { (user) in
            self.user = user
            completed()
        }
    }
    
    //getting the sender that sent before the segue has began
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail_CommentSegue"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Detail_ProfileUserSegue"{
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }

}
extension DetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! HomeTableViewCell
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}
extension DetailViewController: HomeTableViewCellDelegate{
    func goToCommentVC(postId : String) {
        performSegue(withIdentifier: "Detail_CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Detail_ProfileUserSegue", sender: userId)
    }
}
