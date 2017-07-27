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
    case achievesInfo
    //case scenarioSummary
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
    
    override init() {
        super.init()
        
        if let scenario = dataModel.selectedScenario {
            let titleItem = ScenarioDetailViewModelScenarioTitleItem(title: scenario.title)
            items.append(titleItem)
            let unlocksItem = ScenarioDetailViewModelUnlocksInfoItem(unlocks: scenario.unlocks)
            items.append(unlocksItem)
            let unlockedByItem = ScenarioDetailViewModelUnlockedByInfoItem(unlockedBys: scenario.unlockedBy)
            items.append(unlockedByItem)
            let achievesItem = ScenarioDetailViewModelAchievesInfoItem(achieves: scenario.achieves)
            items.append(achievesItem)
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
                cell.item = item
                return cell
            }
        case .unlocksInfo:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UnlocksInfoCell.identifier, for: indexPath) as? UnlocksInfoCell {
                cell.item = item
                return cell
            }
        case .unlockedByInfo:
            if let cell = tableView.dequeueReusableCell(withIdentifier: UnlockedByInfoCell.identifier, for: indexPath) as? UnlockedByInfoCell {
                cell.item = item
                return cell
            }
        case .achievesInfo:
            if let cell = tableView.dequeueReusableCell(withIdentifier: AchievesInfoCell.identifier, for: indexPath) as? AchievesInfoCell {
                cell.item = item
                return cell
            }
//        case .scenarioSummary:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: ScenarioSummaryCell.identifier, for: indexPath) as? ScenarioSummaryCell {
//                cell.item = item
//                return cell
//            }
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
        return "Scenario Info"
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
        return "Unlocks"
    }
    
    var rowCount: Int {
        return unlocks.count
    }
    
    var unlocks: [String]
    
    init(unlocks: [String]) {
        self.unlocks = unlocks
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
    
    var unlockedBys: [String]
    
    init(unlockedBys: [String]) {
        self.unlockedBys = unlockedBys
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
    
    var achieves: [String]
    
    init(achieves: [String]) {
        self.achieves = achieves
    }
}

//class ScenarioDetailViewModelScenarioSummaryItem: ScenarioDetailViewModelItem {
//    
//    var type: ScenarioDetailViewModelItemType {
//        return .scenarioSummary
//    }
//    
//    var sectionTitle: String {
//        return "Summary"
//    }
//    
//    var rowCount: Int {
//        return 1
//    }
//    
//    var summary: String
//    
//    init(summary: String) {
//        self.summary = summary
//    }
//}
