//
//  ScenarioDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/25/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit


class ScenarioDetailViewController: UIViewController {
    
    var viewModel: ScenarioDetailViewModel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(ScenarioTitleCell.nib, forCellReuseIdentifier: ScenarioTitleCell.identifier)
        tableView?.register(SummaryInfoCell.nib, forCellReuseIdentifier: SummaryInfoCell.identifier)
        tableView?.register(LocationInfoCell.nib, forCellReuseIdentifier: LocationInfoCell.identifier)
        tableView?.register(UnlockedByInfoCell.nib, forCellReuseIdentifier: UnlockedByInfoCell.identifier)
        tableView?.register(UnlocksInfoCell.nib, forCellReuseIdentifier: UnlocksInfoCell.identifier)
        tableView?.register(RequirementsInfoCell.nib, forCellReuseIdentifier: RequirementsInfoCell.identifier)
        tableView?.register(RewardsInfoCell.nib, forCellReuseIdentifier: RewardsInfoCell.identifier)
        tableView?.register(AchievesInfoCell.nib, forCellReuseIdentifier: AchievesInfoCell.identifier)
        tableView?.backgroundColor = colorDefinitions.mainBGColor
        //tableView?.separatorInset = .zero
        //setTableViewBGImage()

    }

    func setTableViewBGImage() {
        
        switch viewModel.locationString[1] {
        case "Copperneck Mountains":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGCopperneckMountains"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Corpsewood":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGCorpsewood"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Dagger Forest":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGDaggerForest"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Gloomhaven":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGGloomhaven"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Lingering Swamp":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGLingeringSwamp"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Misty Sea":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGMistySea"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Serpent's Kiss River":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGSerpentsKissRiver"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Still River":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGStillRiver"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "East Road":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGEastRoad"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Stone Road":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGStoneRoad"))
            self.tableView?.backgroundView?.alpha = 0.25
        case "Watcher Mountains":
            self.tableView?.backgroundView = UIImageView(image: UIImage(named: "scenarioMgrTableViewBGWatcherMountains"))
            self.tableView?.backgroundView?.alpha = 0.25
        default:
            break
        }
    }
    func configureRowIcon(for tableViewCell: ScenarioTitleCell, with scenario: Scenario) {
        if scenario.isCompleted == true {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.requirementsMet == true && scenario.isUnlocked == true {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioBlankIcon")
        } else {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
    }
}

extension ScenarioDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.section]
        let statusIcon = viewModel.statusIcon
        switch item.type {
        case .scenarioTitle:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ScenarioTitleCell.identifier, for: indexPath) as? ScenarioTitleCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.scenarioStatusIcon.image = statusIcon
                cell.item = item
                return cell
            }
        case .unlocksInfo:
            if let item = item as? ScenarioDetailViewModelUnlocksInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: UnlocksInfoCell.identifier, for: indexPath) as? UnlocksInfoCell {
                let unlock = item.unlocks[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.separatorInset = .zero
                cell.item = unlock
                return cell
            }
        case .unlockedByInfo:
            if let item = item as? ScenarioDetailViewModelUnlockedByInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: UnlockedByInfoCell.identifier, for: indexPath) as? UnlockedByInfoCell {
                let unlockedBy = item.unlockedBys[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.separatorInset = .zero
                cell.item = unlockedBy
                return cell
            }
        case .requirementsInfo:
            if let item = item as? ScenarioDetailViewModelRequirementsInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: RequirementsInfoCell.identifier, for: indexPath) as? RequirementsInfoCell {
                let requirement = item.requirements[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.separatorInset = .zero
                cell.selectionStyle = .none
                cell.item = requirement
                return cell
                //}
                
            }
        case .rewardsInfo:
            if let item = item as? ScenarioDetailViewModelRewardsInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: RewardsInfoCell.identifier, for: indexPath) as? RewardsInfoCell {
                let reward = item.rewards[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.separatorInset = .zero
                cell.selectionStyle = .none
                cell.item = reward
                return cell
            }
        case .achievesInfo:
            if let item = item as? ScenarioDetailViewModelAchievesInfoItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: AchievesInfoCell.identifier, for: indexPath) as? AchievesInfoCell {
                let achieve = item.achieves[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.separatorInset = .zero
                cell.selectionStyle = .none
                cell.item = achieve
                return cell
            }
        case .scenarioSummary:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SummaryInfoCell.identifier, for: indexPath) as? SummaryInfoCell {
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.item = item
                cell.backgroundColor = UIColor.clear
                cell.separatorInset = .zero
                return cell
            }
        case .scenarioLocation:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationInfoCell.identifier, for: indexPath) as? LocationInfoCell {
                //cell.backgroundColor = cellBGColor
                cell.item = item
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        if let currentCell = tableView.cellForRow(at: indexPath!) as? LockOrUnlockCellType {
            if !((currentCell.item?.number?.contains("Event"))!) && !((currentCell.item?.number?.contains("Envelope"))!) {
                let tappedScenario = viewModel.getScenario(scenarioNumber: (currentCell.item?.number)!)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToDetail"), object: nil, userInfo: ["Scenario": tappedScenario!])
            }
            tableView.deselectRow(at: indexPath!, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
}
