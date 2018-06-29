//
//  CharacterDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/6/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

enum CharacterDetailViewModelItemType {
    case characterName
    case characterLevel
    case characterType
    case characterGoal
    case assignedParty
    case scenarioHistory
}

protocol CharacterDetailViewModelItem {
    var type: CharacterDetailViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

class CharacterDetailViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var dataModel = DataModel.sharedInstance
    var items = [CharacterDetailViewModelItem]()
    var character: Character
    var characterStatus: String {
        get {
            if character.isRetired {
                return "retired"
            } else if character.assignedTo == dataModel.currentParty.name && character.isActive == true {
                return "active"
            } else {
                return "inactive"
            }
        }
    }
    var currentNameCell = UITableViewCell()
    var currentLevelCell = UITableViewCell()
    var textFieldReturningCellType: CharacterDetailViewModelItemType?

    // For swipe to complete goal
    var myCompletedGoalTitle = String()
    var currentPartyAchievements: Dynamic<[String:Bool]>
    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    // For CreateCharacterDetailVC picker delegate
    var characterTypePickerDidPick = false
    var characterTypePickerData = ["Beast Tyrant", "Berserker", "Brute", "Cragheart", "Doomstalker", "Elementalist", "Mindthief", "Nightshroud", "Plagueherald", "Quartermaster", "Sawbone", "Scoundrel", "Spellweaver", "Soothsinger", "Summoner", "Sunkeeper", "Tinkerer"]
    var selectedCharacterType = String()
    
    // For CreateCampaignViewModelCharactersUpdateDelegate
    var updateCharactersForNewCampaign = false
    // Dynamics
    var assignedParty: Dynamic<String>
    var currentParty: Dynamic<String>
    var currentLevel: Dynamic<Double>
    //var characters: Dynamic<[String:Character]>
    var characters: Dynamic<[Character]>
    var inactiveCharacters: Dynamic<[Character]>
    var activeCharacters: Dynamic<[Character]>
    var retiredCharacters: Dynamic<[Character]>
    
    var statusIcon = UIImage()
    
    init(withCharacter character: Character) {
        self.character = character
        self.assignedParty = Dynamic(dataModel.characters[character.name]!.assignedTo!) // "None" is valid assignee
        self.currentLevel = Dynamic(dataModel.characters[character.name]!.level)
        //self.characters = Dynamic(dataModel.characters)
        self.characters = Dynamic(dataModel.assignedCharacters + dataModel.availableCharacters) //Test!!
        self.inactiveCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isActive == false })
        self.activeCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isActive == true })
        self.retiredCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isRetired == true })
        //self.retiredCharacters = Dynamic(dataModel.retiredCharacters) // Test 18/03/13
        self.currentParty = Dynamic(dataModel.currentParty.name)
        self.currentPartyAchievements = Dynamic(dataModel.currentParty.achievements)
        super.init()
        
        statusIcon = getStatusIcon(goal: character.goal)
        
        // Append character name to items
        let characterNameItem = CharacterDetailViewModelCharacterNameItem(name: character.name, status: characterStatus)
        items.append(characterNameItem)
        // Append character level to items
        let characterLevelItem = CharacterDetailViewModelCharacterLevelItem(level: String(character.level))
        items.append(characterLevelItem)
        // Append character type to items
