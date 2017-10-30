//
//  PartyDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/22/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

enum PartyDetailViewModelItemType {
    case partyName
    case reputation
    case characters
    case achievements
    case assignedCampaign
}

protocol PartyDetailViewModelItem {
    var type: PartyDetailViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

class PartyDetailViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var dataModel = DataModel.sharedInstance
    var party: Party!
    var items = [PartyDetailViewModelItem]()
    var characterNames = [SeparatedStrings]()
    var achievementNames = [SeparatedStrings]()
    var newAchievementNames = [SeparatedStrings]()
    // Dynamics
    var assignedCampaign: Dynamic<String>
    var availableCampaigns: Dynamic<[String]>
    var completedPartyAchievements: Dynamic<[String:Bool]>
    var partyName: Dynamic<String>
    var reputation: Dynamic<Int>
    var availableCharacters: Dynamic<[Character]>
    var assignedCharacters: Dynamic<[Character]>
    var allCharacters: Dynamic<[String]>
    // Other
    var currentPartyCell = UITableViewCell()
    var currentReputationCell = UITableViewCell()
    var shopPriceModifier = 0
    var myAssignedPartyTitle = String()
    var selectedCampaignSegmentIndex = 0
    var reloadSection: ((_ section: Int) -> Void)?
    var textFieldReturningCellType: PartyDetailViewModelItemType?
    var assignedCharacterNames = [SeparatedStrings]()
    
    init(withParty party: Party) {
        self.completedPartyAchievements = Dynamic(dataModel.completedPartyAchievements)
        self.partyName = Dynamic(dataModel.currentParty.name)
        self.assignedCampaign = Dynamic(dataModel.assignedCampaign) //String
        self.availableCampaigns = Dynamic(dataModel.availableCampaigns) // [String]
        self.reputation = Dynamic(dataModel.currentParty.reputation) //Int
        self.availableCharacters = Dynamic(dataModel.availableCharacters) // [Character]
        self.assignedCharacters = Dynamic(dataModel.assignedCharacters) // [Character]
        self.allCharacters = Dynamic(Array(dataModel.characters.keys)) // [String]
        super.init()
        
        // Append party name to items
        let partyNameItem = PartyDetailViewModelPartyNameItem(name: partyName.value)
        items.append(partyNameItem)
        // Append party reputation to items
        let reputationItem = PartyDetailViewModelPartyReputationItem(reputation: reputation.value, modifier: getShopPriceModifier(modifier: reputation.value))
        items.append(reputationItem)
        // Append assigned campaign to items
        let assignedCampaignItem = PartyDetailViewModelPartyCampaignItem(assignedCampaign: self.assignedCampaign.value)
        items.append(assignedCampaignItem)
        // Append assigned characters to items
        if self.assignedCharacters.value.isEmpty != true {
            for characterName in self.assignedCharacters.value {
                assignedCharacterNames.append(SeparatedStrings(rowString: characterName.name))
            }
        } else {
            assignedCharacterNames.append(SeparatedStrings(rowString: "No characters assigned"))
        }
        let characterNamesItem = PartyDetailViewModelPartyCharactersItem(names: assignedCharacterNames)
        items.append(characterNamesItem)
        // Append party achievements
        let localCompletedAchievements = party.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if localCompletedAchievements.isEmpty != true {
            for achievement in localCompletedAchievements {
                achievementNames.append(SeparatedStrings(rowString: achievement.key))
            }
        }
        let achievementsItem = PartyDetailViewModelPartyAchievementsItem(achievements: achievementNames)
        items.append(achievementsItem)
    }
    // Helper methods
    func toggleSection(section: Int) {
        reloadSection?(section)
    }
    func updateCurrentParty() {
        self.partyName.value = dataModel.currentParty.name
    }
    func updateAssignedCampaign() {
        self.assignedCampaign.value = dataModel.currentCampaign.title // Provisional
    }
    func updateReputationValue() {
        self.reputation.value = dataModel.currentParty.reputation
    }
    func updateAchievements() {
        self.completedPartyAchievements.value = dataModel.completedPartyAchievements
    }
    func updateCharacters() {
        self.allCharacters.value = Array(dataModel.characters.keys)
    }
    func updateAssignedCharacters() {
        self.assignedCharacters.value = Array(dataModel.assignedCharacters)
    }
    func updateAvailableCharacters() {
        self.availableCharacters.value = Array(dataModel.availableCharacters)
    }
    func getShopPriceModifier(modifier: Int) -> Int {
        var myModifier = 0
        switch self.reputation.value {
        case -20 ... -19:
            myModifier = 5
        case -18 ... -15:
            myModifier = 4
        case -14 ... -11:
            myModifier = 3
        case -10 ... -7:
            myModifier = 2
        case -6 ... -3:
            myModifier = 1
        case -2 ... 2:
            myModifier = 0
        case 3 ... 6:
            myModifier = -1
        case 7 ... 10:
            myModifier = -2
        case 11 ... 14:
            myModifier = -3
        case 15 ... 18:
            myModifier = -4
        case 19 ... 20:
            myModifier = -5
        default:
            break
        }
        return myModifier
    }
    // Method for Renaming Campaign Title
    func renameParty(oldTitle: String, newTitle: String) {
        if dataModel.parties[newTitle] == nil && oldTitle != newTitle { // Don't do anything if it's the same title or if there's already a party with the new title name
            dataModel.parties.changeKey(from: oldTitle, to: newTitle)
            dataModel.currentParty.name = newTitle
            //Test pick up new name for characters assigned
            for character in dataModel.assignedCharacters {
                if character.assignedTo == oldTitle {
                    character.assignedTo = newTitle
                }
            }
            dataModel.saveCampaignsLocally()
        }
    }
}
// MARK: Tableview Delegate and Datasource extension. Other cell delegate methods.
extension PartyDetailViewModel: UITableViewDataSource, UITableViewDelegate, PartyDetailReputationCellDelegate, UITextFieldDelegate {
    // MARK: TableView DataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //var returnValue = 0
        self.updateAchievements()
        
