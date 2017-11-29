//
//  CreateCampaignViewModelFromModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

protocol CreateCampaignViewModelDelegate: class {
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
    func performSegue(withIdentifier: String, sender: Any?)
}
// Move these to separate files?
struct CreateCampaignTitleCellViewModel {
    
//    let campaignTitleTextField: String?
    let campaignTitleTextFieldPlaceholder: String
    
    init() {
        self.campaignTitleTextFieldPlaceholder = "Name campaign"
    }
}
struct CreateCampaignPartyNameCellViewModel {
    
    let createCampaignPartyNameTextFieldPlaceholder: String
    
    init() {
        self.createCampaignPartyNameTextFieldPlaceholder = "Name party"
    }
}
struct CreateCampaignCreateCharacterCellViewModel {
    var createCampaignCreateCharacterLabelText: String
    
    init() {
        self.createCampaignCreateCharacterLabelText = ""
    }
}
class CreateCampaignViewModelFromModel: NSObject {
    
    let dataModel: DataModel
    var newCampaign = Campaign(title: "", parties: [], achievements: [:], prosperityCount: 0, sanctuaryDonations: 0, events: [], isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: true, ancientTechCount: 0)
    var parties = [String:Party]()
    var titleCell: CreateCampaignTitleCell?
    var newCampaignTitle: String?
    var partyNameCell: CreateCampaignPartyCell?
    var newPartyName: String?
    var newCharacter1Name: String?
    var newCharacter2Name: String?
    var newCharacter3Name: String?
    var newCharacter4Name: String?
    var newCharacterNames = [String]()
    var newCharacters = [Character]()
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var selectedRows = [Int]()
    weak var delegate: CreateCampaignViewModelDelegate?
    
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
        print("Just created new campaign with party: \(parties[0].name)")
        dataModel.saveCampaignsLocally()
    }
    fileprivate func createParty(name: String) {
        dataModel.createParty(name: name, characters: newCharacters, location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: (newCampaignTitle!))
        print("Creating new party \(name) assigned to \(newCampaignTitle!)")
        dataModel.currentParty = dataModel.parties[name]
        //dataModel.currentCampaign.parties!.append(dataModel.parties[name]!)
        dataModel.saveCampaignsLocally()
    }
    fileprivate func createCharacter(name: String) {
        dataModel.createCharacter(name: name)
        dataModel.characters[name]!.assignedTo = newPartyName
        dataModel.characters[name]!.isActive = true
        newCharacters.append(dataModel.characters[name]!)
    }
}
extension CreateCampaignViewModelFromModel: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 4
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableViewCell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            let viewModel = CreateCampaignTitleCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignTitleCell.identifier) as! CreateCampaignTitleCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
            cell.separatorInset = .zero
            titleCell = cell
        case 1:
            let viewModel = CreateCampaignPartyNameCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignPartyCell.identifier) as! CreateCampaignPartyCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
            partyNameCell = cell
        case 2:
            var viewModel = CreateCampaignCreateCharacterCellViewModel()
            viewModel.createCampaignCreateCharacterLabelText = ("Add character \(indexPath.row)")
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignCharacterCell.identifier) as! CreateCampaignCharacterCell
            cell.accessoryType = .disclosureIndicator
            cell.createCampaignCharacterLabel.text = ("Add character \(indexPath.row + 1)")
            tableViewCell = cell
        default:
            break
        }
        return tableViewCell
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        var returnString = String()
//        switch section {
//        case 0:
//            returnString = "Name new campaign"
//            print("Section 0?")
//        case 1:
//            returnString = "Name new party"
//            print("Section 1?")
//        case 2:
//            returnString = "Create new character"
//        default:
//            break
//        }
//        return returnString
//    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            delegate!.performSegue(withIdentifier: "showCreateCharacterVC", sender: self)
        }
    }
}
extension CreateCampaignViewModelFromModel: CreateCampaignViewControllerDelegate {
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController) {
//        newCampaignTitle = controller.createCampaignCampaignNameTextField.text
//        newPartyName = controller.createCampaignPartyNameTextField.text
//        self.createParty(name: newPartyName!)
//        newCharacter1Name = controller.createCampaignCharacter1NameTextField.text
//        newCharacterNames.append(newCharacter1Name!)
//        
//        if let myCharacter2Name = controller.createCampaignCharacter2NameTextField.text, !myCharacter2Name.isEmpty {
//            newCharacterNames.append(myCharacter2Name)
//        }
//        if let myCharacter3Name = controller.createCampaignCharacter3NameTextField.text, !myCharacter3Name.isEmpty {
//            newCharacterNames.append(myCharacter3Name)
//        }
//        if let myCharacter4Name = controller.createCampaignCharacter4NameTextField.text, !myCharacter4Name.isEmpty {
//            newCharacterNames.append(myCharacter4Name)
//        }
        for name in newCharacterNames {
            createCharacter(name: name)
            dataModel.parties[newPartyName!]?.characters = newCharacters
        }
        self.createCampaign(title: newCampaignTitle!, parties: [dataModel.parties[newPartyName!]!])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAfterNewCampaignSelected"), object: nil)
        controller.dismiss(animated: true, completion: nil)
    }
}