//        let characterTypeItem = CharacterDetailViewModelCharacterTypeItem(characterType: character.type)
        let characterTypeItem = CharacterDetailViewModelCharacterTypeItem(characterType: SeparatedAttributedStrings(rowString: NSMutableAttributedString(string: character.type)))
        items.append(characterTypeItem)
        // Append character goal to items
        let characterGoalItem = CharacterDetailViewModelCharacterGoalItem(characterGoal: character.goal, statusIcon: statusIcon)
        items.append(characterGoalItem)
        // Append assigned party to items
        let assignedParty = CharacterDetailViewModelAssignedPartyItem(partyName: character.assignedTo!)
        items.append(assignedParty)
        // Append played scenarios to items
        let playedScenariosItem = CharacterDetailViewModelScenarioHistoryItem(scenarioTitles: character.playedScenarios!)
        items.append(playedScenariosItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNewCampaignCharacters), name: NSNotification.Name(rawValue: "updateAfterNewCampaignSelected"), object: nil)

    }
    // Helper methods
    func updateAssignedParty() {
        self.assignedParty.value = dataModel.characters[character.name]!.assignedTo!
    }
    func updateCurrentParty() {
        self.currentParty.value = dataModel.currentParty.name
    }
    func updateCharacterLevel() {
        self.currentLevel.value = dataModel.characters[character.name]!.level
    }
    func updateCharacters() {
        //self.characters.value = dataModel.characters
        self.characters.value = dataModel.assignedCharacters + dataModel.availableCharacters
    }
    func updateCharacter() {
        if self.updateCharactersForNewCampaign == true {
            self.character = self.characters.value.first!
            self.updateCharactersForNewCampaign = false
        } else {
            //
        }
    }
    func updateActiveStatus() {
        self.activeCharacters.value = dataModel.assignedCharacters.filter { $0.isActive == true }
        self.inactiveCharacters.value = dataModel.assignedCharacters.filter { $0.isActive == false && $0.isRetired == false }
        self.retiredCharacters.value = dataModel.assignedCharacters.filter { $0.isRetired == true && $0.isActive == false}
        //self.retiredCharacters.value = dataModel.retiredCharacters
    }
    func updatePartyAchievements() {
        self.currentPartyAchievements.value = dataModel.currentParty.achievements
    }
    func triggerSave() {
        dataModel.saveCampaignsLocally()
    }
    func toggleSection(section: Int) {
        reloadSection?(section)
    }
    func configureGoalSwipeButton(for goal: String) {
        let myGoal = goal+" personal quest"
        if currentPartyAchievements.value[myGoal] == false {
            myCompletedGoalTitle = "Set Completed"
        } else if currentPartyAchievements.value[myGoal] == true {
            myCompletedGoalTitle = "Set Uncompleted"
        } else {
            myCompletedGoalTitle = "Not Applicable"
        }
    }
    func getStatusIcon(goal: String) -> UIImage {
        let myGoal = goal+" personal quest"
        if currentPartyAchievements.value[myGoal] == true {
            statusIcon = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else {
            //
            statusIcon = #imageLiteral(resourceName: "scenarioBlankIcon")
        }
        return statusIcon
    }
}
extension CharacterDetailViewModel: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CharacterDetailCharacterLevelCellDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Call update maybe?!
        if self.items[section].type == .scenarioHistory {
            return character.playedScenarios!.count
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
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
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sectionNumber = indexPath.section
        var returnValue = [UITableViewRowAction]()
        let goal = character.goal
        let myGoal = goal+" personal quest"
        self.configureGoalSwipeButton(for: goal)
        if sectionNumber == 3 {
            let swipeToggleComplete = UITableViewRowAction(style: .normal, title: self.myCompletedGoalTitle) { action, index
                in
                if self.myCompletedGoalTitle == "Set Completed" {
                    self.dataModel.currentParty.achievements[myGoal] = true
                    self.currentPartyAchievements.value[myGoal] = true
                    self.toggleSection(section: 3)
                } else if self.myCompletedGoalTitle == "Set Uncompleted" {
                    self.dataModel.currentParty.achievements[myGoal] = false
                    self.currentPartyAchievements.value[myGoal] = false
                    self.toggleSection(section: 3)
                }
                self.updatePartyAchievements()
                self.dataModel.saveCampaignsLocally()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadParty"), object: nil) // Trigger setRequirementsMetForCurrentParty in Scenario VM
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUnlocks"), object: nil) // Trigger unlock for scenario in question
            }
            swipeToggleComplete.backgroundColor = colorDefinitions.scenarioSwipeBGColor
            returnValue = [swipeToggleComplete]
        }
        return returnValue
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.section]
        switch item.type {
        case .characterName:
            if let item = item as? CharacterDetailViewModelCharacterNameItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterNameCell.identifier, for: indexPath) as? CharacterDetailCharacterNameCell {
                cell.backgroundColor = UIColor.clear
                currentNameCell = cell
                item.name = character.name
                item.status = characterStatus
                cell.characterDetailNameTextField.isHidden = true
                cell.selectionStyle = .none
                cell.item = item
                return cell
            }
        case .characterLevel:
            if let item = item as? CharacterDetailViewModelCharacterLevelItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterLevelCell.identifier, for: indexPath) as? CharacterDetailCharacterLevelCell {
                currentLevelCell = cell
                cell.delegate = self
                cell.backgroundColor = UIColor.clear
                item.level = String(Int(character.level))
                cell.selectionStyle = .none
                cell.item = item
                return cell
            }
        case .characterType:
            if let item = item as? CharacterDetailViewModelCharacterTypeItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterTypeCell.identifier, for: indexPath) as? CharacterDetailCharacterTypeCell {
                var fancyType = SeparatedAttributedStrings(rowString: NSMutableAttributedString(string: ""))
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                for type in dataModel.availableCharacterTypesAttributed {
                    let cleanedType = type.rowString!.string.replacingOccurrences(of: " ", with: "")
                    let ultraCleanedType = cleanedType.replacingOccurrences(of: "\u{fffc}", with: "")
                    if ultraCleanedType == character.type {
                        fancyType = type
                    }
                }
                //item.characterType = character.type
                item.characterType = fancyType
                cell.item = fancyType
                return cell
            }
        case .characterGoal:
            if let item = item as? CharacterDetailViewModelCharacterGoalItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterGoalCell.identifier, for: indexPath) as? CharacterDetailCharacterGoalCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.characterGoal = character.goal
                cell.item = item
                return cell
            }
        case .assignedParty:
            if let item = item as? CharacterDetailViewModelAssignedPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailAssignedPartyCell.identifier, for: indexPath) as? CharacterDetailAssignedPartyCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.partyName = self.assignedParty.value
                cell.item = item
                return cell
            }
        case .scenarioHistory:
            if let _ = item as? CharacterDetailViewModelScenarioHistoryItem, let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailPlayedScenarioCell.identifier, for: indexPath) as? CharacterDetailPlayedScenarioCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                if character.playedScenarios! == ["None"] {
                    cell.title = "No played scenarios"
                } else {
                    cell.title = character.playedScenarios![indexPath.row]
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        //let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let itemType = self.items[section].type
        
        switch itemType {
            
        case .characterName:
            break
        case .characterLevel:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showUIStepperInCharacterLevelCell(_:)), for: .touchUpInside)
            header.addSubview(button)
            header.addConstraint(NSLayoutConstraint(item: button, attribute: .trailingMargin, relatedBy: .equal, toItem: header, attribute: .trailingMargin, multiplier: 0.99, constant: 0))
            header.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 0.5, constant: 0))
        case .characterType:
            break
        case .characterGoal:
            break
        case .assignedParty:
            break
        case .scenarioHistory:
            break
        }
    }

    // Called by edit button in Character Name header
    @objc func enableNameTextField(_ sender: UIButton) {
        let myCell = self.currentNameCell as! CharacterDetailCharacterNameCell
        let myTextField = myCell.characterDetailNameTextField!
        myTextField.delegate = self
        let oldText = myCell.characterDetailNameLabel.text
        myTextField.text = oldText
        myTextField.font = fontDefinitions.detailTableViewTitleFont
        myTextField.becomeFirstResponder()
        myTextField.selectedTextRange = myCell.characterDetailNameTextField.textRange(from: myCell.characterDetailNameTextField.beginningOfDocument, to: myCell.characterDetailNameTextField.endOfDocument)
        myCell.characterDetailNameLabel.isHidden = true
        myTextField.isHidden = false
        self.textFieldReturningCellType = .characterName
    }
    // Called by edit button in Character Level header
    @objc func showUIStepperInCharacterLevelCell(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        let myCell = self.currentLevelCell as! CharacterDetailCharacterLevelCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCharacterLevelCell(_:)), for: .touchUpInside)
    }
    @objc func hideUIStepperInCharacterLevelCell(_ button: UIButton) {
        let myCell = self.currentLevelCell as! CharacterDetailCharacterLevelCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCharacterLevelCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        dataModel.saveCampaignsLocally()
    }
    @objc func showCharacterTypePicker(_ button: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showCharacterTypePicker"), object: nil)
    }
    func hideAllControls() {
        let myLevelCell = self.currentLevelCell as! CharacterDetailCharacterLevelCell
        myLevelCell.myStepperOutlet.isHidden = true
        myLevelCell.myStepperOutlet.isEnabled = false
    }
    // Called from SelectCampaignVC DidSelect
    @objc func setNewCampaignCharacters() {
        self.updateCharactersForNewCampaign = true
    }
    // Delegate method for CharacterLevelCell
    func incrementCharacterLevel(value: Int) {
        let currentLevel = self.currentLevel.value
        var newLevel = Int(currentLevel) + value
        if value == -1 && currentLevel == 0 {
            newLevel = 0
        } else if value == 1  && currentLevel == 9 {
            newLevel = 9
        } else {
            dataModel.characters[character.name]!.level += Double(value)
        }
        if let cell = currentLevelCell as? CharacterDetailCharacterLevelCell {
            cell.characterDetailCharacterLevelLabel.text = "\(newLevel)"
        }
        self.updateCharacterLevel()
        dataModel.saveCampaignsLocally()
    }
}
extension CharacterDetailViewModel: CreateCharacterViewModelDelegate {
    func setCurrentCharacter(character: Character) {
        self.character = character
    }
}
extension CharacterDetailViewModel: SelectCharacterViewControllerDelegate {
    
