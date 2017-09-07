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
        confirmDataModelReset()
    }
    @IBAction func loadCampaign(_ sender: Any) {
        dataModel?.loadCampaign(campaign: "Default")
        viewModel?.updateAvailableScenarios()
    }
    @IBAction func addCampaign(_ sender: Any) {
        createCampaign()
        viewModel?.updateAvailableScenarios()
    }
    
    @IBAction func printAchievements(_ sender: Any) {
        print("Unlocks for \(viewModel?.campaign.value.isUnlocked.minimalDescription)")
    }
    @IBAction func saveState(_ sender: Any) {
        dataModel?.saveCampaignsLocally()
        dataModel?.updateCampaignRecords()
//        dataModel?.updateAchievementsStatusRecords(achievementsToUpdate: (dataModel?.achievements)!)
//        dataModel?.updateScenarioStatusRecords(scenarios: (dataModel?.allScenarios)!)
    }
    var dataModel: DataModel? {
        didSet {
        }
    }
    var viewModel: ScenarioViewModelFromModel? {
        didSet {
            
        }
    }
    var mainTextColor = UIColor(hue: 30/360, saturation: 45/100, brightness: 25/100, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel?.delegate = self
        self.navigationItem.title = "Dashboard"
        self.navigationController?.navigationBar.titleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 26.0, textColor: mainTextColor)
        
    }
    // Test create campaign and add to dataModel
    func createCampaign() {
        let newCampaign = "Donkler"
        //dataModel?.addCampaign(campaign: newCampaign)
        dataModel?.loadCampaign(campaign: newCampaign)
    }

    // Farm this out to separate object
    func setTextAttributes(fontName: String, fontSize: CGFloat, textColor: UIColor) -> [ String : Any ] {
        let fontStyle = UIFont(name: fontName, size: fontSize)
        let fontColor = textColor
        return [ NSFontAttributeName : fontStyle! , NSForegroundColorAttributeName : fontColor ]
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowScenarioManager" {
//            let destinationVC = segue.destination as! ScenarioViewController
//            let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
//            destinationVC.viewModel = viewModel
//        }
//    }
    // MARK: Private
//    
//    fileprivate func showScenarioViewController() {
//        if !self.isViewLoaded {
//            return
//        }
// 
//        let controller = UIStoryboard.loadScenarioViewController()
//        let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
//        controller.viewModel = viewModel
//        
//    }
    fileprivate func confirmDataModelReset () {
        let alertController = UIAlertController(title: "Reset Scenario status to default?", message: "Clicking OK will set Scenario status back to initial state, both locally and in iCloud (if available).", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Reset", style: .default) { (action:UIAlertAction!) in
            self.dataModel?.resetAll()
            self.dataModel?.saveCampaignsLocally()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
}

// MARK: - DataModelDelegate
extension CampaignViewController: DataModelDelegate {
    func errorUpdating(error: CKError, type: myCKErrorType) {
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
