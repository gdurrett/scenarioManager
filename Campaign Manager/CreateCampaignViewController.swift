//
//  CreateCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import SwiftyDropbox

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
    
    // Set from appDelegate first time load
    var isFirstLoad: Bool?
    
    var newCampaignTitle: String?
    var selectedParties: [String]?
    var currentCharacter: Character?
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test Dropbox auth right out of the gate
        //authenticateToDropBox()
        
        viewModel!.reloadSection = { [weak self] (section: Int) in
            self?.createCampaignTableView.reloadData()
        }
        
        // Register cells
        createCampaignTableView.register(CreateCampaignTitleCell.nib, forCellReuseIdentifier: CreateCampaignTitleCell.identifier)
        createCampaignTableView.register(CreateCampaignPartyCell.nib, forCellReuseIdentifier: CreateCampaignPartyCell.identifier)
        createCampaignTableView.register(CreateCampaignCharacterCell.nib, forCellReuseIdentifier: CreateCampaignCharacterCell.identifier)
        
        createCampaignTableView.delegate = viewModel
        createCampaignTableView.dataSource = viewModel
        
        styleUI()
        
        if isFirstLoad == true {
            self.navigationItem.leftBarButtonItem = nil
        }
        
    }


    // Dropbox test
    fileprivate func authenticateToDropBox() {
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        } else {
            if let client = DropboxClientsManager.authorizedClient {
                client.files.listFolder(path: "").response {
                    response, error in
                    if let result = response {
                        print("Folder Contents:")
                        for entry in result.entries {
                            if entry.name == "Campaigns.plist" {
                                print("Found a save file!")
                                let destination: (URL, HTTPURLResponse) -> URL = { tempURL, response in
                                    return self.viewModel!.dataFilePath
                                }
                                client.files.download(path: "/Campaigns.plist", overwrite: true, destination: destination)
                                    .response { response, error in
                                        if let response = response {
                                            print(response)
                                            self.performSegue(withIdentifier: "showTabBarVC", sender: self)
                                        } else if let error = error {
                                            print(error)
                                        }
                                }
                            }
                        }
                    } else if let error = error {
                        print(error)
                    }
                }
                print("Did get a client though.")
            }
            print("Client isn't nil?")
        }
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
        } else if segue.identifier == "showTabBarVC" {
            let scenarioViewModel = ScenarioViewModelFromModel(withDataModel: self.viewModel!.dataModel)
            
            let campaignDetailViewModel = CampaignDetailViewModel(withCampaign: self.viewModel!.dataModel.currentCampaign)
            let partyDetailViewModel = PartyDetailViewModel(withParty: self.viewModel!.dataModel.currentParty)
            // Set to first character that matches current party assignment
            let currentPartyCharacters = self.viewModel!.dataModel.characters.values.filter { $0.assignedTo == self.viewModel!.dataModel.currentParty.name }.isEmpty ? Array(self.viewModel!.dataModel.characters.values) : self.viewModel!.dataModel.characters.values.filter { $0.assignedTo == self.viewModel!.dataModel.currentParty.name }
            
            let characterDetailViewModel = CharacterDetailViewModel(withCharacter: currentPartyCharacters.first!)
            let tabBarController = segue.destination as! CampaignManagerTabBarController
            let navController1 = tabBarController.viewControllers?[1] as! UINavigationController
            let controller1 = navController1.viewControllers[0] as! PartyDetailViewController
            controller1.viewModel = partyDetailViewModel
            controller1.delegate = partyDetailViewModel
            controller1.pickerDelegate = partyDetailViewModel
            
            // Set up Campaign Detail view controller
            let navController2 = tabBarController.viewControllers?[0] as? UINavigationController
            let controller2 = navController2?.viewControllers[0] as! CampaignDetailViewController
            controller2.viewModel = campaignDetailViewModel
            controller2.delegate = campaignDetailViewModel
            // See if we can set reload
            campaignDetailViewModel.partyReloadDelegate = controller1
            
            
            // Set up Character Detail view controller
            let navController3 = tabBarController.viewControllers?[2] as? UINavigationController
            let controller3 = navController3?.viewControllers[0] as! SelectCharacterViewController
            controller3.viewModel = characterDetailViewModel
            controller3.actionDelegate = characterDetailViewModel
            //controller3.delegate = characterDetailViewModel
            
            // Set up Scenario view controller
            let navController4 = tabBarController.viewControllers?[3] as? UINavigationController
            let controller4 = navController4?.viewControllers[0] as! ScenarioViewController
            controller4.viewModel = scenarioViewModel
        }
    }
    func showFormAlert(alertText: String, message: String) {
        let alertView = UIAlertController(
            title: alertText,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
}
