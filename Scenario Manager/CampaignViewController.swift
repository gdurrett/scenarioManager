//
//  CampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import CloudKit

class CampaignViewController: UIViewController, AddCampaignViewControllerDelegate {
    var progressHUD: ProgressHUD!
    
    @IBAction func resetToDefaults(_ sender: Any) {
        confirmDataModelReset()
    }
    @IBAction func loadCampaign(_ sender: Any) {
        dataModel?.loadCampaign(campaign: "Default")
        viewModel?.updateAvailableScenarios()
    }
    
    @IBAction func addCampaign(_ sender: Any) {
        //loadAddCampaignViewController()
        displayCampaignOptions()
    }
    @IBAction func saveState(_ sender: Any) {
        dataModel?.saveCampaignsLocally()
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor.black
            self.dataModel?.updateCampaignRecords()
        }
        
    }
    var dataModel: DataModel? {
        didSet {
        }
    }
    var viewModel: ScenarioViewModelFromModel? {
        didSet {
            
        }
    }
    //var addCampaignViewController = AddCampaignViewController()
    var colorDefinitions = ColorDefinitions()

    
//    let rightButtonItem = UIBarButtonItem(
//        barButtonSystemItem: .add,
//        target: self,
//        action: #selector(loadAddCampaignViewController)
//    )
    override func viewDidLoad() {
        //Activity Indicator View
        //Create and add the view to the screen.
        progressHUD = ProgressHUD(text: "Updating")
        self.view.addSubview(progressHUD)
        progressHUD.hide()
        super.viewDidLoad()
        
        
        dataModel?.delegate = self
        self.navigationItem.title = "Dashboard"
        self.navigationController?.navigationBar.titleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 26.0, textColor: colorDefinitions.mainTextColor)
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
    // Delegate methods for AddCampaignViewController
    func addCampaignViewControllerDidCancel(_ controller: AddCampaignViewController) {
        print("Did we get back here to cancel?")
        controller.navigationController?.popViewController(animated: true)
    }
    func addCampaignViewControllerDidFinishAdding(_ controller: AddCampaignViewController) {
        //
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
    fileprivate func loadAddCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addCampaignVC = storyboard.instantiateViewController(withIdentifier: "addCampaignViewController") as! AddCampaignViewController
        addCampaignVC.delegate = self
        addCampaignVC.viewModel = AddCampaignViewModelFromModel(withDataModel: dataModel!)
        addCampaignVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(addCampaignVC, animated: true)
        //self.present(addCampaignVC, animated: true, completion: nil)
    }
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
    fileprivate func displayCampaignOptions() {
        //let attributedTitleForAddCharacter = NSAttributedString(string:
        let campaignOptionsActionsSheetController = UIAlertController(title: "Select", message: "Choose one option", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        campaignOptionsActionsSheetController.addAction(cancelActionButton)
        let addCampaignAction = UIAlertAction(title: "Add Campaign", style: .default) { action -> Void in
            self.loadAddCampaignViewController()
        }
        campaignOptionsActionsSheetController.addAction(addCampaignAction)
        let addCharacterAction = UIAlertAction(title: "Add Character", style: .default) { action -> Void in
            //self.loadAddCharacterViewController()
        }
        campaignOptionsActionsSheetController.addAction(addCharacterAction)
        //campaignOptionsActionsSheetController.setValue(attributedTitle, forKey: )
        self.present(campaignOptionsActionsSheetController, animated: true, completion: nil)
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
