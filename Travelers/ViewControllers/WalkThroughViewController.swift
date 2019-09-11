//
//  WalkThroughViewController.swift
//  Travelers
//
//  Created by admin on 11/12/2018.
//  Copyright © 2018 IdanOmer. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageContent = ["Your Travel App",
                       "You can share your travel online and watch others",
                       "Enjoy!"]
    var pageImage = ["background1","background2","background3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        if let statingVC = viewControllerAtIndex(index: 0){
            setViewControllers([statingVC], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkThroughContentViewController).index
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkThroughContentViewController).index
        index += 1
        return viewControllerAtIndex(index: index)
        
    }
    
    func viewControllerAtIndex(index: Int) -> WalkThroughContentViewController?{
        if index < 0 || index >= pageContent.count {
            return nil
        }
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkThroughContentViewController") as? WalkThroughContentViewController{
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            return pageContentVC
        }
        return nil
    }
    
    func forward(index: Int){
        if let nextVC = viewControllerAtIndex(index: index + 1){
            setViewControllers([nextVC], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
    }
}
