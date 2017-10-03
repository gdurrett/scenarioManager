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

class CampaignDetailViewController: UIViewController {

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
        delegate.campaignDetailVCDidTapDelete(self)
        updateAllSections()
        refreshAllSections()
    }
    weak var delegate: CampaignDetailViewControllerDelegate!
    
    var viewModel: CampaignDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        campaignDetailTableView?.dataSource = viewModel
        campaignDetailTableView?.delegate = viewModel
        
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        
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
            print("I selected a prosperity row")
        case .donations:
            print("I selected a donations row")
        case .achievements:
            break
        case .campaignTitle:
            break
        case .parties:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //UIView.setAnimationsEnabled(true)
        
        //self.navigationController?.popViewController(animated: true)
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

}
