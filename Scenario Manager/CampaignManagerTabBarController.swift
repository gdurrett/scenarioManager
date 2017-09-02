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
        
        let tabBarTitleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 10.0, textColor: UIColor(hue: 30/360, saturation: 45/100, brightness: 25/100, alpha: 1.0))
        let allTabBarItems = tabBar.items
        
        let dashboardItem = allTabBarItems?[0]
        let scenariosItem = allTabBarItems?[1]
        
        dashboardItem?.image = UIImage(named: "spikyHeadGuy.png")
        dashboardItem?.setTitleTextAttributes(tabBarTitleTextAttributes, for: .selected)
        dashboardItem?.title = "Dashboard"

        scenariosItem?.image = UIImage(named: "cthulhuFace.png")
        scenariosItem?.setTitleTextAttributes(tabBarTitleTextAttributes, for: .selected)
        scenariosItem?.title = "Scenarios"
        
        tabBar.unselectedItemTintColor = UIColor(hue: 40/360, saturation: 6/100, brightness: 65/100, alpha: 1.0)
        tabBar.tintColor = UIColor(hue: 40/360, saturation: 6/100, brightness: 40/100, alpha: 1.0)
        tabBar.barTintColor = UIColor(hue: 40/360, saturation: 6/100, brightness: 100/100, alpha: 1.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setTextAttributes(fontName: String, fontSize: CGFloat, textColor: UIColor) -> [ String : Any ] {
        let fontStyle = UIFont(name: fontName, size: fontSize)
        let fontColor = textColor
        return [ NSFontAttributeName : fontStyle! , NSForegroundColorAttributeName : fontColor ]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

