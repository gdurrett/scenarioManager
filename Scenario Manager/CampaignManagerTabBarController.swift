//
//  CampaignManagerTabBarController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignManagerTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorDefinitions = ColorDefinitions()
        //let tabBarTitleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 10.0, textColor: colorDefinitions.tabBarTitleTextColor)
        let allTabBarItems = tabBar.items
        
        let dashboardItem = allTabBarItems?[0]
        let campaignsItem = allTabBarItems?[1]
        let scenariosItem = allTabBarItems?[2]

        
        dashboardItem?.image = UIImage(named: "spikyHeadGuy.png")
        dashboardItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        dashboardItem?.title = "Dashboard"
        
        campaignsItem?.image = UIImage(named: "moonSymbol.png")
        campaignsItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        campaignsItem?.title = "Campaigns"
        
        scenariosItem?.image = UIImage(named: "cthulhuFace.png")
        scenariosItem?.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 10.0)!, .foregroundColor: colorDefinitions.tabBarTitleTextColor], for: .selected)
        scenariosItem?.title = "Scenarios"

        tabBar.unselectedItemTintColor = colorDefinitions.tabBarUnselectedItemTintColor
        tabBar.tintColor = colorDefinitions.tabBarTintColor
        tabBar.barTintColor = colorDefinitions.tabBarBarTintColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func setTextAttributes(fontName: String, fontSize: CGFloat, textColor: UIColor) -> [ String : Any ] {
//        let fontStyle = UIFont(name: fontName, size: fontSize)
//        let fontColor = textColor
//        return [ NSFontAttributeName : fontStyle! , NSForegroundColorAttributeName : fontColor ]
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

