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

extension CampaignDetailViewController: UITableViewDataSource, UITableViewDelegate, CampaignDetailTitleCellDelegate {

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
                cell.delegate = self
                // Give proper status to isActive button in this cell
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                return cell
            }
        case .parties:
            if let item = item as? CampaignDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                let party = item.names[indexPath.row]
                cell.item = party
                return cell
            }
        case .achievements:
            if let item = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                let achievement = item.achievements[indexPath.row]
                cell.item = achievement
                return cell
            }
        case .prosperity:
            if let item = item as? CampaignDetailViewModelCampaignProsperityItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailProsperityCell.identifier, for: indexPath) as? CampaignDetailProsperityCell {
                cell.item = item
                return cell
            }
        case .donations:
            if let item = item as? CampaignDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                cell.item = item
                return cell
            }
        //        case .events:
//            break
        }
        return UITableViewCell()
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
        
        viewModel.setCampaignActive()
    }
}
