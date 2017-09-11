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
    var rewards = [SeparatedAttributedStrings]()
    var achieves = [SeparatedStrings]()
    var cellBGColor = UIColor()
    var statusIcon = UIImage()
    var myLockedTitle: String?
    var myCompletedTitle: String?
    var bgColor: UIColor?
    var locationString = [String]()
    
    //    override init() {
    //        super.init()
    init(withScenario scenario: Scenario) {
        super.init()
        
        statusIcon = getStatusIcon(scenario: scenario)
        locationString = scenario.locationString.components(separatedBy: ", ")
        
        let titleItem = ScenarioDetailViewModelScenarioTitleItem(number: scenario.number, title: scenario.title, statusIcon: statusIcon)
        items.append(titleItem)
        
        let locationItem = ScenarioDetailViewModelScenarioLocationItem(location: scenario.locationString)
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
            var removeColon = false
            for requirement in scenario.requirements {
                
                if requirement.key == "None" {
                    break
                }
                
                if requirement.key == "OR" {
                    orPresent = true
                    continue
                }
                if requirement.key != "None" && requirement.value == true && !requirement.key.contains("personal quest"){
                    requirementLabel = "COMPLETE"
                } else if requirement.key != "None" && requirement.value == false {
                    requirementLabel = "INCOMPLETE"
                } else if requirement.key.contains("personal quest") {
                    removeColon = true
                    requirementLabel = ""
                } else {
                    requirementLabel = ""
                }
                if requirement.key != "None" {
                    if !removeColon {
                        requirements.append(SeparatedStrings(rowString:"\(requirement.key)" + ": " + "\(requirementLabel)"))
                    } else {
                        requirements.append(SeparatedStrings(rowString:"\(requirement.key)" + "\(requirementLabel)"))
                    }
                } else {
                    requirements.append(SeparatedStrings(rowString:requirement.key))
                }
            }
            let requirementsItem = ScenarioDetailViewModelRequirementsInfoItem(requirements: requirements, orPresent: orPresent)
            items.append(requirementsItem)
        }
        for reward in scenario.rewards {
            rewards.append(SeparatedAttributedStrings(rowString:reward))
        }
        if !scenario.rewards.contains(NSAttributedString(string: "None")) {
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
                achieves.append(SeparatedStrings(rowString: "LOSE: " + achieve))
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
    //MARK: Helper Functions
    
    func getStatusIcon(scenario: Scenario) -> UIImage {
        if scenario.isCompleted {
            statusIcon = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.isUnlocked && scenario.requirementsMet {
            //statusIcon = #imageLiteral(resourceName: "scenarioAvailableIcon")
        } else {
            statusIcon = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
        return statusIcon
    }
    func getScenario(scenarioNumber: String) -> Scenario? {
        
        if scenarioNumber == "None" || scenarioNumber == "ONEOF" || scenarioNumber.contains("Event") || scenarioNumber.contains("Envelope") {
            return nil
        } else {
            let scenInt = Int(scenarioNumber)!-1
            let scenario = dataModel.allScenarios[scenInt]
            
            return scenario
        }
    }
}

// MARK: Extensions
// Default number of rows to return if rows aren't specified
extension ScenarioDetailViewModelItem {
    var rowCount: Int {
        return 1
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
    
    var rewards: [SeparatedAttributedStrings]
    
    init(rewards: [SeparatedAttributedStrings]) {
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