        if self.items[section].type == .achievements {
            if self.completedPartyAchievements.value.count == 0 {
                return 1
            } else {
                return self.completedPartyAchievements.value.count
            }
        } else if self.items[section].type == .characters {
            if self.assignedCharacters.value.count == 0 {
                return 1
            } else {
                return self.assignedCharacters.value.count
            }
        } else {
                return self.items[section].rowCount
            }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.section]
        switch item.type {
        case .partyName:
            if let item = item as? PartyDetailViewModelPartyNameItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailNameCell.identifier, for: indexPath) as? PartyDetailNameCell {
                cell.backgroundColor = UIColor.clear
                item.name = partyName.value
                // Set global party name cell to this cell
                currentPartyCell = cell
                // Set text field to hidden until edit is requested
                cell.partyDetailNameTextField.isHidden = true
                cell.selectionStyle = .none
                //cell.delegate = self
                cell.item = item
                return cell
            }
        case .reputation:
            if let item = item as? PartyDetailViewModelPartyReputationItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailReputationCell.identifier, for: indexPath) as? PartyDetailReputationCell {
                cell.delegate = self
                currentReputationCell = cell
                cell.backgroundColor = UIColor.clear
                item.reputation = reputation.value
                item.modifier = self.getShopPriceModifier(modifier: reputation.value)
                cell.item = item
                return cell
            }
        case .assignedCampaign:
            if let item = item as? PartyDetailViewModelPartyCampaignItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAssignedCampaignCell.identifier, for: indexPath) as? PartyDetailAssignedCampaignCell {
                cell.backgroundColor = UIColor.clear
                cell.item = item.assignedCampaign
                return cell
            }
        case .characters:
            if let _ = item as? PartyDetailViewModelPartyCharactersItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAssignedCharactersCell.identifier, for: indexPath) as? PartyDetailAssignedCharactersCell {
                cell.backgroundColor = UIColor.clear
                if self.assignedCharacters.value.isEmpty {
                    cell.item = SeparatedStrings(rowString: "No assigned characters")
                } else {
                    cell.item = SeparatedStrings(rowString: self.assignedCharacters.value[indexPath.row].name)
                }
                return cell
            }
        case .achievements:
            if let _ = item as? PartyDetailViewModelPartyAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAchievementsCell.identifier, for: indexPath) as? PartyDetailAchievementsCell {
                cell.backgroundColor = UIColor.clear
                var achievement = SeparatedStrings(rowString: "")
                var tempAch = Array(self.completedPartyAchievements.value.keys)
                if tempAch.isEmpty { tempAch = ["No completed party achievements"] }
                var achNames = [SeparatedStrings]()
                for ach in tempAch {
                    achNames.append(SeparatedStrings(rowString: ach))
                }
                achievement = achNames[indexPath.row]
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
        }
        return UITableViewCell()
    }
    // MARK: TableView Delegate methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if self.items[section].sectionTitle == "Campaign" {
//            return 80
//        } else {
            return 50
