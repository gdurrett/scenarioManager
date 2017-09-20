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
    
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    
    @IBOutlet weak var campaignDetailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        campaignDetailTableView?.dataSource = self
        campaignDetailTableView?.delegate = self
        campaignDetailTableView?.estimatedRowHeight = 100
        campaignDetailTableView?.rowHeight = UITableViewAutomaticDimension
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CampaignDetailViewController: UITableViewDataSource, UITableViewDelegate, CampaignDetailTitleCellDelegate, CampaignDetailProsperityCellDelegate, CampaignDetailDonationsCellDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.section]
        
        switch item.type {
        case .campaignTitle:
            if let item = item as? CampaignDetailViewModelCampaignTitleItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailTitleCell.identifier, for: indexPath) as? CampaignDetailTitleCell {
                viewModel?.campaignTitle = item.title
                cell.selectionStyle = .none
                cell.delegate = self
                // Give proper status to isActive button in this cell
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                return cell
            }
        case .parties:
            if let item = item as? CampaignDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                cell.selectionStyle = .none
                let party = item.names[indexPath.row]
                cell.item = party
                return cell
            }
        case .achievements:
            if let item = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                let achievement = item.achievements[indexPath.row]
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
        case .prosperity:
            if let item = item as? CampaignDetailViewModelCampaignProsperityItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailProsperityCell.identifier, for: indexPath) as? CampaignDetailProsperityCell {
                // Give proper status to isActive button in this cell
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                currentProsperityCell = cell
                return cell
            }
        case .donations:
            if let item = item as? CampaignDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                // Give proper status to isActive button in this cell
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                currentDonationsCell = cell
                return cell
            }
        //        case .events:
//            break
        }
        return UITableViewCell()
    }
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
        self.navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
    func setCampaignActive() {
        self.viewModel.setCampaignActive()
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.isActive = true
        }
        if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
            cell.isActive = true
        }
    }
    // Delegate methods for custom campaign cells
    func updateCampaignProsperityCount(value: Int) {
        let (level, count) = (self.viewModel.updateProsperityCount(value: value))
        let remainingChecks = self.viewModel.getRemainingChecksUntilNextLevel(level: level, count: count)
        let checksText = remainingChecks > 1 ? "checks" : "check"
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.campaignDetailProsperityLabel.text = "\(level) (\(remainingChecks) \(checksText) to next level)"
        }
    }
    func updateCampaignDonationsCount(value: Int) {
        let amount = self.viewModel.updateCampaignDonationsCount(value: value)
        if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
            cell.campaignDetailDonationsLabel.text = "\(amount)"
        }
    }
}
