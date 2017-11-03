//
//  CreateCampaignViewModelFromModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

protocol CaseCountable {
    static func countCases() -> Int
    static var caseCount: Int { get }
}
// Move these to separate files?
struct CreateCampaignTitleCellViewModel {
    
//    let campaignTitleTextField: String?
    let campaignTitleTextFieldPlaceholder: String
    
    init() {
        self.campaignTitleTextFieldPlaceholder = "Enter Campaign Title"
    }
}
struct CreateCampaignPartyNameCellViewModel {
    
    let createCampaignPartyNameTextFieldPlaceholder: String
    
    init() {
        self.createCampaignPartyNameTextFieldPlaceholder = "Enter Party Name"
    }
    
}

enum SectionTypes: Int, CaseCountable {
    
    case Title
    case Parties
    
    static let caseCount = SectionTypes.countCases()
}

class CreateCampaignViewModelFromModel: NSObject {
    
    let dataModel: DataModel
    var newCampaign = Campaign(title: "", parties: [], achievements: [:], prosperityCount: 0, sanctuaryDonations: 0, events: [], isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: true, ancientTechCount: 0)
    var parties = [String:Party]()
    let numberOfSections = SectionTypes.caseCount
    let sections = [SectionTypes.Title, SectionTypes.Parties]
    var titleCell: CreateCampaignTitleCell?
    var newCampaignTitle: String?
    var partyNameCell: CreateCampaignPartyCell?
    var newPartyName: String?
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var selectedRows = [Int]()
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
//        for party in dataModel.availableParties {
//            self.parties[party] = dataModel.parties[party]
//        }
    }

    fileprivate func returnTextFieldPlaceholderText() -> String {
        return "Select Party"
    }
    fileprivate func createCampaign(title: String, parties: [Party]) {
        dataModel.createCampaign(title: title, isCurrent: true, parties: parties)
        dataModel.saveCampaignsLocally()
    }
    fileprivate func createParty(name: String) {
        dataModel.createParty(name: name, characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: (newCampaignTitle!))
        print("Creating new party \(name) assigned to \(newCampaignTitle!)")
        dataModel.currentParty = dataModel.parties[name]
        dataModel.currentCampaign.parties!.append(dataModel.parties[name]!)
        dataModel.saveCampaignsLocally()
    }
}
extension CreateCampaignViewModelFromModel: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        //Temporary
//        let sectionType = sections[section]
//        switch sectionType {
//        case .Title:
//            return 1
//        case .Parties:
//            return parties.count == 0 ? 1 : parties.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.section]
        var tableViewCell: UITableViewCell
        
        switch sectionType {
        case .Title:
            let viewModel = CreateCampaignTitleCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignTitleCell.identifier) as! CreateCampaignTitleCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
            titleCell = cell
        case .Parties:
            let viewModel = CreateCampaignPartyNameCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignPartyCell.identifier) as! CreateCampaignPartyCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
            partyNameCell = cell
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = sections[section]
        switch sectionType {
        case .Title:
            return "Name new campaign"
        case .Parties:
            return "Name new party"
        }
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
}
extension CreateCampaignViewModelFromModel: CreateCampaignViewControllerDelegate {
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController) {
        // Try setting vmDelegate here
        newCampaignTitle = titleCell?.campaignTitleTextField.text
        if newCampaignTitle != "" {
            self.createCampaign(title: newCampaignTitle!, parties: [])
        } else {
            // Present alert controller telling them to put a name in title field
        }
        newPartyName = partyNameCell?.createCampaignPartyNameTextField.text
        if newPartyName != "" {
            self.createParty(name: newPartyName!)
            controller.dismiss(animated: true, completion: nil)
        } else {
            // Present alert controller
        }
    }
}

// provide a default implementation to count the cases for Int enums assuming starting at 0 and contiguous
extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    // count the number of cases in the enum
    static func countCases() -> Int {
        // starting at zero, verify whether the enum can be instantiated from the Int and increment until it cannot
        var count = 0
        while let _ = Self(rawValue: count) { count += 1 }
        return count
    }
}
