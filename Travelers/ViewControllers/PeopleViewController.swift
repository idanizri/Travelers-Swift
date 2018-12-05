//
//  PeopleViewController.swift
//  Travelers
//
//  Created by admin on 05/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 81
        
        tableView.rowHeight = UITableView.automaticDimension
        
        loadUsers()
    }
    
    func loadUsers(){
        API.User.observeUsers { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void){
        API.Follow.isFollowing(userId: userId, completed: completed)
    }

}
extension PeopleViewController: UITableViewDataSource {
    //seting the amount of cells we want to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    //set the cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }
    
    
}
