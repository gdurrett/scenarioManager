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
class CreateCampaignViewController: UIViewController, CreateCampaignViewModelDelegate {
    var selectedCharacter: Character {
        get {
            return currentCharacter!
        }
        set {
            currentCharacter = newValue
        }
    }
    
    
    //@IBOutlet weak var createCampaignTableView: UITableView!
    
    @IBOutlet var createCampaignView: UIView!
    
    @IBOutlet weak var createCampaignTableView: UITableView!

    @IBOutlet weak var createCampaignNameTextField: UITextField!
    
    @IBAction func cancel(_ sender: Any) {
         delegate?.createCampaignViewControllerDidCancel(self)
    }
    @IBAction func save(_ sender: Any) {
        delegate?.createCampaignViewControllerDidFinishAdding(self)
    }
    @IBAction func unwindToCreateCampaignVC(segue: UIStoryboardSegue) {
        self.createCampaignTableView.reloadData()
    }
    var viewModel: CreateCampaignViewModelFromModel? {
        didSet {
            //
            viewModel!.delegate = self
        }
    }
    weak var delegate: CreateCampaignViewControllerDelegate!
    // Test Test!
    weak var reloadDelegate: CreateCampaignViewControllerReloadDelegate?
    
    var newCampaignTitle: String?
    var selectedParties: [String]?
    var currentCharacter: Character?
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cells
        createCampaignTableView.register(CreateCampaignTitleCell.nib, forCellReuseIdentifier: CreateCampaignTitleCell.identifier)
        createCampaignTableView.register(CreateCampaignPartyCell.nib, forCellReuseIdentifier: CreateCampaignPartyCell.identifier)
        createCampaignTableView.register(CreateCampaignCharacterCell.nib, forCellReuseIdentifier: CreateCampaignCharacterCell.identifier)
        
        createCampaignTableView.delegate = viewModel
        createCampaignTableView.dataSource = viewModel
        
        styleUI()
        
    }

    // Helper methods
    fileprivate func styleUI() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "campaignDetailTableViewBG")
        backgroundImage.alpha = 0.25
        self.navigationItem.title = "Create Campaign"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.createCampaignTableView.insertSubview(backgroundImage, at: 0)
        self.createCampaignTableView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createCampaignTableView.backgroundView?.alpha = 0.25
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateCampaignCharacterVC" {
            let destinationVC = segue.destination as! CreateCampaignCharacterViewController
            let destinationVM = CreateCampaignCharacterViewModel(withDataModel: viewModel!.dataModel)
            destinationVC.viewModel = destinationVM
            destinationVC.pickerDelegate = destinationVM as CreateCampaignCharacterPickerDelegate
            destinationVC.delegate = destinationVM
            destinationVM.selectedCharacterRow = self.viewModel!.selectedCharacterRow
        }
    }
}
