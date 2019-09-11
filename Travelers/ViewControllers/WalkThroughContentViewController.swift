//
//  WalkThroughContentViewController.swift
//  Travelers
//
//  Created by admin on 11/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class WalkThroughContentViewController: UIViewController {

    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    var index = 0
    var imageFileName = ""
    var content = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentLabel.text = content
        backgroundImg.image = UIImage(named: imageFileName)
        pageControl.currentPage = index
        switch index {
        case 0...1:
            forwardButton.setImage(UIImage(named: "arrow.png"), for: UIControl.State.normal)
        case 2:
             forwardButton.setImage(UIImage(named: "doneIcon.png"), for: UIControl.State.normal)
        default:
            break
        }
    }
    
    @IBAction func nextButton_TouchUpInside(_ sender: Any) {
        switch index {
        case 0...1:
            let pageVC = parent as! WalkThroughViewController
            pageVC.forward(index: index)
        case 2:
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkThrough")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
        
    }
    
}
