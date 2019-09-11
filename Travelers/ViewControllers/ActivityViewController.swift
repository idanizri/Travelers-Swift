//
//  ActivityViewController.swift
//  Travelers
//
//  Created by admin on 02/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var notifications = [Notification]()
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadNotifications()
    }
    func loadNotifications(){
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        API.Notification.observeNotification(withId: currentUser.uid ,completion:{
            notification in
            guard let uid = notification.from else{
                return
            }
            self.fetchUser(uid: uid, completed: {
                self.notifications.insert(notification, at: 0)
                self.tableView.reloadData()
            })

        })
    }
    
    //fetching the user from the database so we can couple the post photo to the user
    func fetchUser(uid: String,completed: @escaping () -> Void){
        API.User.observeUser(withId: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
    
    //getting the sender that sent before the segue has began
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Activity_DetailSegue"{
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
        
    }
}
extension ActivityViewController: UITableViewDataSource{
    //seting the amount of cells we want to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    //set the cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        return cell
    }
}
extension ActivityViewController: ActivityTableViewCellDelegate{
    func goToDetailVC(postId: String) {
        performSegue(withIdentifier: "Activity_DetailSegue", sender: postId)
    }
    
    
}
