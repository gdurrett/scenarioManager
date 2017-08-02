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

class ScenarioDetailViewModel: NSObject {
    
    var scenario: Scenario!
    var items = [ScenarioDetailViewModelItem]()
    var dataModel = DataModel.sharedInstance
    var unlocks = [ScenarioNumberAndTitle]()
    //var unlockLabel = String()
    var unlockedBys = [ScenarioNumberAndTitle]()
    var requirements = [SeparatedStrings]()
    var requirementLabel = String()
    var orPresent = false
    var oneofPresent = false
    var rewards = [SeparatedStrings]()
    var achieves = [SeparatedStrings]()
    var cellBGColor = UIColor()
    
    override init() {
        super.init()
        
        if let scenario = dataModel.selectedScenario {
            if scenario.completed {
                cellBGColor = DataModel.sharedInstance.completedBGColor
            } else if scenario.isUnlocked && scenario.requirementsMet {
                cellBGColor = DataModel.sharedInstance.availableBGColor
            } else {
                cellBGColor = DataModel.sharedInstance.unavailableBGColor
            }
            let titleItem = ScenarioDetailViewModelScenarioTitleItem(title: scenario.title)
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
    
}

// Default number of rows to return if rows aren't specified
extension ScenarioDetailViewModelItem {
    var rowCount: Int {
        return 1
    }
}

extension ScenarioDetailViewModel: UITableViewDataSource {
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
                //Need to figure out how to skip section creation of None. This works, but we still get a section title, which creates a section.
                //if requirement.rowString != "None" {
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
    
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

class ScenarioDetailViewModelUnlocksInfoItem: ScenarioDetailViewModelItem {
    
    var type: ScenarioDetailViewModelItemType {
        return .unlocksInfo
    }
    
    var sectionTitle: String {
        if oneofPresent {
            return "Unlocks one of"
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
            return "Requirements (one of)"
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
