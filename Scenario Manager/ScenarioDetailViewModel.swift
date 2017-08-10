//
//  ScenarioDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/25/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

enum ScenarioDetailViewModelItemType {
    case scenarioTitle
    case unlocksInfo
    case unlockedByInfo
    case requirementsInfo
    case rewardsInfo
    case achievesInfo
    case scenarioSummary
    case scenarioLocation
}

protocol ScenarioDetailViewModelItem {
    var type: ScenarioDetailViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}
//Have unlock and lock tableViewCells conform to this so we can combine didSelectRow at stuff
protocol LockOrUnlockCellType {
    var item: ScenarioNumberAndTitle? { get set }
}
class ScenarioDetailViewModel: NSObject {
    
    var scenario: Scenario!
    var items = [ScenarioDetailViewModelItem]()
    var dataModel = DataModel.sharedInstance
    var unlocks = [ScenarioNumberAndTitle]()
    var unlockedBys = [ScenarioNumberAndTitle]()
    var requirements = [SeparatedStrings]()
    var requirementLabel = String()
    var orPresent = false
    var oneofPresent = false
    var rewards = [SeparatedStrings]()
    var achieves = [SeparatedStrings]()
    var cellBGColor = UIColor()
    var statusIcon = UIImage()
    var myLockedTitle: String?
    var myCompletedTitle: String?
    var bgColor: UIColor?
    
    override init() {
        super.init()
        
        if let scenario = dataModel.selectedScenario {
            getStatusIcon(scenario: scenario)

            let titleItem = ScenarioDetailViewModelScenarioTitleItem(number: scenario.number, title: scenario.title, statusIcon: statusIcon)
            items.append(titleItem)
            
            let locationItem = ScenarioDetailViewModelScenarioLocationItem(location: scenario.location)
            items.append(locationItem)
            
            let summaryItem = ScenarioDetailViewModelScenarioSummaryItem(summary: scenario.summary)
            items.append(summaryItem)
            
            for unlockedBy in scenario.unlockedBy {
                unlockedBys.append(ScenarioNumberAndTitle(number: unlockedBy))
            }
            if !scenario.unlockedBy.contains("None") {
                let unlockedByItem = ScenarioDetailViewModelUnlockedByInfoItem(unlockedBys: unlockedBys)
                items.append(unlockedByItem)
            }
            // Create array of ScenarioNumberAndTitle objects to store unlock info as objects
            for unlock in scenario.unlocks {
                if unlock == "ONEOF" {
                    oneofPresent = true
                    continue
                }
                unlocks.append(ScenarioNumberAndTitle(number: unlock))
            }
            if !scenario.unlocks.contains("None") {
                let unlocksItem = ScenarioDetailViewModelUnlocksInfoItem(unlocks: unlocks, oneofPresent: oneofPresent)
                items.append(unlocksItem)
            }

            if scenario.requirements.index(forKey: "None") == nil {
                for requirement in scenario.requirements {
                    
                    if requirement.key == "None" {
                        break
                    }
                    
                    if requirement.key == "OR" {
                        orPresent = true
                        continue
                    }
                    if requirement.key != "None" && requirement.value == true {
                        requirementLabel = "COMPLETE"
                    } else if requirement.key != "None" && requirement.value == false {
                        requirementLabel = "INCOMPLETE"
                    } else {
                        requirementLabel = ""
                    }
                    if requirement.key != "None" {
                        requirements.append(SeparatedStrings(rowString:"\(requirement.key)" + ": " + "\(requirementLabel)"))
                    } else {
                        requirements.append(SeparatedStrings(rowString:requirement.key))
                    }
                }
                let requirementsItem = ScenarioDetailViewModelRequirementsInfoItem(requirements: requirements, orPresent: orPresent)
                items.append(requirementsItem)
            }
            for reward in scenario.rewards {
                rewards.append(SeparatedStrings(rowString:reward))
            }
            if !scenario.rewards.contains("None") {
                let rewardsItem = ScenarioDetailViewModelRewardsInfoItem(rewards: rewards)
                items.append(rewardsItem)
            }
            var remove = false
            for achieve in scenario.achieves {
                if achieve == "REMOVE" {
                    remove = true
                    continue
                }
                if remove {
                    achieves.append(SeparatedStrings(rowString: "REMOVE: " + achieve))
                    remove = false
                } else {
                    achieves.append(SeparatedStrings(rowString: achieve))
                }
            }

            if !scenario.achieves.contains("None") {
                let achievesItem = ScenarioDetailViewModelAchievesInfoItem(achieves: achieves)
                items.append(achievesItem)
            }
        }
    }
    //MARK: Helper Functions
    
