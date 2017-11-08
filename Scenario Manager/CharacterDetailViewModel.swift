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
    case assignedParty
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
            } else if character.assignedTo == dataModel.currentParty.name {
                return "active"
            } else {
                return "inactive"
            }
        }
    }
    var currentNameCell = UITableViewCell()
    var currentLevelCell = UITableViewCell()
    var textFieldReturningCellType: CharacterDetailViewModelItemType?
    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    // For CharacterDetailVC picker delegate
    var characterTypePickerDidPick = false
    var characterTypePickerData = ["Beast Tyrant", "Berserker", "Brute", "Cragheart", "Doomstalker", "Elementalist", "Mindthief", "Nightshroud", "Plagueherald", "Quartermaster", "Sawbone", "Scoundrel", "Spellweaver", "Soothsinger", "Summoner", "Sunkeeper", "Tinkerer"]
    var selectedCharacterType = String()
    
    // Dynamics
    var assignedParty: Dynamic<String>
    var currentLevel: Dynamic<Double>
    
    init(withCharacter character: Character) {
        self.character = character
        self.assignedParty = Dynamic(dataModel.characters[character.name]!.assignedTo!) // "None" is valid assignee
        self.currentLevel = Dynamic(dataModel.characters[character.name]!.level)
        super.init()
        
        
        // Append character name to items
        let characterNameItem = CharacterDetailViewModelCharacterNameItem(name: character.name, status: characterStatus)
        items.append(characterNameItem)
        // Append character level to items
        let characterLevelItem = CharacterDetailViewModelCharacterLevelItem(level: String(character.level))
        items.append(characterLevelItem)
        // Append character type to items
        let characterTypeItem = CharacterDetailViewModelCharacterTypeItem(characterType: character.type)
        items.append(characterTypeItem)
        // Append assigned party to items
        let assignedParty = CharacterDetailViewModelAssignedPartyItem(partyName: character.assignedTo!)
        items.append(assignedParty)
    }
    // Helper methods
    // Method for Renaming Character Name
    func renameCharacter(oldName: String, newName: String) {
        if dataModel.characters[newName] == nil && oldName != newName { // Don't do anything if it's the same name or if there's already a character with the new name
            dataModel.characters[oldName]!.name = newName
            dataModel.characters.changeKey(from: oldName, to: newName)
            for character in dataModel.characters { print("\(character.value.name)") }
            //let indexOfOldCharacter = dataModel.characters.index { $0.value === dataModel.characters[oldName] }
            //dataModel.assignedCharacters(indexOfOldCharacter[oldName]) = newName

            dataModel.saveCampaignsLocally()
        }
    }
    func updateAssignedParty() {
        self.assignedParty.value = dataModel.characters[character.name]!.assignedTo!
    }
    func updateCharacterLevel() {
        self.currentLevel.value = dataModel.characters[character.name]!.level
    }
}
extension CharacterDetailViewModel: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CharacterDetailCharacterLevelCellDelegate, CharacterDetailViewControllerPickerDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.characterType = character.type
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
        }
        return UITableViewCell()
    }
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        
        let itemType = self.items[section].type
        
        switch itemType {
            
        case .characterName:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.enableNameTextField(_:)), for: .touchUpInside)
            header.addSubview(button)
        case .characterLevel:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showUIStepperInCharacterLevelCell(_:)), for: .touchUpInside)
            header.addSubview(button)
        case .characterType:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showCharacterTypePicker(_:)), for: .touchUpInside)
            header.addSubview(button)
        case .assignedParty:
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
    // Delegate method for textField in cell
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch self.textFieldReturningCellType! {
        case .characterName:
            let myCell = self.currentNameCell as! CharacterDetailCharacterNameCell
            let myLabel = myCell.characterDetailNameLabel
            let oldName = myLabel!.text!
            if textField.text != "" {
                myLabel?.text = textField.text
                textField.isHidden = true
                self.renameCharacter(oldName: oldName, newName: textField.text!)
            }
            myLabel?.isHidden = false
        default:
            break
        }
        return true
    }
    // Delegate method for CharacterLevelCell
    func incrementCharacterLevel(value: Int) {
        let currentLevel = self.currentLevel.value
        print("Currentlevel: \(self.currentLevel.value)")
        var newLevel = Int(currentLevel) + value
        print("NewLevel = \(newLevel)")
        if value == -1 && currentLevel == 0 {
            newLevel = 0
        } else if value == 1  && currentLevel == 9 {
            newLevel = 9
        } else {
            print("Adding \(Double(value))")
            dataModel.characters[character.name]!.level += Double(value)
        }
        if let cell = currentLevelCell as? CharacterDetailCharacterLevelCell {
            print("Getting here?")
            cell.characterDetailCharacterLevelLabel.text = "\(newLevel)"
        }
        self.updateCharacterLevel()
        dataModel.saveCampaignsLocally()
    }
    // Delegate method and property for Character Detail VC picker
    func setCharacterType() {
        if characterTypePickerDidPick == false { self.selectedCharacterType = self.characterTypePickerData[0]
        } else {
            characterTypePickerDidPick = true
            self.character.type = selectedCharacterType
        }
        self.reloadSection?(2)
        self.dataModel.saveCampaignsLocally()
    }
    
}
extension CharacterDetailViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return characterTypePickerData.count
    }
    
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        characterTypePickerDidPick = true
        selectedCharacterType = characterTypePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.textAlignment = .center
            label?.text =  ("\(characterTypePickerData[row])")
        
        return label!
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
    
    var characterType: String
    
    init(characterType: String) {
        self.characterType = characterType
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
