//
//  CreatePartyViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

protocol CreatePartyViewModelDelegate: class {
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
    func performSegue(withIdentifier: String, sender: Any?)
    var selectedCharacter: Character { get set }
    func showFormAlert(alertText: String, message: String)
}

struct CreatePartyPartyNameCellViewModel {
    let createPartyNameTextFieldPlaceholder: String
    
    init() {
        self.createPartyNameTextFieldPlaceholder = "Enter Party Name"
    }
}
struct CreatePartyCreateCharacterCellViewModel {
    var createPartyCreateCharacterLabelText: String
    
    init() {
        self.createPartyCreateCharacterLabelText = ""
    }
}
class CreatePartyViewModel: NSObject {
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    let currentCampaign: Campaign? // Need to assign when we load this from PartyDetailVM
    var newParty = Party(name: "", characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: "")
    var nameCell: CreatePartyPartyNameCell?
    var newPartyName: String?
    var selectedCharacterRow = 0
    var newCharacterNames = [String]()
    var newCharacters = [Character]()
    var characterCell = CreateCampaignCharacterCell()
    var selectedRows = [Int]()
    weak var delegate: CreatePartyViewModelDelegate?
    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.currentCampaign = dataModel.currentCampaign
    }
    
    fileprivate func returnTextFieldPlaceholderText() -> String {
        return "Select Party"
    }
    fileprivate func createParty(name: String) {
        dataModel.createParty(name: name, characters: newCharacters, location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: (dataModel.currentCampaign.title))
        dataModel.currentParty = dataModel.parties[name]
        dataModel.currentCampaign.parties!.append(dataModel.parties[name]!)
        dataModel.saveCampaignsLocally()
    }
}
extension CreatePartyViewModel: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
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
            let viewModel = CreatePartyPartyNameCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreatePartyPartyNameCell.identifier) as! CreatePartyPartyNameCell
            cell.configure(withViewModel: viewModel)
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            nameCell = cell
            newPartyName = cell.createPartyNameTextField.text
            tableViewCell = cell
        case 1:
            var viewModel = CreatePartyCreateCharacterCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignCharacterCell.identifier) as! CreateCampaignCharacterCell
            let newCharacterIndex = ("Character\(indexPath.row)")
            if dataModel.newCharacters[newCharacterIndex] == nil {
                viewModel.createPartyCreateCharacterLabelText = ("Add character \(indexPath.row)")
                cell.createCampaignCharacterLabel.text = ("Add character \(indexPath.row + 1)")
            } else {
                viewModel.createPartyCreateCharacterLabelText = (dataModel.newCharacters[newCharacterIndex]!).name
                cell.createCampaignCharacterLabel.text = (dataModel.newCharacters[newCharacterIndex]!).name
                cell.createCampaignCharacterLabel.textColor = colorDefinitions.scenarioTitleFontColor
            }
            characterCell = cell
            cell.accessoryType = .disclosureIndicator
            tableViewCell = cell
        default:
            break
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name new party"
        case 1:
            return "Add at least one character"
        default:
            break
        }
        return ""
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCharacterRow = indexPath.row
        if indexPath.section == 1 {
            delegate!.performSegue(withIdentifier: "showCreatePartyCharacterVC", sender: self)
        }
    }
}
extension CreatePartyViewModel: CreatePartyViewControllerDelegate {
    func createPartyViewControllerDidCancel(_ controller: CreatePartyViewController) {
        dataModel.newCharacters = [String:Character]()
        dataModel.newPartyName = String()
        dataModel.newCampaignName = String()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createPartyViewControllerDidFinishAdding(_ controller: CreatePartyViewController) {
        if newPartyName != "" {
            if dataModel.newCharacters.isEmpty != true {
            self.createParty(name: newPartyName!)
            for char in dataModel.newCharacters.values {
                dataModel.characters[char.name] = char
                char.assignedTo = newPartyName
                char.isActive = true
                char.isRetired = false
            }
            dataModel.newCharacters = [String:Character]()
            dataModel.newPartyName = String()
            dataModel.newCampaignName = String()
            dataModel.saveCampaignsLocally()
            controller.dismiss(animated: true, completion: nil)
            } else {
                delegate?.showFormAlert(alertText: "Must create at least one character.", message: "Please create a character.")
                reloadSection!(0)
            }
        } else {
            delegate?.showFormAlert(alertText: "Party name cannot be blank!", message: "Please type a name for the party.")
            reloadSection!(0)
        }

    }
}