    func getStatusIcon(scenario: Scenario) {
        if scenario.completed {
            cellBGColor = DataModel.sharedInstance.completedBGColor
            statusIcon = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.isUnlocked && scenario.requirementsMet {
            cellBGColor = DataModel.sharedInstance.availableBGColor
            //statusIcon = #imageLiteral(resourceName: "scenarioAvailableIcon")
        } else {
            cellBGColor = DataModel.sharedInstance.unavailableBGColor
            statusIcon = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
    }
    
}

// Default number of rows to return if rows aren't specified
extension ScenarioDetailViewModelItem {
    var rowCount: Int {
        return 1
    }
}

extension ScenarioDetailViewModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .scenarioTitle:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ScenarioTitleCell.identifier, for: indexPath) as? ScenarioTitleCell {
                cell.backgroundColor = cellBGColor
                cell.item = item
                configureRowIcon(for: (cell), with: dataModel.selectedScenario!)
                return cell
            }
        case .unlocksInfo:
            if let item = item as? ScenarioDetailViewModelUnlocksInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: UnlocksInfoCell.identifier, for: indexPath) as? UnlocksInfoCell {
                cell.backgroundColor = cellBGColor
                let unlock = item.unlocks[indexPath.row]
                cell.item = unlock
                return cell
            }
        case .unlockedByInfo:
            if let item = item as? ScenarioDetailViewModelUnlockedByInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: UnlockedByInfoCell.identifier, for: indexPath) as? UnlockedByInfoCell {
                cell.backgroundColor = cellBGColor
                let unlockedBy = item.unlockedBys[indexPath.row]
                cell.item = unlockedBy
                return cell
            }
        case .requirementsInfo:
            if let item = item as? ScenarioDetailViewModelRequirementsInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: RequirementsInfoCell.identifier, for: indexPath) as? RequirementsInfoCell {
                cell.backgroundColor = cellBGColor
                let requirement = item.requirements[indexPath.row]
                cell.item = requirement
                return cell
                //}
                
            }
        case .rewardsInfo:
            if let item = item as? ScenarioDetailViewModelRewardsInfoItem, let cell = tableView.dequeueReusableCell(withIdentifier: RewardsInfoCell.identifier, for: indexPath) as? RewardsInfoCell {
                cell.backgroundColor = cellBGColor
                let reward = item.rewards[indexPath.row]
                cell.item = reward
                return cell
            }
        case .achievesInfo:
            if let item = item as? ScenarioDetailViewModelAchievesInfoItem,
                let cell = tableView.dequeueReusableCell(withIdentifier: AchievesInfoCell.identifier, for: indexPath) as? AchievesInfoCell {
                cell.backgroundColor = cellBGColor
                let achieve = item.achieves[indexPath.row]
                cell.item = achieve
                return cell
            }
        case .scenarioSummary:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SummaryInfoCell.identifier, for: indexPath) as? SummaryInfoCell {
                cell.backgroundColor = cellBGColor
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.item = item
                return cell
            }
        case .scenarioLocation:
            if let cell = tableView.dequeueReusableCell(withIdentifier: LocationInfoCell.identifier, for: indexPath) as? LocationInfoCell {
                cell.backgroundColor = cellBGColor
                cell.item = item
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        if let currentCell = tableView.cellForRow(at: indexPath!) as? LockOrUnlockCellType {
            let tappedScenario = dataModel.getScenario(scenarioNumber: (currentCell.item?.number)!)
            //post notification back to ScenarioViewController, passing scenario back to our segueToDetailViewController function
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToDetail"), object: nil, userInfo: ["Scenario": tappedScenario!])
            tableView.deselectRow(at: indexPath!, animated: true)
        }
    }
    // Set up swipe functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        scenario = dataModel.selectedScenario
        
        print("We have scenario: \(scenario.title)!")
        
        configureSwipeButton(for: scenario)
        
        let swipeToggleLocked = UITableViewRowAction(style: .normal, title: self.myLockedTitle) { action, index in
            if self.myLockedTitle == "Unlock" {
                self.scenario.isUnlocked = true
                self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                tableView.reloadData()
            } else if self.myLockedTitle == "Lock" {
                self.scenario.isUnlocked = false
                self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                tableView.reloadData()
            }
        }
        let swipeToggleComplete = UITableViewRowAction(style: .normal, title: self.myCompletedTitle) { action, index in
            //let indexPath = tableView.indexPathForSelectedRow
            if self.myCompletedTitle == "Unavailable" {
                //self.showSelectionAlert(status: "disallowCompletion")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSelectionAlert"), object: nil, userInfo: ["status": "disallowCompletion"])
                //tableView.deselectRow(at: indexPath!, animated: true)
            } else {
                if self.scenario.completed {
                    if self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                        if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                            //Okay to mark uncompleted, but don't trigger lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        } else {
                            //NOT okay to mark uncompleted
                            //self.showSelectionAlert(status: "")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSelectionAlert"), object: nil, userInfo: ["status": ""])
                        }
                    } else if !self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                        if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                            //Okay to mark uncompleted, but don't trigger lock of uncompleted lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        } else {
                            //Okay to mark uncompleted AND trigger lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        }
                    }
                } else {
                    self.scenario.completed = true
                    if self.scenario.unlocks[0] == "ONEOF" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToPicker"), object: nil, userInfo: ["Scenario": self.scenario!])
                    } else {
                        self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: true)
                        tableView.reloadData()
                    }
                }
            } // Can't complete
        }
        swipeToggleComplete.backgroundColor = bgColor
        swipeToggleLocked.backgroundColor = UIColor.darkGray
        if myLockedTitle == "Unlock" {
            return [swipeToggleLocked]
        } else if myLockedTitle == "NoShow" {
            return [swipeToggleComplete]
        } else {
            return [swipeToggleLocked, swipeToggleComplete]
        }
    }

    // Helpers - can these be centralized so both VCs share?
    func configureSwipeButton(for scenario: Scenario) {
        if scenario.completed {
            bgColor = UIColor.gray
            myCompletedTitle = "Set Uncompleted"
        } else if scenario.isUnlocked && scenario.requirementsMet  {
            bgColor = dataModel.completedBGColor
            myCompletedTitle = "Set Completed"
        } else {
            bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
            myCompletedTitle = "Unavailable"
        }
        if scenario.isManuallyUnlockable && scenario.isUnlocked && !scenario.completed {
            myLockedTitle = "Lock"
        } else if scenario.isManuallyUnlockable && !scenario.completed {
            myLockedTitle = "Unlock"
        } else {
            myLockedTitle = "NoShow"
        }
    }
    func configureRowIcon(for tableViewCell: ScenarioTitleCell, with scenario: Scenario) {
        if scenario.completed == true {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.requirementsMet == true && scenario.isUnlocked == true {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioBlankIcon")
        } else {
            tableViewCell.scenarioStatusIcon.image = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
        
    }
}
class ScenarioDetailViewModelScenarioTitleItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .scenarioTitle
    }
    
    var sectionTitle: String {
        return "Scenario Title"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var number: String
    var title: String
    // Try passing in availability status
    var statusIcon: UIImage
    
    init(number: String, title: String, statusIcon: UIImage) {
        self.number = number
        self.title = title
        self.statusIcon = statusIcon
    }
}

class ScenarioDetailViewModelUnlocksInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .unlocksInfo
    }
    
    var sectionTitle: String {
        if oneofPresent {
            return "Unlocks ONE OF"
        } else {
            return "Unlocks"
        }
    }
    
    var rowCount: Int {
        return unlocks.count
    }
    
    var unlocks: [ScenarioNumberAndTitle]
    var oneofPresent: Bool

    init(unlocks: [ScenarioNumberAndTitle], oneofPresent: Bool) {
        self.unlocks = unlocks
        self.oneofPresent = oneofPresent
    }
}

class ScenarioDetailViewModelUnlockedByInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .unlockedByInfo
    }
    
    var sectionTitle: String {
        return "Unlocked By"
    }
    
    var rowCount: Int {
        return unlockedBys.count
    }
    
    var unlockedBys: [ScenarioNumberAndTitle]
    
    init(unlockedBys: [ScenarioNumberAndTitle]) {
        self.unlockedBys = unlockedBys
    }
}

class ScenarioDetailViewModelRequirementsInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .requirementsInfo
    }
    
    var sectionTitle: String {
        if orPresent {
            return "Requirements (ONE OF)"
        } else {
            return "Requirements"
        }
    }
    
    var rowCount: Int {
        return requirements.count
    }
    
    var requirements: [SeparatedStrings]
    var orPresent: Bool
    
    init(requirements: [SeparatedStrings], orPresent: Bool) {
        self.requirements = requirements
        self.orPresent = orPresent
    }
}

class ScenarioDetailViewModelRewardsInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .rewardsInfo
    }
    
    var sectionTitle: String {
        return "Rewards"
    }
    
    var rowCount: Int {
        return rewards.count
    }
    
    var rewards: [SeparatedStrings]
    
    init(rewards: [SeparatedStrings]) {
        self.rewards = rewards
    }
}

class ScenarioDetailViewModelAchievesInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .achievesInfo
    }
    
    var sectionTitle: String {
        return "Achieves"
    }
    
    var rowCount: Int {
        return achieves.count
    }
    
    var achieves: [SeparatedStrings]
    
    init(achieves: [SeparatedStrings]) {
        self.achieves = achieves
    }
}

class ScenarioDetailViewModelScenarioSummaryItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .scenarioSummary
    }
    
    var sectionTitle: String {
        return "Summary"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var summary: String
    
    init(summary: String) {
        self.summary = summary
    }
    
}
class ScenarioDetailViewModelScenarioLocationItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .scenarioLocation
    }
    
    var sectionTitle: String {
        return "Location"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var location: String
    
    init(location: String) {
        self.location = location
    }
}
