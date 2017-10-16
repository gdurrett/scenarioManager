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
    func showEventChoiceAlert(_ controller: CampaignDetailViewController)
    func setEventOptionChoice(option: String)
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
    
    var viewModel: CampaignDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Test
        
        viewModel.reloadEventsSection = { [weak self] (section: Int) in
            self?.refreshEvents()
            //self?.scrollToBottom()
        }
        viewModel.scrollEventsSection = { [weak self] () in
            self?.scrollToBottom()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showEventChoiceAlert), name: NSNotification.Name(rawValue: "showEventChoiceAlert"), object: nil)

        campaignDetailTableView?.dataSource = viewModel
        campaignDetailTableView?.delegate = viewModel
        
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
        viewModel.updateParties()
        viewModel.updateEvents()
        
        refreshAchievements()
        refreshCampaignTitle()
        refreshProsperityLevel()
        refreshDonations()
        refreshParties()
        refreshEvents()
        
        self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")

        
//        updateAllSections()
//        refreshAllSections()
    }
    // Helper methods
    fileprivate func styleUI() {
        self.campaignDetailTableView.estimatedRowHeight = 80
        self.campaignDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.campaignDetailTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.campaignDetailTableView.backgroundView?.alpha = 0.25
    }

    func updateAllSections() {
        viewModel.updateAchievements()
        viewModel.updateCampaignTitle()
        viewModel.updateChecksToNextLevel()
        viewModel.updateProsperityLevel()
        viewModel.updateDonations()
        viewModel.updateParties()
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
            self.campaignDetailTableView.reloadSections([4], with: .none)
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
            self.campaignDetailTableView.reloadSections([3], with: .none)
        }
    }
    func refreshEvents() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([5], with: .automatic)
        }
    }
    
    fileprivate func showConfirmDeletionAlert () {
        let alertController = UIAlertController(title: "Delete current campaign?", message: "Clicking OK will delete the current campaign.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
            self.delegate.campaignDetailVCDidTapDelete(self)
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
        //self.navigationController!.pushViewController(selectCampaignVC, animated: true)
        self.navigationController!.present(selectCampaignVC, animated: true, completion: nil)
    }
    fileprivate func loadCreateCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
        // Give VC the current campaign so it can set checkmark.
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
    @objc func showEventChoiceAlert() {
        let optionMenu = UIAlertController(title: nil, message: "Choose an option", preferredStyle: .actionSheet)
        
        let chooseOptionA = UIAlertAction(title: "Choose Option A", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.delegate!.setEventOptionChoice(option: "A")
        })
        let chooseOptionB = UIAlertAction(title: "Choose Option B", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.delegate!.setEventOptionChoice(option: "B")
        })
        
        optionMenu.addAction(chooseOptionA)
        optionMenu.addAction(chooseOptionB)
        
        optionMenu.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        present(optionMenu, animated: true, completion: nil)
    }
}
// Test Test!
extension CampaignDetailViewController: CreateCampaignViewControllerReloadDelegate {
    func reloadAfterDidFinishAdding() {
        self.campaignDetailTableView.reloadData()
    }
}
