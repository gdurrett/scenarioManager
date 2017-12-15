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
protocol EventAchievementsPickerDelegate: class {
    func setEventAchievement()
    var eventAchievementsPickerDidPick: Bool { get set }
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
    weak var pickerDelegate: EventAchievementsPickerDelegate?
    
    var viewModel: PartyDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()

    // For eventAchievements Picker
    var eventAchievementsPicker = UIPickerView()
    var eventAchievementsPickerData = [String]()
    var eventAchievementsPickerInputView = UIView()
    var eventAchievementsPickerDummyTextField = UITextField()
    var selectedAchievement: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.reloadSection = { [weak self] (section: Int) in
            self?.partyDetailTableView.reloadData()
        }
        // Set up observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNoCharactersAlert), name: NSNotification.Name(rawValue: "showNoCharactersAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEventAchievementsPicker), name: NSNotification.Name(rawValue: "showEventAchievementsPicker"), object: nil)
        // Listener for when we complete an event-based achievement - called from PartyDetailVM
        NotificationCenter.default.addObserver(self, selector: #selector(showUnlockScenarioAlert), name: NSNotification.Name(rawValue: "showUnlockScenarioAlert"), object: nil)
        // Set up UITableViewDelegate
        partyDetailTableView?.dataSource = viewModel
        partyDetailTableView?.delegate = viewModel
        
        eventAchievementsPicker.dataSource = viewModel
        eventAchievementsPicker.delegate = viewModel
        
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
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.hideAllControls()
        eventAchievementsPickerDidTapCancel()
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
        viewModel.updateCharacters()
        viewModel.updateAssignedAndActiveCharacters() //Try here?
        
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
    fileprivate func loadCreatePartyViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createPartyVC = storyboard.instantiateViewController(withIdentifier: "CreatePartyViewController") as! CreatePartyViewController
        let navCon = UINavigationController(rootViewController: createPartyVC)
        let createPartyVCViewModel = CreatePartyViewModel(withDataModel: viewModel!.dataModel)
        createPartyVC.viewModel = createPartyVCViewModel
        createPartyVC.delegate = createPartyVCViewModel
        createPartyVC.hidesBottomBarWhenPushed = true
        self.present(navCon, animated: true, completion: nil)
    }
    @objc fileprivate func showNoCharactersAlert() {
        let alertController = UIAlertController(title: "There are no available characters!", message: "Create new characters on the Characters tab, or unassign characters from another party.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    // Called via notification
    @objc func showEventAchievementsPicker() {
        eventAchievementsPicker.tag = 10
        eventAchievementsPicker.layer.cornerRadius = 10
        eventAchievementsPicker.layer.masksToBounds = true
        eventAchievementsPicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        eventAchievementsPicker.showsSelectionIndicator = true
        
        // Try to set up toolbar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setEventAchievement))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(eventAchievementsPickerDidTapCancel))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        eventAchievementsPicker.reloadAllComponents()
        eventAchievementsPicker.addSubview(toolBar)
        eventAchievementsPickerInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: eventAchievementsPicker.frame.size.height + 44))
        eventAchievementsPicker.frame = CGRect(x: 0, y: 0, width: eventAchievementsPickerInputView.frame.width, height: 200)
        eventAchievementsPicker.selectRow(0, inComponent: 0, animated: true) // Set to first row
        pickerDelegate?.eventAchievementsPickerDidPick = false // Reset this after initial selection setting
        eventAchievementsPickerInputView.addSubview(eventAchievementsPicker)
        eventAchievementsPickerInputView.addSubview(toolBar)
        eventAchievementsPickerDummyTextField.inputView = eventAchievementsPickerInputView
        eventAchievementsPickerDummyTextField.isHidden = true
        self.view.addSubview(eventAchievementsPickerDummyTextField)
        self.view.addSubview(eventAchievementsPickerInputView)
    }
    @objc func setEventAchievement() {
        // Call to delegate to set event
        pickerDelegate!.setEventAchievement()
        self.eventAchievementsPickerInputView.removeFromSuperview()
        self.eventAchievementsPicker.removeFromSuperview()
        eventAchievementsPickerData.removeAll()
    }
    @objc func eventAchievementsPickerDidTapCancel() {
        self.eventAchievementsPickerInputView.removeFromSuperview()
        self.eventAchievementsPicker.removeFromSuperview()
        eventAchievementsPickerData.removeAll()
    }
    @objc func showUnlockScenarioAlert(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTitle = dict["Scenario"] as! String
            let alertTitle = "Scenario unlocked!"
            let alertView = UIAlertController(
                title: alertTitle,
                message: "You may now unlock '\(scenarioTitle)' from All Scenarios in the Scenarios tab.",
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
            alertView.addAction(action)
            present(alertView, animated: true, completion: nil)
        }
    }
}
extension PartyDetailViewController: CampaignDetailPartyUpdaterDelegate {
    func reloadTableAfterSetPartyCurrent() {
        if let myTableView = self.partyDetailTableView {
            myTableView.reloadData()
        }
    }
}
