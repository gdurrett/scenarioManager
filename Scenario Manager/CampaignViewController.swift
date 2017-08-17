//
//  CampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignViewController: UIViewController {
    
    @IBAction func openScenarioManagerButtonTapped(_ sender: Any) {
        showScenarioViewController()
    }
    var dataModel: DataModel? {
        didSet {
            //showScenarioViewController()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //showScenarioViewController()
        
    }
    // MARK: Private
    
    fileprivate func showScenarioViewController() {
        if !self.isViewLoaded {
            return
        }
 
        let controller = UIStoryboard.loadScenarioViewController()
        let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
        controller.viewModel = viewModel
        let navController = UINavigationController(rootViewController: controller)
        //Hide Campaign Manager's nav bar so we can see ScenarioViewController's NavBar
        self.navigationController?.navigationBar.isHidden = true
        self.insertChildController(navController, intoParentView: self.view)
        
        
    }
}
