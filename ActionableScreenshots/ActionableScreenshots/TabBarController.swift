//
//  TabBarController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 11/30/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            let view = viewController as! AllScreenshotsViewController
            view.searchBar.text = ""
        }
    }

}
