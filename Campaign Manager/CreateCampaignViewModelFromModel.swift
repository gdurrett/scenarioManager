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
    var selectedCharacter: Character { get set }
    func showFormAlert(alertText: String, message: String)
}
// Move these to separate files?
struct CreateCampaignTitleCellViewModel {
    
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
    var newCampaign = Campaign(title: "", parties: [], achievements: [:], prosperityCount: 0, sanctuaryDonations: 0, events: [], isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: true, ancientTechCount: 0, availableCharacterTypes: [:], notes: "")
    var parties = [String:Party]()
    var titleCell: CreateCampaignTitleCell?
    var newCampaignTitle: String?
    var partyNameCell: CreateCampaignPartyCell?
    var newPartyName: String?
    var newCharacterNames = [String]()
    var newCharacters = [Character]()
    var selectedCharacterRow = 0
    var dataFilePath: URL

    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var selectedRows = [Int]()
    weak var delegate: CreateCampaignViewModelDelegate?
    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    // Set from appDelegate first time load
    var isFirstLoad: Bool?
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.dataFilePath = dataModel.dataFilePath()
        super.init()
        resetForNewCampaignCreation()
    }

    fileprivate func resetForNewCampaignCreation() {
        dataModel.newCharacters = [String:Character]()
        dataModel.newPartyName = String()
        dataModel.newCampaignName = String()
    }
    fileprivate func returnTextFieldPlaceholderText() -> String {
        return "Select Party"
    }
    fileprivate func createCampaign(title: String, parties: [Party]) {
        dataModel.createCampaign(title: title, isCurrent: true, parties: parties)
        dataModel.saveCampaignsLocally()
    }
    fileprivate func createParty(name: String) {
        dataModel.createParty(name: name, characters: newCharacters, location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: (newCampaignTitle!), notes: "")
        dataModel.currentParty = dataModel.parties[name]
        dataModel.saveCampaignsLocally()
    }
}
extension CreateCampaignViewModelFromModel: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
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
            newCampaignTitle = cell.campaignTitleTextField.text
        case 1:
            let viewModel = CreateCampaignPartyNameCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignPartyCell.identifier) as! CreateCampaignPartyCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
            partyNameCell = cell
            newPartyName = cell.createCampaignPartyNameTextField.text
        case 2:
            var viewModel = CreateCampaignCreateCharacterCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignCharacterCell.identifier) as! CreateCampaignCharacterCell
            let newCharacterIndex = ("Character\(indexPath.row)")
            if dataModel.newCharacters[newCharacterIndex] == nil {
                viewModel.createCampaignCreateCharacterLabelText = ("Add character \(indexPath.row)")
                cell.createCampaignCharacterLabel.text = ("Add character \(indexPath.row + 1)")
            } else {
                viewModel.createCampaignCreateCharacterLabelText = (dataModel.newCharacters[newCharacterIndex]!).name
                cell.createCampaignCharacterLabel.text = (dataModel.newCharacters[newCharacterIndex]!).name
                cell.createCampaignCharacterLabel.textColor = colorDefinitions.scenarioTitleFontColor
            }

            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.clear
            tableViewCell = cell
        default:
            break
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnString = String()
        switch section {
        case 0:
            returnString = "Name new campaign"
        case 1:
            returnString = "Name new party"
        case 2:
            returnString = "Add at least one character"
        default:
            break
        }
        return returnString
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCharacterRow = indexPath.row
        if indexPath.section == 2 {
            delegate!.performSegue(withIdentifier: "showCreateCampaignCharacterVC", sender: self)
        }
    }

}
extension CreateCampaignViewModelFromModel: CreateCampaignViewControllerDelegate {
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController) {
        dataModel.newCharacters = [String:Character]()
        dataModel.newPartyName = String()
        dataModel.newCampaignName = String()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController) {
        // Capture form errors here
        if newPartyName == "" || newCampaignTitle == "" {
            delegate?.showFormAlert(alertText: "Cannot leave fields blank!", message: "Both campaign title and party name must be specified.")
            reloadSection!(0)
        } else if dataModel.parties.contains(where: { $0.key == newPartyName! }) {
            delegate?.showFormAlert(alertText: "Already have a party by that name!", message: "Choose a different party name.")
            reloadSection!(0)
        } else {
            if dataModel.newCharacters.isEmpty == true {
                delegate?.showFormAlert(alertText: "Must create at least one character.", message: "Tap Add character 1 to create a character.")
            } else if dataModel.campaigns.contains(where: { $0.key == newCampaignTitle }) {
                delegate?.showFormAlert(alertText: "Already have a campaign by that title!", message: "Choose a different campaign title.")
                reloadSection!(0)
            } else {
                self.createParty(name: newPartyName!)
                for char in dataModel.newCharacters.values {
                    if dataModel.characters.contains(where: { $0.key == char.name }) {
                        delegate?.showFormAlert(alertText: "Already have a character by that name!", message: "Choose a different character name.")
                    } else if char.name == "" {
                        delegate?.showFormAlert(alertText: "Can't leave character name blank!", message: "Please choose a name for your character.")
                    } else if char.type == "" {
                        delegate?.showFormAlert(alertText: "Must specify a character type!", message: "Please select a character type.")
                    } else {
                        dataModel.characters[char.name] = char
                        char.assignedTo = newPartyName
                        char.isActive = true
                        char.isRetired = false
                    }
                }
                self.createCampaign(title: newCampaignTitle!, parties: [dataModel.parties[newPartyName!]!])
                dataModel.newCharacters = [String:Character]()
                dataModel.newPartyName = String()
                dataModel.newCampaignName = String()
                // Test branching based on if we're coming from first load version of VC
                if isFirstLoad == true {
                    dataModel.campaigns.removeValue(forKey: "MyCampaign")
                    dataModel.parties.removeValue(forKey: "MyParty")
                    dataModel.updateCampaignRecords() // Test initial schema creation here
                    delegate?.performSegue(withIdentifier: "showTabBarVC", sender: self)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAfterNewCampaignSelected"), object: nil)
                    controller.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