//        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView(frame: CGRect(x:0, y:0, width: tableView.frame.size.width, height: tableView.frame.size.height))
            let headerTitleLabel = UILabel(frame: CGRect(x:16, y:15, width: 42, height: 21))
            headerTitleLabel.text = self.items[section].sectionTitle
            headerTitleLabel.font = fontDefinitions.detailTableViewHeaderFont
            headerTitleLabel.textColor = colorDefinitions.mainTextColor
            headerView.backgroundColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
            headerTitleLabel.sizeToFit()
            createSectionButton(forSection: section, inHeader: headerView)
            headerView.addSubview(headerTitleLabel)
            return headerView
       // }
    }
    // Create section buttons
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        
        let itemType = self.items[section].type
        
        switch itemType {
            
        case .partyName:
            button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.enableTitleTextField(_:)), for: .touchUpInside)
            header.addSubview(button)
        case .reputation:
            button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showUIStepperInPartyReputationCell(_:)), for: .touchUpInside)
            header.addSubview(button)
            break //Temporary!
        case .achievements:
            break
        case .assignedCampaign:
            break //Temporary!
        case .characters:
            button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.loadSelectCharacterViewController(_:)), for: .touchUpInside)
            header.addSubview(button)
        }
    }
    // MARK: PartyReputationCell Delegate methods
    func updatePartyReputationCount(value: Int) {
        if let cell = currentReputationCell as? PartyDetailReputationCell {
            if value == -1 && reputation.value > -20 || value == +1 && reputation.value < 20 {
                dataModel.currentParty.reputation += value
            }
            updateReputationValue()
            dataModel.saveCampaignsLocally() //Probably remove when implementing buttons
            cell.partyDetailReputationLabel.sizeToFit()
            let sign = reputation.value < -2 ? "+" : ""
            cell.partyDetailReputationLabel.text = "\(reputation.value)      shop price modifier: \(sign)\(getShopPriceModifier(modifier: reputation.value))"
        }
    }
    // MARK: selector methods
    @objc func enableTitleTextField(_ sender: UIButton) {
        let myCell = self.currentPartyCell as! PartyDetailNameCell
        let myTextField = myCell.partyDetailNameTextField!
        myTextField.delegate = self
        let oldText = myCell.partyDetailNameLabel.text
        myTextField.text = oldText
        myTextField.font = fontDefinitions.detailTableViewTitleFont
        myTextField.becomeFirstResponder()
        myTextField.selectedTextRange = myCell.partyDetailNameTextField.textRange(from: myCell.partyDetailNameTextField.beginningOfDocument, to: myCell.partyDetailNameTextField.endOfDocument)
        myCell.partyDetailNameLabel.isHidden = true
        myTextField.isHidden = false
        self.textFieldReturningCellType = .partyName
    }
    @objc func showUIStepperInPartyReputationCell(_ button: UIButton) {
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        let myCell = self.currentReputationCell as! PartyDetailReputationCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInPartyReputationCell(_:)), for: .touchUpInside)
    }
    @objc func hideUIStepperInPartyReputationCell(_ button: UIButton) {
        let myCell = self.currentReputationCell as! PartyDetailReputationCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInPartyReputationCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
        dataModel.saveCampaignsLocally()
    }
    @objc func loadSelectCharacterViewController(_ button: UIButton) {
        // Alert here if there are no characters
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSelectCharacterVC"), object: nil)
    }
    
    // Delegate methods for textField in cell
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch self.textFieldReturningCellType! {
        case .partyName:
            let myCell = self.currentPartyCell as! PartyDetailNameCell
            let myLabel = myCell.partyDetailNameLabel
            let oldTitle = myLabel!.text!
            if textField.text != "" {
                myLabel?.text = textField.text
                textField.isHidden = true
                self.renameParty(oldTitle: oldTitle, newTitle: textField.text!)
            }
            myLabel?.isHidden = false
        default:
            break
        }
        return true
    }
}
// MARK: Select Character delegate methods
extension PartyDetailViewModel: SelectCharacterViewControllerDelegate {
    func selectCharacterViewControllerDidCancel(_ controller: SelectCharacterViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func selectCharacterViewControllerDidFinishSelecting(_ controller: SelectCharacterViewController) {
        // Need to gather array of selected characters here
        print(self.partyName.value)
        if !controller.selectedCharacters.isEmpty {
            for character in controller.selectedCharacters {
                dataModel.characters[character.name]!.assignedTo = self.partyName.value
                updateCharacters()
                updateAssignedCharacters()
                toggleSection(section: 3)
            }
        }
        if !controller.unassignedCharacters.isEmpty {
            for character in controller.unassignedCharacters {
                dataModel.characters[character.name]!.assignedTo = "None"
            }
            updateCharacters()
            updateAssignedCharacters()
            updateAvailableCharacters()
        }
        dataModel.saveCampaignsLocally()
        controller.dismiss(animated: true, completion: nil)
    }
}
// MARK: ViewModelItem Classes
class PartyDetailViewModelPartyNameItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .partyName
    }
    
    var sectionTitle: String {
        return "Party Name"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
class PartyDetailViewModelPartyCharactersItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .characters
    }
    
    var sectionTitle: String {
        return "Assigned Characters"
    }
    
    var rowCount: Int {
        return names.count
    }
    
    var names: [SeparatedStrings]
    
    init(names: [SeparatedStrings]) {
        self.names = names
    }
}
class PartyDetailViewModelPartyAchievementsItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .achievements
    }
    
    var sectionTitle: String {
        return "Party Achievements"
    }
    
    var rowCount: Int {
        return achievements.count
    }
    
    var achievements: [SeparatedStrings]
    
    init(achievements: [SeparatedStrings]) {
        self.achievements = achievements
    }
}
class PartyDetailViewModelPartyReputationItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .reputation
    }
    
    var sectionTitle: String {
        return "Reputation"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var reputation: Int
    var modifier: Int
    init(reputation: Int, modifier: Int) {
        self.reputation = reputation
        self.modifier = modifier
    }
}
class PartyDetailViewModelPartyCampaignItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .assignedCampaign
    }
    
    var sectionTitle: String {
        return "Campaign"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var assignedCampaign: String
    
    init(assignedCampaign: String) {
        self.assignedCampaign = assignedCampaign
    }
}









