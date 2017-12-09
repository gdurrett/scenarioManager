//
//  CreatePartyCharacterViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 12/2/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

struct CreatePartyCharacterCharacterNameCellViewModel {
    let createCharacterNameTextFieldPlaceholder: String
    
    init() {
        self.createCharacterNameTextFieldPlaceholder = "Enter Character Name"
    }
}
protocol CreatePartyCharacterViewModelDelegate: class {
    func showFormAlert(alertText: String, message: String)
    func doSegue()
}

class CreatePartyCharacterViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    var items = [CharacterDetailViewModelItem]()
    
    var nameCell: CreateCharacterCharacterNameCell?
    var typeCell: CharacterDetailCharacterTypeCell?
    var goalCell: CharacterDetailCharacterGoalCell?
    var levelCell: CharacterDetailCharacterLevelCell?
    
    var newCharacterName: String?
    var newCharacterType: String?
    var newCharacterGoal: String?
    var newCharacterLevel = "1"
    
    var newCharacter = Character(name: "", goal: "", type: "", level: 1, isActive: true, isRetired: false, assignedTo: "", playedScenarios: ["None"])
    var newCharacters = [String:Character]()
    var currentLevel: Double
    var currentLevelCell = UITableViewCell()
    
    var selectedCharacterRow: Int?
    var newCharacterIndex = "Character0"
    
    weak var delegate: CreatePartyCharacterViewModelDelegate?

    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    // For CreatePartyCharacterPickerDelegate
    var characterTypePickerDidPick = false
    
    var selectedCharacterTypes: [String] {
        get {
            var tempTypes = [String]()
            if dataModel.newCharacters.isEmpty != true {
                for char in dataModel.newCharacters.values {
                    tempTypes.append(char.type)
                }
                return tempTypes
            } else {
                return [""]
            }
        }
    }
    
    var characterTypePickerData: Set<String> {
        get {
            if selectedCharacterTypes == [""] {
                return Set(characterTypePickerDataDefaults)
            } else {
                let tempSelected = Set(selectedCharacterTypes)
                let tempDefaults = Set(characterTypePickerDataDefaults)
                return tempDefaults.symmetricDifference(tempSelected)
            }
        }
    }
    var characterTypePickerDataDefaults = ["Beast Tyrant", "Berserker", "Brute", "Cragheart", "Doomstalker", "Elementalist", "Mindthief", "Nightshroud", "Plagueherald", "Quartermaster", "Sawbone", "Scoundrel", "Spellweaver", "Soothsinger", "Summoner", "Sunkeeper", "Tinkerer"]
    
    var selectedCharacterType = String()
    
    // For CreateCharacterGoalPicker
    // For CharacterCharacterDetailVC picker delegate
    var selectedCharacterGoals: [String] {
        get {
            var tempTypes = [String]()
            if dataModel.assignedCharacters.isEmpty != true {
                for char in dataModel.assignedCharacters {
                    tempTypes.append(char.goal)
                }
                return tempTypes
            } else {
                return [""]
            }
            
        }
    }
    var characterGoalPickerDidPick = false
    var characterGoalPickerData: Set<String> {
        get {
            let tempSelectedGoals = Set(selectedCharacterGoals)
            let tempDefaultGoals = Set(characterGoalPickerDataDefaults)
            return tempDefaultGoals.symmetricDifference(tempSelectedGoals)
        }
    }
    var characterGoalPickerDataDefaults = ["A Helping Hand", "A Study of Anatomy", "Aberrant Slayer", "Augmented Abilities", "Battle Legend", "Elemental Samples", "Eternal Wanderer", "Fearess Stand", "Finding the Cure", "Goliath Toppler", "Greed is Good", "Implement of Light", "Law Bringer", "Merchant Class", "Piety in All Things", "Pounds of Flesh", "Seeker of Xorn", "Take Back the Trees", "The Fall of Man", "The Perfect Poison", "The Thin Places", "Trophy Hunt", "Vengeance", "Zealot of the Blood God"]
    
    var selectedCharacterGoal = String()
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.currentLevel = newCharacter.level
    }
}
extension CreatePartyCharacterViewModel: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableViewCell = UITableViewCell()
        if selectedCharacterRow != nil {
            newCharacterIndex = ("Character\(selectedCharacterRow!)")
        } else {
            selectedCharacterRow = 0
        }
        
        switch indexPath.section {
        case 0:
            let viewModel = CreateCharacterCharacterNameCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCharacterCharacterNameCell.identifier, for: indexPath) as! CreateCharacterCharacterNameCell
            if dataModel.newCharacters[newCharacterIndex] != nil {
                cell.createCharacterNameTextField.text = dataModel.newCharacters[newCharacterIndex]!.name
            } else {
                cell.configure(withViewModel: viewModel)
            }
            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.clear
            nameCell = cell
            tableViewCell = cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterLevelCell.identifier, for: indexPath) as! CharacterDetailCharacterLevelCell
            let item = CharacterDetailViewModelCharacterLevelItem(level: "1")
            currentLevelCell = cell
            if dataModel.newCharacters[newCharacterIndex] != nil {
                item.level = String(Int(dataModel.newCharacters[newCharacterIndex]!.level))
            } else {
                item.level = String(Int(newCharacter.level))
            }
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.item = item
            cell.delegate = self
            levelCell = cell
            cell.myStepperOutlet.isHidden = false
            tableViewCell = cell
        case 2:
            var item = CharacterDetailViewModelCharacterTypeItem(characterType: "None")
            let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterTypeCell.identifier, for: indexPath) as! CharacterDetailCharacterTypeCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if dataModel.newCharacters[newCharacterIndex] != nil && dataModel.newCharacters[newCharacterIndex]?.type != "" {
                item = CharacterDetailViewModelCharacterTypeItem(characterType: dataModel.newCharacters[newCharacterIndex]!.type)
            } else if newCharacter.type == "" {
                item = CharacterDetailViewModelCharacterTypeItem(characterType: "Tap to select")
            } else {
                item = CharacterDetailViewModelCharacterTypeItem(characterType: newCharacter.type)
            }
            typeCell = cell
            cell.item = item
            tableViewCell = cell
        case 3:
            var item = CharacterDetailViewModelCharacterGoalItem(characterGoal: "None")
            let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailCharacterGoalCell.identifier, for: indexPath) as! CharacterDetailCharacterGoalCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if newCharacter.goal == "" {
                item = CharacterDetailViewModelCharacterGoalItem(characterGoal: "Tap to select")
            } else {
                item = CharacterDetailViewModelCharacterGoalItem(characterGoal: newCharacter.goal)
            }
            goalCell = cell
            cell.item = item
            tableViewCell = cell
        default:
            break
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name new character"
        case 1:
            return "Set new character level"
        case 2:
            return "Select character type"
        case 3:
            return "Select character goal"
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
        if indexPath.section == 2 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showCharacterTypePicker"), object: nil)
        } else if indexPath.section == 3 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showCharacterGoalPicker"), object: nil)
        }
    }
}
extension CreatePartyCharacterViewModel: CreatePartyCharacterViewControllerDelegate {
    func createPartyCharacterViewControllerDidCancel(_ controller: CreatePartyCharacterViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createPartyCharacterViewControllerDidFinishAdding(_ controller: CreatePartyCharacterViewController) {
        newCharacterName = nameCell?.createCharacterNameTextField.text
        newCharacterLevel = levelCell!.characterDetailCharacterLevelLabel.text!
        newCharacterType = typeCell?.characterDetailCharacterTypeLabel.text
        newCharacterGoal = goalCell?.characterDetailCharacterGoalLabel.text
        let newCharactersIndex = ("Character\(selectedCharacterRow!)")
        
        if newCharacterName != "" {
            if newCharacterType != "" && newCharacterType! != "Tap to select" {
                if newCharacterGoal != "" && newCharacterGoal != "Tap to select" {
                    dataModel.newCharacters[newCharactersIndex] = Character(name: newCharacterName!, goal: newCharacterGoal!, type: newCharacterType!, level: Double(newCharacterLevel)!, isActive: false, isRetired: false, assignedTo: dataModel.currentParty.name, playedScenarios: ["None"])
                    delegate?.doSegue()
                } else {
                    delegate?.showFormAlert(alertText: "Must specify a character goal!", message: "Please select a character goal.")
                }
            } else {
                delegate?.showFormAlert(alertText: "Must specify a character type!", message: "Please select a character type.")
            }
        } else {
            delegate?.showFormAlert(alertText: "Can't leave character name blank!", message: "Please choose a name for your character.")
        }
    }
}
extension CreatePartyCharacterViewModel: CharacterDetailCharacterLevelCellDelegate {
    func incrementCharacterLevel(value: Int) {
        let currentLevel = self.currentLevel
        var newLevel = Int(currentLevel) + value
        if value == -1 && currentLevel == 0 {
            newLevel = 0
        } else if value == 1  && currentLevel == 9 {
            newLevel = 9
        } else {
            newCharacter.level += Double(value)
            self.currentLevel += Double(value)
        }
        if let cell = currentLevelCell as? CharacterDetailCharacterLevelCell {
            cell.characterDetailCharacterLevelLabel.text = "\(newLevel)"
        }
    }
}
extension CreatePartyCharacterViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnValue = Int()
        if pickerView.tag == 10 {
            returnValue = characterTypePickerData.count
        } else if pickerView.tag == 15 {
            returnValue = characterGoalPickerData.count
        }
        return returnValue
    }
    
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 10 {
            characterTypePickerDidPick = true
            selectedCharacterType = Array(characterTypePickerData.sorted(by: <))[row]
        } else if pickerView.tag == 15 {
            characterGoalPickerDidPick = true
            selectedCharacterGoal = Array(characterGoalPickerData.sorted(by: <))[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.textAlignment = .center
        if pickerView.tag == 10 {
            label?.text = ("\(Array(characterTypePickerData.sorted(by: <))[row])")
        } else if pickerView.tag == 15 {
            label?.text = ("\(Array(characterGoalPickerData.sorted(by: <))[row])")
        }
        return label!
    }
}
extension CreatePartyCharacterViewModel: CreatePartyCharacterPickerDelegate {
    // Delegate method and property for Create Character VC picker
    func setCharacterType() {
        let newCharactersIndex = ("Character\(selectedCharacterRow!)")
        if dataModel.newCharacters[newCharactersIndex] != nil {
            dataModel.newCharacters[newCharactersIndex]!.type = "" //Test reset if we change it
        }
        if characterTypePickerDidPick == false {
            self.newCharacter.type = Array(self.characterTypePickerData.sorted(by: <))[0]
        } else {
            characterTypePickerDidPick = true
            self.newCharacter.type = selectedCharacterType
        }
        self.reloadSection?(2)
    }
    // Delegate method and property for Character Detail VC goal picker
    func setCharacterGoal() {
        let newCharactersIndex = ("Character\(selectedCharacterRow!)")
        if dataModel.newCharacters[newCharactersIndex] != nil {
            dataModel.newCharacters[newCharactersIndex]!.goal = "" //Test reset if we change it
        }
        if characterGoalPickerDidPick == false {
            self.newCharacter.goal = Array(self.characterGoalPickerData.sorted(by: <))[0]
        } else {
            characterGoalPickerDidPick = true
            self.newCharacter.goal = selectedCharacterGoal
        }
        self.reloadSection?(2)
    }
}
