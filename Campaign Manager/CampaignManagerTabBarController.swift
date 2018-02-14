//
//  CampaignManagerTabBarController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import SwiftyDropbox

class CampaignManagerTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorDefinitions = ColorDefinitions()
        let allTabBarItems = tabBar.items
        
        let campaignsItem = allTabBarItems?[0]
        let partiesItem = allTabBarItems?[1]
        let charactersItem = allTabBarItems?[2]
        let scenariosItem = allTabBarItems?[3]
        
        campaignsItem?.image = UIImage(named: "icons8-parchment-filled-40.png")
        campaignsItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        campaignsItem?.title = "Campaign"
        
        partiesItem?.image = UIImage(named: "icons8-people-40.png")
        partiesItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        partiesItem?.title = "Party"
        
        charactersItem?.image = UIImage(named: "icons8-footman-filled-40.png")
        charactersItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        charactersItem?.title = "Characters"
        
        scenariosItem?.image = UIImage(named: "icons8-adventure-filled-40.png")
        scenariosItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        scenariosItem?.title = "Scenarios"

        tabBar.unselectedItemTintColor = colorDefinitions.tabBarUnselectedItemTintColor
        tabBar.tintColor = colorDefinitions.tabBarTintColor
        tabBar.barTintColor = colorDefinitions.tabBarBarTintColor

    }

}
