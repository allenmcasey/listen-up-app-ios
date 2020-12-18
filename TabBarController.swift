//
//  TabBarController.swift
//  ListenUpPOC
//
//  Created by Allen Casey on 11/24/20.
//  Copyright © 2020 Allen Casey. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Adjust color of tab bar items
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
}
