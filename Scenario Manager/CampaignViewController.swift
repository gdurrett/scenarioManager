//
//  CampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignViewController: UIViewController {
    
    var dataModel: DataModel? {
        didSet {
            showScenarioViewController()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showScenarioViewController()
        
    }
    
    // MARK: Private
    
    fileprivate func showScenarioViewController() {
        if !self.isViewLoaded {
            return
        }
 
        let controller = UIStoryboard.loadScenarioViewController()
        let viewModel = ScenarioViewModelFromModel(withDataModel: DataModel.sharedInstance)
        controller.viewModel = viewModel
        
        self.insertChildController(controller, intoParentView: self.view)
        
    }
}
