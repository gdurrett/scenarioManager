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
}

class CampaignDetailViewController: UIViewController, CampaignDetailViewModelDelegate {

    @IBOutlet weak var campaignDetailTableView: UITableView!

    @IBAction func selectCampaignAction(_ sender: Any) {
        loadSelectCampaignViewController()
    }
    @IBAction func createCampaignAction(_ sender: Any) {
        loadCreateCampaignViewController()
    }
    @IBAction func deleteCampaignAction(_ sender: Any) {
        // Call back to viewModel
        // check if we're only campaign and raise alert if so
        //delegate.campaignDetailVCDidTapDelete(self)
        showConfirmDeletionAlert()
//        updateAllSections()
//        refreshAllSections()
    }
    weak var delegate: CampaignDetailViewControllerDelegate!
    
    var viewModel: CampaignDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        viewModel.delegate = self
        
        campaignDetailTableView?.dataSource = viewModel
        campaignDetailTableView?.delegate = viewModel
        
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailCityEventsCell.nib, forCellReuseIdentifier: CampaignDetailCityEventsCell.identifier)
        styleUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        case .cityEvents:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        updateAllSections()
        refreshAllSections()
    }
    // Helper methods
    fileprivate func styleUI() {
        self.campaignDetailTableView.estimatedRowHeight = 80
        self.campaignDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationItem.title = ("Campaign Detail")
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
    }
    func refreshAllSections() {
        refreshAchievements()
        refreshCampaignTitle()
        refreshProsperityLevel()
        refreshDonations()
        refreshParties()
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
    func refreshCityEvents() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([5], with: .none)
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
}
