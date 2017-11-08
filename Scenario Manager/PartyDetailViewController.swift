//
//  PartyDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/22/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol PartyDetailViewControllerDelegate: class {
    func partyDetailVCDidTapDelete(_ controller: PartyDetailViewController)
}
class PartyDetailViewController: UIViewController {

    @IBOutlet weak var partyDetailTableView: UITableView!
    
    @IBAction func selectPartyAction(_ sender: Any) {
        loadSelectPartyViewController()
    }
    
    @IBAction func deletePartyAction(_ sender: Any) {
        showConfirmDeletionAlert()
    }
    
    @IBAction func createPartyAction(_ sender: Any) {
        loadCreatePartyViewController()
    }
    
    weak var delegate: PartyDetailViewControllerDelegate!
    
    var viewModel: PartyDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadSelectPartyCharactersViewController), name: NSNotification.Name(rawValue: "showSelectCharacterVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNoCharactersAlert), name: NSNotification.Name(rawValue: "showNoCharactersAlert"), object: nil)
        // Set up UITableViewDelegate
        partyDetailTableView?.dataSource = viewModel
        partyDetailTableView?.delegate = viewModel
        
        // Register cells
        partyDetailTableView?.register(PartyDetailNameCell.nib, forCellReuseIdentifier: PartyDetailNameCell.identifier)
        partyDetailTableView?.register(PartyDetailReputationCell.nib, forCellReuseIdentifier: PartyDetailReputationCell.identifier)
        partyDetailTableView?.register(PartyDetailAssignedCampaignCell.nib, forCellReuseIdentifier: PartyDetailAssignedCampaignCell.identifier)
        partyDetailTableView?.register(PartyDetailAssignedCharactersCell.nib, forCellReuseIdentifier: PartyDetailAssignedCharactersCell.identifier)
        partyDetailTableView?.register(PartyDetailAchievementsCell.nib, forCellReuseIdentifier: PartyDetailAchievementsCell.identifier)
        
        // Register headers
        partyDetailTableView?.register(PartyDetailAssignedCampaignHeader.nib, forCellReuseIdentifier: PartyDetailAssignedCampaignHeader.identifier)
        styleUI()
    }
    
    // MARK: Helper methods
    func updateAllSections() {
        viewModel.updateCurrentPartyName()
        viewModel.updateAssignedCampaign()
        viewModel.updateReputationValue()
        viewModel.updateAchievements()
        viewModel.updateCharacters()
        viewModel.updateAssignedCharacters()
        viewModel.updateAvailableCharacters()
        viewModel.updateAssignedParties()
        viewModel.updateCurrentParty()
    }
    func refreshAllSections() {
        self.partyDetailTableView.reloadData()
    }
    //MARK: Action Methods
    fileprivate func loadSelectPartyViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectPartyVC = storyboard.instantiateViewController(withIdentifier: "SelectPartyViewController") as! SelectPartyViewController
        selectPartyVC.delegate = viewModel
        // Give VC the current campaign so it can set checkmark.
        viewModel.updateAssignedParties()
        viewModel.updateCurrentParty()
        selectPartyVC.assignedParties = viewModel.assignedParties.value!
        selectPartyVC.viewModel = self.viewModel
        //selectCampaignVC.reloadDelegate = self // Need to reloadData on entire table before returning here!
        selectPartyVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(selectPartyVC, animated: true, completion: nil)
    }
    // Called when pressing delete button
    fileprivate func showConfirmDeletionAlert () {
        let alertController = UIAlertController(title: "Delete current party?", message: "Clicking OK will delete the current party.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
            self.delegate.partyDetailVCDidTapDelete(self)
            self.updateAllSections()
            self.refreshAllSections()
            //self.updateNavTitle()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    // Called by PartyDetailViewModel delegate method
    func showDisallowDeletionAlert() {
        let alertTitle = "Cannot delete only party!"
        let alertView = UIAlertController(
            title: alertTitle,
            message: "Create a new party before deleting this one.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
}
extension PartyDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let item = viewModel.items[indexPath!.section]
        switch item.type {
        case .partyName:
            break
        case .reputation:
            break
        case .assignedCampaign:
            break
        case .characters:
            break
        case .achievements:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Call updates and refreshes here
        viewModel.updateCurrentPartyName()
        viewModel.updateReputationValue()
        viewModel.updateAssignedCampaign()
        viewModel.updateAssignedCharacters()
        viewModel.updateAchievements()

        self.partyDetailTableView.reloadData()
        
        // Test scroll to top
        self.partyDetailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    func refreshCurrentParty() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([0], with: .none)
        }
    }
    func refreshReputation() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([1], with: .none)
        }
    }
    func refreshAssignedCharacters() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([3], with: .none)
        }
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([4], with: .none)
        }
    }
    fileprivate func styleUI() {
        self.partyDetailTableView.estimatedRowHeight = 80
        self.partyDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationItem.title = "Current Party"
        self.partyDetailTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.partyDetailTableView.backgroundView?.alpha = 0.25
        self.partyDetailTableView.separatorInset = .zero
    }
    // MARK: Action Methods
    @objc func loadSelectPartyCharactersViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCharacterVC = storyboard.instantiateViewController(withIdentifier: "SelectPartyCharactersViewController") as! SelectPartyCharactersViewController
        selectCharacterVC.delegate = viewModel
        selectCharacterVC.viewModel = viewModel
        selectCharacterVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(selectCharacterVC, animated: true, completion: nil)
    }
    fileprivate func loadCreatePartyViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createPartyVC = storyboard.instantiateViewController(withIdentifier: "CreatePartyViewController") as! CreatePartyViewController
        createPartyVC.viewModel = CreatePartyViewModel(withDataModel: viewModel!.dataModel)
        createPartyVC.delegate = createPartyVC.viewModel
        createPartyVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(createPartyVC, animated: true, completion: nil)
    }
    @objc fileprivate func showNoCharactersAlert() {
        let alertController = UIAlertController(title: "There are no available characters!", message: "Create new characters on the Characters tab, or unassign characters from another party.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
}
extension PartyDetailViewController: CampaignDetailPartyUpdaterDelegate {
    func reloadTableAfterSetPartyCurrent() {
        if let myTableView = self.partyDetailTableView {
            myTableView.reloadData()
        }
    }
}
extension PartyDetailViewController: SelectPartyCharactersViewControllerReloadDelegate {
    func reloadAfterDidFinishSelecting() {
        if let myTableView = self.partyDetailTableView {
            //self.viewModel.updateAssignedCharacters()
            myTableView.reloadData()
        }
    }
}
