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

enum SectionTypes: Int, CaseCountable {
    
    case Title
    case Parties
    
    static let caseCount = SectionTypes.countCases()
}

class CreateCampaignViewModelFromModel: NSObject {
    
    let dataModel: DataModel
    var newCampaign = Campaign(title: "", parties: [], achievements: [:], prosperityCount: 0, sanctuaryDonations: 0, cityEvents: ["None"], roadEvents: ["None"], isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: true)
    var parties = [String:Party]()
    let numberOfSections = SectionTypes.caseCount
    let sections = [SectionTypes.Title, SectionTypes.Parties]
    var titleCell: CreateCampaignTitleCell?
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var selectedRows = [Int]()
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.parties = dataModel.parties
    }

    fileprivate func returnTextFieldPlaceholderText() -> String {
        return "Select Party"
    }
    fileprivate func createCampaign(title: String, parties: [Party]) {
        dataModel.createCampaign(title: title, isCurrent: true, parties: parties)
    }
}
extension CreateCampaignViewModelFromModel: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Temporary
        let sectionType = sections[section]
        switch sectionType {
        case .Title:
            return 1
        case .Parties:
            return parties.count == 0 ? 1 : parties.count
        }
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
            tableViewCell = cell
            titleCell = cell
        case .Parties:
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignPartyCell.identifier) as! CreateCampaignPartyCell
            let myParties = Array(self.parties.values)
            //cell.accessoryType = selectedRows.contains(indexPath.row) ? .checkmark : .none
            cell.selectionStyle = .none
            cell.createCampaignPartyLabel.text = myParties[indexPath.row].name
            cell.backgroundView?.alpha = 0.25
            cell.selectedBackgroundView?.alpha = 0.65
            tableViewCell = cell
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedRows.contains(indexPath.row) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            self.selectedRows = self.selectedRows.filter { $0 != indexPath.row }
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.selectedRows.append(indexPath.row)
        }
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = sections[section]
        switch sectionType {
        case .Title:
            return "Name new campaign"
        case .Parties:
            return "Assign parties to new campaign"
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
        var selectedParties = [Party]()
        let myParties = Array(self.parties.values)
        for row in selectedRows {
            selectedParties.append(myParties[row])
        }
        let newCampaignTitle = titleCell?.campaignTitleTextField.text
        if newCampaignTitle != "" {
            self.createCampaign(title: newCampaignTitle!, parties: selectedParties)
            controller.dismiss(animated: true, completion: nil)
        } else {
            // Present alert controller telling them to put a name in title field
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
