//
//  CampaignDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailViewController: UIViewController {
    
    var viewModel: CampaignDetailViewModel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    @IBOutlet weak var campaignDetailTableView: UITableView!

    @IBAction func selectCampaignAction(_ sender: Any) {
        loadSelectCampaignViewController()
    }
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
        
        viewModel.updateAchievements()
        refreshAchievements()
        
        viewModel.updateCampaignTitle()
        refreshCampaignTitle()

        viewModel.updateChecksToNextLevel()

        viewModel.updateProsperityLevel()
        refreshProsperityLevel()

        viewModel.updateDonations()
        refreshDonations()

        viewModel.updateParties()
        refreshParties()
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
}
