//
//  CampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import CloudKit

class CampaignViewController: UIViewController {
    @IBAction func resetToDefaults(_ sender: Any) {
        dataModel?.resetAll()
        // Implement undo function on timer here?
        dataModel?.saveScenarios()
    }
    
    @IBAction func saveState(_ sender: Any) {
        dataModel?.saveScenarios()
        dataModel?.updateAchievementsStatusRecords(achievementsToUpdate: (dataModel?.achievements)!)
        dataModel?.updateScenarioStatusRecords(scenarios: (dataModel?.allScenarios)!)
    }
    @IBAction func openScenarioManagerButtonTapped(_ sender: Any) {
        showScenarioViewController()
    }
    var dataModel: DataModel? {
        didSet {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel?.delegate = self
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowScenarioManager" {
            let destinationVC = segue.destination as! ScenarioViewController
            let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
            destinationVC.viewModel = viewModel
        }
    }
    // MARK: Private
    
    fileprivate func showScenarioViewController() {
        if !self.isViewLoaded {
            return
        }
 
        let controller = UIStoryboard.loadScenarioViewController()
        let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
        controller.viewModel = viewModel
        
    }
}

// MARK: - DataModelDelegate
extension CampaignViewController: DataModelDelegate {
    func errorUpdating(error: CKError, type: myCKErrorType) {
        print("Got to errorUpdating function")
        let message: String
        if error.code == CKError.notAuthenticated {
            message = "Authentication Error: Log your device into iCloud and enable iCloud for the CampaignManager app."
        } else {
            message = error.localizedDescription
        }
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
