//
//  CampaignDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import SwiftyDropbox

protocol CampaignDetailViewControllerDelegate: class {
    func campaignDetailVCDidTapDelete(_ controller: CampaignDetailViewController)
    func toggleSection(section: Int)
    var eventOptionPickerDidPick: Bool { get set }
    func setEventOptionChoice()
    var characterTypePickerDidPick: Bool { get set }
    func setCharacterType()
}

class CampaignDetailViewController: UIViewController {
    @IBOutlet var campaignDetailView: UIView!
    
    @IBAction func exportCampaignAction(_ sender: Any) {
        authenticateToDropBox()
        loadAuthenticationViewController()
//        if let client = DropboxClientsManager.authorizedClient {
//            let alertController = UIAlertController(title: "Load/Save campaign state", message: "Choose an option", preferredStyle: .actionSheet)
//            let saveButton = UIAlertAction(title: "Save campaign to Dropbox", style: .default, handler: {
//                (action) -> () in
//                print("would be saving")
//            })
//            let loadButton = UIAlertAction(title: "Load campaign from Dropbox", style: .default, handler: {
//                (action) -> () in
//                self.downloadCampaignsFile()
//                self.viewModel.dataModel.loadCampaignsFromLocal()
//                self.viewModel.dataModel.setCampaignsAndParties()
//                self.campaignDetailTableView.reloadData()
//            })
//            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: {
//                (action) -> () in
//                print("fuggeddaboudit")
//            })
//
//            alertController.addAction(loadButton)
//            alertController.addAction(saveButton)
//            alertController.addAction(cancelButton)
//            self.present(alertController, animated: true, completion: nil)
//        } else {
//            authenticateToDropBox()
//        }
        
    }
    
    @IBOutlet weak var campaignDetailTableView: UITableView!

    @IBAction func selectCampaignAction(_ sender: Any) {
        loadSelectCampaignViewController()
    }
    @IBAction func createCampaignAction(_ sender: Any) {
        loadCreateCampaignViewController()
    }
    @IBAction func deleteCampaignAction(_ sender: Any) {
        showConfirmDeletionAlert()
    }
    weak var delegate: CampaignDetailViewControllerDelegate!
    weak var delegateVM: CampaignDetailViewModel!
    
    var viewModel: CampaignDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    // Vars for eventOptionPicker
    var eventOptionPicker = UIPickerView()
    var eventOptionPickerData = [String]()
    var myEventOptionInputView = UIView()
    var eventOptionDummyTextField = UITextField()
    // Vars for characterTypePicker
    var characterTypePicker = UIPickerView()
    var characterTypePickerData = [String]()
    var characterTypePickerInputView = UIView()
    var characterTypePickerDummyTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Test dropbox setup
        //authenticateToDropBox()

