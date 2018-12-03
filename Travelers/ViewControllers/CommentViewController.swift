//
//  CommentViewController.swift
//  Travelers
//
//  Created by admin on 03/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class CommentViewController: UIViewController {
    
    
    var comments = [Comment]()
    var users = [User]()
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var constraintToButtom: NSLayoutConstraint!
    
    
    let postId = "-LSotBJnS0emFkIERVjl"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        
        //adjust the size of the cell so every comment will fit there
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableView.automaticDimension
        
        handleTextField()
        empty()
        loadComments()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tableView.addGestureRecognizer(tapGesture)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    //making the send comment view go up if the keyboard is toggled
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3){
            self.constraintToButtom.constant = ((keyboardFrame?.height)! * -1)
            self.view.layoutIfNeeded()
        }
        
    }
    
    //making the send comment view go down to the buttom if the keyboard dissapear
    @objc func keyboardWillHide(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3){
            self.constraintToButtom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    //load all the comments to the corresponding user
    func loadComments(){
        let postCommentRef = Database.database().reference().child("post-comments").child(self.postId)
        postCommentRef.observe(.childAdded, with: {
            snapshot in
            Database.database().reference().child("comments").child(snapshot.key).observeSingleEvent(of: .value, with: {
                snapshotComment in
                if let dict = snapshotComment.value as?[String: Any]{
                    let newComment = Comment.transformComment(dict: dict)
                    self.fetchUser(uid: newComment.uid!,completed: {
                        self.comments.append(newComment)
                        self.tableView.reloadData()
                    })
                }
            })
        })
    }
    
    //fetching the user from the database so we can couple the comment to the user
    func fetchUser(uid: String,completed: @escaping () -> Void){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any]{
                let user = User.transformUser(dict: dict)
                self.users.append(user)
                completed()
            }
        })
    }
    
    //disable showing the tabbar when we move to the comments view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
//    }
    
    //sharing a comment to the post
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        //put user at the database
        let ref = Database.database().reference()
        let commentsRefrence = ref.child("comments")
        let newCommentId = commentsRefrence.childByAutoId().key
        let newCommentRefrence = commentsRefrence.child(newCommentId!)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentRefrence.setValue(["uid": currentUserId,"commentText": commentTextField.text!]) { (error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            let postCommentRef = Database.database().reference().child("post-comments").child(self.postId).child(newCommentId!)
            print(postCommentRef)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            self.empty()
            self.view.endEditing(true)
        }
    }
    
    //make the send button active or unactive when a new comment is written or deleted
    func handleTextField(){
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChanged), for: UIControl.Event.editingChanged)
    }
    
    //the text field is edited
    @objc func textFieldDidChanged(){
        if let commentText = commentTextField.text, !commentText.isEmpty{
            sendButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        sendButton.isEnabled = false
    }
    
    
    //empty and disabling the send button
    func empty(){
        self.commentTextField.text = ""
        sendButton.setTitleColor(UIColor.lightGray, for: UIControl.State.normal)
        sendButton.isEnabled = false
    }
}
extension CommentViewController: UITableViewDataSource {
    //seting the amount of cells we want to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //set the cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        cell.user = users[indexPath.row]
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    
}
