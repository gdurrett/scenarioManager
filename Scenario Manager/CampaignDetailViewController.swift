//
//  CampaignDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailViewControllerDelegate: class {
    func campaignDetailVCDidTapDelete(_ controller: CampaignDetailViewController)
    func toggleSection(section: Int)
    func setEventOptionChoice()
    func setPartyChoice()
}

class CampaignDetailViewController: UIViewController {

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
    // Vars for partyPicker
    var partyPicker = UIPickerView()
    var partyPickerData = [String]()
    var myPartyPickerInputView = UIView()
    var partyPickerDummyTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Test
        
        viewModel.reloadSection = { [weak self] (section: Int) in
            if section == 4 {
                self?.refreshParties()
            } else if section == 5 {
                self?.refreshEvents()
            }
        }
        viewModel.scrollEventsSection = { [weak self] () in
            self?.scrollToBottom()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPartyPicker), name: NSNotification.Name(rawValue: "showPartyPicker"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEventOptionPicker), name: NSNotification.Name(rawValue: "showEventChoiceOptionPicker"), object: nil)
        
        campaignDetailTableView?.dataSource = viewModel
        campaignDetailTableView?.delegate = viewModel
        eventOptionPicker.delegate = self.viewModel
        eventOptionPicker.dataSource = self.viewModel
        partyPicker.delegate = self.viewModel
        partyPicker.dataSource = self.viewModel
        
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailEventCell.nib, forCellReuseIdentifier: CampaignDetailEventCell.identifier)
        
        // Register Custom header(s)
        campaignDetailTableView?.register(CampaignDetailEventsHeader.nib, forCellReuseIdentifier: CampaignDetailEventsHeader.identifier)
        campaignDetailTableView?.register(CampaignDetailPartiesHeader.nib, forCellReuseIdentifier: CampaignDetailPartiesHeader.identifier)
        
//        updateAllSections()
//        refreshAllSections()
        
        styleUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel.updateAchievements()
        viewModel.updateCampaignTitle()
        viewModel.updateChecksToNextLevel()
        viewModel.updateProsperityLevel()
        viewModel.updateDonations()
        viewModel.updateAvailableParties()
        viewModel.updateAssignedParties()
        viewModel.updateEvents()
        
        refreshAchievements()
        refreshCampaignTitle()
        refreshProsperityLevel()
        refreshDonations()
        refreshParties()
        refreshEvents()
        
        //self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.updateNavTitle()
        
//        updateAllSections()
//        refreshAllSections()
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
        refreshAchievements()
        refreshCampaignTitle()
        refreshProsperityLevel()
        refreshDonations()
        refreshParties()
        refreshEvents()
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
                let indexPath = IndexPath(row: numberOfRows - 1, section: 5)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else if numberOfRows > 5 {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 4, section: 5)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 0, section: 5)
                self.campaignDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([3], with: .none)
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
    func refreshEvents() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([5], with: .automatic)
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
        // Give VC the current campaign so it can set checkmark.
        self.viewModel.updateAvailableParties()
        self.viewModel.updateAssignedParties()
        createCampaignVC.viewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel!.dataModel)
        createCampaignVC.delegate = createCampaignVC.viewModel
        // Test Test!
        createCampaignVC.reloadDelegate = self // Need to reloadData on entire table before returning here!
        createCampaignVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(createCampaignVC, animated: true, completion: nil)
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
    // Called by CampaignDetailViewModel
//    @objc func showEventChoiceAlert() {
//        let optionMenu = UIAlertController(title: nil, message: "Choose an option", preferredStyle: .actionSheet)
//
//        let chooseOptionA = UIAlertAction(title: "Choose Option A", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            self.delegate!.setEventOptionChoice(option: "A")
//        })
//        let chooseOptionB = UIAlertAction(title: "Choose Option B", style: .default, handler: {
//            (alert: UIAlertAction!) -> Void in
//            self.delegate!.setEventOptionChoice(option: "B")
//        })
//
//        optionMenu.addAction(chooseOptionA)
//        optionMenu.addAction(chooseOptionB)
//
//        optionMenu.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
//        present(optionMenu, animated: true, completion: nil)
//    }
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
    @objc func showPartyPicker() {
        partyPicker.tag = 10
        partyPicker.layer.cornerRadius = 10
        partyPicker.layer.masksToBounds = true
        partyPicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        partyPicker.showsSelectionIndicator = true
        
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setPartyChoice))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(partyPickerDidTapCancel))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        partyPicker.reloadAllComponents()
        partyPicker.addSubview(toolBar)
        myPartyPickerInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: partyPicker.frame.size.height + 44))
        partyPicker.frame = CGRect(x: 0, y: 0, width: myPartyPickerInputView.frame.width, height: 200)
        myPartyPickerInputView.addSubview(partyPicker)
        myPartyPickerInputView.addSubview(toolBar)
        partyPickerDummyTextField.inputView = myPartyPickerInputView
        partyPickerDummyTextField.isHidden = true
        self.view.addSubview(partyPickerDummyTextField)
        self.view.addSubview(myPartyPickerInputView)
    }
    @objc func partyPickerDidTapCancel() {
        self.myPartyPickerInputView.removeFromSuperview()
        self.partyPicker.removeFromSuperview()
        partyPickerData.removeAll()
    }
    @objc func setPartyChoice() {
        delegate.setPartyChoice()
        self.myPartyPickerInputView.removeFromSuperview()
        self.partyPicker.removeFromSuperview()
        partyPickerData.removeAll()
    }
}
// Test Test!
extension CampaignDetailViewController: CreateCampaignViewControllerReloadDelegate {
    func reloadAfterDidFinishAdding() {
        self.campaignDetailTableView.reloadData()
        self.updateNavTitle()
    }
}

