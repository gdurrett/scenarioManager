//
//  CreateCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreateCampaignViewControllerDelegate: class {
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController)
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController)
}
// Test Test!
protocol CreateCampaignViewControllerReloadDelegate: class {
    func reloadAfterDidFinishAdding()
}
class CreateCampaignViewController: UIViewController {
    
    //@IBOutlet weak var createCampaignTableView: UITableView!
    
    @IBOutlet var createCampaignView: UIView!
    
    @IBOutlet weak var createCampaignCampaignNameTextField: UITextField!
    
    @IBOutlet weak var createCampaignPartyNameTextField: UITextField!
    
    @IBOutlet weak var createCampaignCharacter1NameTextField: UITextField!
    
    @IBOutlet weak var createCampaignCharacter2NameTextField: UITextField!
    
    @IBOutlet weak var createCampaignCharacter3NameTextField: UITextField!
    
    @IBOutlet weak var createCampaignCharacter4NameTextField: UITextField!
    
    @IBAction func save(_ sender: Any) {
        if createCampaignCampaignNameTextField.text != "" && createCampaignPartyNameTextField.text != "" && createCampaignCharacter1NameTextField.text != "" {
            delegate?.createCampaignViewControllerDidFinishAdding(self)
            // Test Test!
            reloadDelegate?.reloadAfterDidFinishAdding()
        } else {
            print("Fill all required fields!")
        }
    }
    @IBAction func cancel(_ sender: Any) {
         delegate?.createCampaignViewControllerDidCancel(self)
    }
    
    var viewModel: CreateCampaignViewModelFromModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreateCampaignViewControllerDelegate?
    // Test Test!
    weak var reloadDelegate: CreateCampaignViewControllerReloadDelegate?
    
    var newCampaignTitle: String?
    var selectedParties: [String]?
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        
    }

    // Helper methods
    fileprivate func styleUI() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "campaignDetailTableViewBG")
        backgroundImage.alpha = 0.25
        self.createCampaignView.insertSubview(backgroundImage, at: 0)
        self.createCampaignView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        //self.createCampaignView.backgroundView?.alpha = 0.25
    }
}