        viewModel.reloadSection = { [weak self] (section: Int) in
            if section == 1 {
                self?.refreshProsperityLevel()
            } else if section == 3 {
                self?.refreshTypes()
            } else if section == 4 {
                self?.refreshParties()
            } else if section == 6 {
                self?.refreshEvents()
            }
        }
        viewModel.scrollEventsSection = { [weak self] () in
            self?.scrollToBottom()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEventOptionPicker), name: NSNotification.Name(rawValue: "showEventChoiceOptionPicker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showCharacterTypePicker), name: NSNotification.Name(rawValue: "showCharacterAvailableTypePicker"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSwipeAlertStarting), name: NSNotification.Name(rawValue: "showSwipeAlertStarting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSwipeAlertUsed), name: NSNotification.Name(rawValue: "showSwipeAlertUsed"), object: nil)
        
        campaignDetailTableView?.dataSource = viewModel
        campaignDetailTableView?.delegate = viewModel
        eventOptionPicker.delegate = self.viewModel
        eventOptionPicker.dataSource = self.viewModel
        characterTypePicker.delegate = self.viewModel
        characterTypePicker.dataSource = self.viewModel
        
        campaignDetailTableView.separatorInset = .zero // Get rid of offset to left for tableview!
        
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailEventCell.nib, forCellReuseIdentifier: CampaignDetailEventCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAvailableTypeCell.nib, forCellReuseIdentifier: CampaignDetailAvailableTypeCell.identifier)
        campaignDetailTableView?.register(CampaignDetailNotesCell.nib, forCellReuseIdentifier: CampaignDetailNotesCell.identifier)
        
        // Register Custom header(s)
        campaignDetailTableView?.register(CampaignDetailEventsHeader.nib, forCellReuseIdentifier: CampaignDetailEventsHeader.identifier)
        campaignDetailTableView?.register(CampaignDetailPartiesHeader.nib, forCellReuseIdentifier: CampaignDetailPartiesHeader.identifier)
        
        styleUI()
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension CampaignDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let item = viewModel.items[indexPath!.section]
        
        switch item.type {
            
        case .prosperity:
            break
        case .donations:
            break
        case .achievements:
            break
        case .campaignTitle:
            break
        case .parties:
            break
        case .events:
            break
        case .availableTypes:
            break
        case .campaignNotes:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.hideAllControls()
        characterTypePickerDidTapCancel()
        eventOptionPickerDidTapCancel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel.updateAchievements()
        viewModel.updateCurrentParty()
        viewModel.updateCampaignTitle()
        viewModel.updateChecksToNextLevel()
        viewModel.updateProsperityLevel()
        viewModel.updateDonations()
        viewModel.updateAvailableParties()
        viewModel.updateAssignedParties()
        viewModel.updateEvents()
        viewModel.updateCampaignNotes()

        self.campaignDetailTableView.reloadData()
        self.updateNavTitle()
        
        // Try scrolling back to top when coming back to this screen
        self.campaignDetailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
        
    }
    // Helper methods
    fileprivate func styleUI() {
        self.campaignDetailTableView.estimatedRowHeight = 80
        self.campaignDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        //self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.navigationItem.title = "Current Campaign"
        self.campaignDetailTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.campaignDetailTableView.backgroundView?.alpha = 0.25
    }

    func updateAllSections() {
        viewModel.updateAchievements()
        viewModel.updateCampaignTitle()
        viewModel.updateChecksToNextLevel()
        viewModel.updateProsperityLevel()
        viewModel.updateDonations()
        viewModel.updateAvailableParties()
        viewModel.updateAssignedParties()
        viewModel.updateEvents()
    }
    func refreshAllSections() {
        self.campaignDetailTableView.reloadData()
    }
    // Currently dedicated to Events section
    func scrollToBottom() {
        var numberOfRows = Int()
        switch self.viewModel.selectedEventsSegmentIndex {
        case 0:
        numberOfRows = self.viewModel.unavailableEvents.value.filter { $0.type.rawValue == self.viewModel.selectedEventType }.count
        case 1:
        numberOfRows = self.viewModel.availableEvents.value.filter { $0.type.rawValue == self.viewModel.selectedEventType }.count
        case 2:
        numberOfRows = self.viewModel.completedEvents.value.filter { $0.type.rawValue == self.viewModel.selectedEventType }.count
        default:
            break
        }
        if numberOfRows > 0 && numberOfRows < 5 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: numberOfRows - 1, section: 6)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else if numberOfRows > 5 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 4, section: 6)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 0, section: 6)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([5], with: .none)
        }
    }
    func refreshCampaignTitle() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([0], with: .none)
        }
    }
    func refreshProsperityLevel() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([1], with: .none)
        }
    }
    func refreshDonations() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([2], with: .none)
        }
    }
    func refreshParties() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([4], with: .none)
        }
    }
    func refreshTypes() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([3], with: .none)
        }
    }
    func refreshEvents() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([6], with: .automatic)
        }
    }
    func updateNavTitle() {
        //self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.navigationItem.title = "Current Campaign"
    }
    fileprivate func showConfirmDeletionAlert () {
        let alertController = UIAlertController(title: "Delete current campaign?", message: "Clicking OK will delete the current campaign.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
            self.delegate.campaignDetailVCDidTapDelete(self)
            self.updateAllSections()
            self.refreshAllSections()
            self.updateNavTitle()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    @objc func showSwipeAlertStarting() {
        let alertTitle = "Cannot lock starting character type"
        let alertView = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    @objc func showSwipeAlertUsed() {
        let alertTitle = "Cannot lock used character type"
        let alertView = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    // Action methods
    fileprivate func loadSelectCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCampaignVC = storyboard.instantiateViewController(withIdentifier: "SelectCampaignViewController") as! SelectCampaignViewController
        selectCampaignVC.delegate = viewModel
        // Give VC the current campaign so it can set checkmark.
        selectCampaignVC.currentCampaign = viewModel.campaignTitle.value
        selectCampaignVC.viewModel = CampaignViewModelFromModel(withDataModel: viewModel!.dataModel)
        selectCampaignVC.reloadDelegate = self // Need to reloadData on entire table before returning here!
        selectCampaignVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(selectCampaignVC, animated: true, completion: nil)
    }
    fileprivate func loadCreateCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
        let navCon = UINavigationController(rootViewController: createCampaignVC)
        // Give VC the current campaign so it can set checkmark.
        self.viewModel.updateAvailableParties()
        self.viewModel.updateAssignedParties()
        let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel!.dataModel)
//        createCampaignVC.viewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel!.dataModel)
        createCampaignVC.viewModel = createCampaignVCViewModel
        createCampaignVC.delegate = createCampaignVCViewModel
        // Test Test!
        createCampaignVC.reloadDelegate = self // Need to reloadData on entire table before returning here!
        createCampaignVC.hidesBottomBarWhenPushed = true
        //self.navigationController!.pushViewController(createCampaignVC, animated: true)
        self.present(navCon, animated: true, completion: nil)
    }
    fileprivate func loadAuthenticationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authenticationControllerVC = storyboard.instantiateViewController(withIdentifier: "AuthenticationController") as! AuthenticationController
        authenticationControllerVC.firstLoad = false
        let navCon = UINavigationController(rootViewController: authenticationControllerVC)
        self.present(navCon, animated: true, completion: nil)
    }
    // Dropbox stuff
    fileprivate func authenticateToDropBox() {
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
    }
    func downloadCampaignsFile() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.listFolder(path: "").response {
                response, error in
                if let result = response {
                    print("Folder Contents:")
                    for entry in result.entries {
                        if entry.name == "Campaigns.plist" {
                            let destination: (URL, HTTPURLResponse) -> URL = { tempURL, response in
                                return self.viewModel.dataFilePath
                            }
                            client.files.download(path: "/Campaigns.plist", overwrite: true, destination: destination)
                                .response { response, error in
                                    if let _ = response {
//                                        self.campaignDetailTableView.reloadData()
                                    } else if let _ = error {
                                        self.showNoCampaignsFileAlert()
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
    }
    func showNoCampaignsFileAlert() {
        let alertTitle = "Did not find a save file!"
        let alertView = UIAlertController(
            title: alertTitle,
            message: "You must first save your progress to Dropbox.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    // Called by CampaignDetailViewModel
    func showDisallowDeletionAlert() {
        let alertTitle = "Cannot delete only campaign!"
        let alertView = UIAlertController(
            title: alertTitle,
            message: "Create a new campaign before deleting this one.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    @objc func showEventOptionPicker() {
        eventOptionPicker.tag = 5
        eventOptionPicker.layer.cornerRadius = 10
        eventOptionPicker.layer.masksToBounds = true
        eventOptionPicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        eventOptionPicker.showsSelectionIndicator = true
        
        // Try to set up toolbar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setEventOptionChoice))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(eventOptionPickerDidTapCancel))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        eventOptionPicker.reloadAllComponents()
        eventOptionPicker.addSubview(toolBar)
        myEventOptionInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: eventOptionPicker.frame.size.height + 44))
        eventOptionPicker.frame = CGRect(x: 0, y: 0, width: myEventOptionInputView.frame.width, height: 200)
        eventOptionPicker.selectRow(0, inComponent: 0, animated: true) // Set to first row
        delegate.eventOptionPickerDidPick = false // Reset this after initial selection setting
        myEventOptionInputView.addSubview(eventOptionPicker)
        myEventOptionInputView.addSubview(toolBar)
        eventOptionDummyTextField.inputView = myEventOptionInputView
        eventOptionDummyTextField.isHidden = true
        self.view.addSubview(eventOptionDummyTextField)
        self.view.addSubview(myEventOptionInputView)
    }
    @objc func eventOptionPickerDidTapCancel() {
        self.myEventOptionInputView.removeFromSuperview()
        self.eventOptionPicker.removeFromSuperview()
        eventOptionPickerData.removeAll()
    }
    @objc func setEventOptionChoice() {
        delegate.setEventOptionChoice()
        self.myEventOptionInputView.removeFromSuperview()
        self.eventOptionPicker.removeFromSuperview()
        eventOptionPickerData.removeAll()
    }
    // Called via notification
    @objc func showCharacterTypePicker() {
        characterTypePicker.tag = 20
        characterTypePicker.layer.cornerRadius = 10
        characterTypePicker.layer.masksToBounds = true
        characterTypePicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        characterTypePicker.showsSelectionIndicator = true
        
        // Try to set up toolbar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setCharacterType))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(characterTypePickerDidTapCancel))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        characterTypePicker.reloadAllComponents()
        characterTypePicker.addSubview(toolBar)
        characterTypePickerInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: characterTypePicker.frame.size.height + 44))
        characterTypePicker.frame = CGRect(x: 0, y: 0, width: characterTypePickerInputView.frame.width, height: 200)
        characterTypePicker.selectRow(0, inComponent: 0, animated: true) // Set to first row
        delegate?.characterTypePickerDidPick = false // Reset this after initial selection setting
        characterTypePickerInputView.addSubview(characterTypePicker)
        characterTypePickerInputView.addSubview(toolBar)
        characterTypePickerDummyTextField.inputView = characterTypePickerInputView
        characterTypePickerDummyTextField.isHidden = true
        self.view.addSubview(characterTypePickerDummyTextField)
        self.view.addSubview(characterTypePickerInputView)
    }
    @objc func setCharacterType() {
        delegate!.setCharacterType()
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
    @objc func characterTypePickerDidTapCancel() {
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
}

extension CampaignDetailViewController: CreateCampaignViewControllerReloadDelegate {
    func reloadAfterDidFinishAdding() {
        self.campaignDetailTableView.reloadData()
        self.updateNavTitle()
    }
}

