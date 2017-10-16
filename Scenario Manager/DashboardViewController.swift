//
//  DashboardViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import CloudKit

//class DashboardViewController: UIViewController, CreateCampaignViewControllerDelegate, DeleteCampaignViewControllerDelegate {
class DashboardViewController: UIViewController, DeleteCampaignViewControllerDelegate {

    var progressHUD: ProgressHUD!
    
    @IBAction func resetToDefaults(_ sender: Any) {
        confirmDataModelReset()
    }
    @IBAction func loadCampaign(_ sender: Any) {
        viewModel?.addDonation()
        //viewModel?.updateAvailableScenarios()
    }
    
    @IBAction func printCampaigns(_ sender: Any) {
//        dataModel?.loadCampaign(campaign: "ThunderDays")
        viewModel?.decreaseProsperityCount()
        viewModel?.updateAvailableScenarios()
    }
//    @IBAction func displayCreateOptions(_ sender: Any) {
//        displayCreateOptions()
//    }
    @IBAction func displayDeleteOptions(_ sender: Any) {
        displayDeleteOptions()
    }
    @IBAction func saveState(_ sender: Any) {
        dataModel?.saveCampaignsLocally()
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.black
            self.dataModel?.updateCampaignRecords()
        }
        
    }
    @IBAction func printParties(_ sender: Any) {
        viewModel?.increaseProsperityCount()
    }
    
    var dataModel: DataModel? {
        didSet {
        }
    }
    var viewModel: ScenarioViewModelFromModel? {
        didSet {
            
        }
    }
    var colorDefinitions = ColorDefinitions()

    override func viewDidLoad() {
        //Activity Indicator View
        //Create and add the view to the screen.
        progressHUD = ProgressHUD(text: "Updating")
        self.view.addSubview(progressHUD)
        progressHUD.hide()
        super.viewDidLoad()
        
        
        dataModel?.delegate = self
        self.navigationItem.title = "Dashboard"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
    }
    
    // Delegate methods for DeleteCamaignViewController
    func deleteCampaignViewControllerDidCancel(_ controller: DeleteCampaignViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    func deleteCampaignViewControllerDidFinishDeleting(_ controller: DeleteCampaignViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowScenarioManager" {
//            let destinationVC = segue.destination as! ScenarioViewController
//            let viewModel = ScenarioViewModelFromModel(withDataModel: dataModel!)
//            destinationVC.viewModel = viewModel
//        }
//    }
    // MARK: Private
    fileprivate func confirmDataModelReset () {
        let alertController = UIAlertController(title: "Reset Scenario status to default?", message: "Clicking OK will set Scenario status back to initial state, both locally and in iCloud (if available).", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Reset", style: .default) { (action:UIAlertAction!) in
            self.dataModel?.resetCurrentCampaign()
            self.dataModel?.saveCampaignsLocally()
            self.dataModel?.updateCampaignRecords()
            //self.viewModel?.updateAvailableScenarios()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    fileprivate func displayCreateOptions() {
        let campaignOptionsActionsSheetController = UIAlertController(title: "Select", message: "Choose one option", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        campaignOptionsActionsSheetController.addAction(cancelActionButton)
//        let createCampaignAction = UIAlertAction(title: "Add Campaign", style: .default) { action -> Void in
//            self.loadCreateCampaignViewController()
//        }
//        campaignOptionsActionsSheetController.addAction(createCampaignAction)
        let addCharacterAction = UIAlertAction(title: "Add Character", style: .default) { action -> Void in
        }
        campaignOptionsActionsSheetController.addAction(addCharacterAction)
        self.present(campaignOptionsActionsSheetController, animated: true, completion: nil)
    }
    fileprivate func displayDeleteOptions() {
        let campaignOptionsActionsSheetController = UIAlertController(title: "Select", message: "Choose one option", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        campaignOptionsActionsSheetController.addAction(cancelActionButton)
        let deleteCampaignAction = UIAlertAction(title: "Delete Campaign", style: .default) { action -> Void in
            //self.loadDeleteCampaignViewController()
        }
        campaignOptionsActionsSheetController.addAction(deleteCampaignAction)
        let deleteCharacterAction = UIAlertAction(title: "Delete Character", style: .default) { action -> Void in
        }
        campaignOptionsActionsSheetController.addAction(deleteCharacterAction)
        self.present(campaignOptionsActionsSheetController, animated: true, completion: nil)
    }
//    fileprivate func loadCreateCampaignViewController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "createCampaignViewController") as! CreateCampaignViewController
//        createCampaignVC.delegate = self
//        createCampaignVC.viewModel = CreateCampaignViewModelFromModel(withDataModel: dataModel!)
//        createCampaignVC.hidesBottomBarWhenPushed = true
//        self.navigationController!.pushViewController(createCampaignVC, animated: true)
//    }
//    fileprivate func loadDeleteCampaignViewController() {
//        if dataModel?.campaigns.count == 1 {
//            showErrorAlert(errorMessage: "Cannot delete only remaining campaign!")
//        } else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let deleteCampaignVC = storyboard.instantiateViewController(withIdentifier: "deleteCampaignViewController") as! DeleteCampaignViewController
//            deleteCampaignVC.delegate = self
//            deleteCampaignVC.viewModel = DeleteCampaignViewModelFromModel(withDataModel: dataModel!)
//            deleteCampaignVC.hidesBottomBarWhenPushed = true
//            self.navigationController!.pushViewController(deleteCampaignVC, animated: true)
//        }
//    }
}

// MARK: - DataModelDelegate
extension DashboardViewController: DataModelDelegate {
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
    func showErrorAlert(errorMessage: String) {
        let message = errorMessage
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    func showProgressHUD() {
        progressHUD.show()
    }
    func hideProgressHUD() {
        progressHUD.hide()
    }
    func darkenViewBGColor() {
        view.backgroundColor = UIColor.darkGray
    }
    func restoreViewBGColor() {
        view.backgroundColor = UIColor.white
    }
}
