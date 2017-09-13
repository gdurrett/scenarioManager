//
//  UIStoryboard+Loader.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

fileprivate enum Storyboard : String {
    case main = "Main"
}

fileprivate extension UIStoryboard {
    
    static func loadFromMain(_ identifier: String) -> UIViewController {
        return load(from: .main, identifier: identifier)
    }
    // add convenience methods for other storyboards here ...
    
    // ... or use the main loading method directly when instantiating view controller
    // from a specific storyboard
    static func load(from storyboard: Storyboard, identifier: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        return uiStoryboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: App View Controllers

extension UIStoryboard {
    static func loadScenarioViewController() -> ScenarioViewController {
        return loadFromMain("ScenarioViewController") as! ScenarioViewController
    }
    static func loadCampaignViewController() -> DashboardViewController {
        return loadFromMain("DashboardViewController") as! DashboardViewController
    }
    static func loadCampaignTabBarController() -> CampaignManagerTabBarController {
        return loadFromMain("CampaignManagerTabBarController") as! CampaignManagerTabBarController
    }
    static func loadCreateCampaignViewController() -> CreateCampaignViewController {
        return loadFromMain("CreateCampaignViewController") as! CreateCampaignViewController
    }
}