    func deleteCharacter(character: Character, controller: SelectCharacterViewController) {
        if dataModel.characters.count == 1 {
            //Raise alert that we can't delete last character
            controller.showDisallowDeletionAlert()
        } else {
            dataModel.characters.removeValue(forKey: character.name)
            self.character = dataModel.characters.first!.value
            // Load new character here
            self.updateCharacters()
            self.updateAssignedParty()
            self.updateCharacterLevel()
            reloadSection!(0)
            dataModel.saveCampaignsLocally()
        }
    }
    
    func retireCharacter(character: Character) {
        character.isRetired = true
        character.assignedTo = "None"
        dataModel.characters[character.name]!.assignedTo = "None"
        dataModel.characters[character.name]?.isRetired = true
        self.updateAssignedParty()
        reloadSection!(0)
        reloadSection!(3)
        dataModel.saveCampaignsLocally()
    }

}
// MARK: ViewModelItem Classes
class CharacterDetailViewModelCharacterNameItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .characterName
    }
    
    var sectionTitle: String {
        return "Character Name"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var name: String
    var status: String
    
    init(name: String, status: String) {
        self.name = name
        self.status = status
    }
}
class CharacterDetailViewModelCharacterLevelItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .characterLevel
    }
    
    var sectionTitle: String {
        return "Character Level"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var level: String
    
    init(level: String) {
        self.level = level
    }
    
}
class CharacterDetailViewModelCharacterTypeItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .characterType
    }
    
    var sectionTitle: String {
        return "Character Type"
    }
    
    var rowCount: Int {
        return 1
    }
    
//    var characterType: String
//
//    init(characterType: String) {
//        self.characterType = characterType
//    }
    var characterType: SeparatedAttributedStrings
    
    init(characterType: SeparatedAttributedStrings) {
        self.characterType = characterType
    }
}
class CharacterDetailViewModelCharacterGoalItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .characterGoal
    }
    
    var sectionTitle: String {
        return "Character Goal"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var characterGoal: String
    var statusIcon: UIImage
    
    init(characterGoal: String, statusIcon: UIImage) {
        self.characterGoal = characterGoal
        self.statusIcon = statusIcon
    }
}
class CharacterDetailViewModelAssignedPartyItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .assignedParty
    }
    
    var sectionTitle: String {
        return "Assigned Party"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var partyName: String
    
    init(partyName: String) {
        self.partyName = partyName
    }
}
class CharacterDetailViewModelScenarioHistoryItem: CharacterDetailViewModelItem {
    
    var type: CharacterDetailViewModelItemType {
        return .scenarioHistory
    }
    
    var sectionTitle: String {
        return "Scenario History"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var scenarioTitles: [String]
    
    init(scenarioTitles: [String]) {
        self.scenarioTitles = scenarioTitles
    }
}
