//
//  CreateCharacterViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/30/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

struct CreateCharacterCharacterNameCellViewModel {
    let createCharacterNameTextFieldPlaceholder: String
    
    init() {
        self.createCharacterNameTextFieldPlaceholder = "Enter Character Name"
    }
}
protocol CreateCharacterViewModelDelegate: class {
    func setCurrentCharacter(character: Character)
}
protocol CreateCharacterViewModelVCDelegate: class {
    func showFormAlert(alertText: String, message: String)
    func dismissSelf()
}

class CreateCharacterViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    var items = [CharacterDetailViewModelItem]()
    
    var nameCell: CreateCharacterCharacterNameCell?
    var typeCell: CharacterDetailCharacterTypeCell?
    var levelCell: CharacterDetailCharacterLevelCell?
    
    var newCharacterName: String?
    var newCharacterType: String?
    var newCharacterLevel = "1"
    
    var newCharacter = Character(name: "", race: "", type: "", level: 1, isActive: true, isRetired: false, assignedTo: "", playedScenarios: ["None"])
    var newCharacters = [String:Character]()
    var currentLevel: Double
    var currentLevelCell = UITableViewCell()

    var selectedCharacterRow: Int?
    var newCharacterIndex = "Character0"
    
    weak var delegate: CreateCharacterViewModelDelegate?
    weak var delegateVC: CreateCharacterViewModelVCDelegate?
    
    // Calls back to VC to refresh
    var reloadSection: ((_ section: Int) -> Void)?
    
    // For CreateCharacterPickerDelegate
    var characterTypePickerDidPick = false

    var selectedCharacterTypes: [String] {
        get {
            var tempTypes = [String]()
            if dataModel.assignedCharacters.isEmpty != true {
                for char in dataModel.assignedCharacters {
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
            let tempSelected = Set(selectedCharacterTypes)
            let tempDefaults = Set(characterTypePickerDataDefaults)
            return tempDefaults.symmetricDifference(tempSelected)
        }
    }
    var characterTypePickerDataDefaults = ["Beast Tyrant", "Berserker", "Brute", "Cragheart", "Doomstalker", "Elementalist", "Mindthief", "Nightshroud", "Plagueherald", "Quartermaster", "Sawbone", "Scoundrel", "Spellweaver", "Soothsinger", "Summoner", "Sunkeeper", "Tinkerer"]
    
    var selectedCharacterType = String()
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.currentLevel = newCharacter.level
    }
}
extension CreateCharacterViewModel: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return 3
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
            //                cell.delegate = self
            if dataModel.newCharacters[newCharacterIndex] != nil {
                item.level = String(Int(dataModel.newCharacters[newCharacterIndex]!.level))
            } else {
                //item.level = String(Int(1))
                item.level = String(Int(newCharacter.level))
            }
            //item.level = String(Int(newCharacter.level))
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
            if newCharacter.type == "" {
                item = CharacterDetailViewModelCharacterTypeItem(characterType: "Tap to select")
            } else {
                item = CharacterDetailViewModelCharacterTypeItem(characterType: newCharacter.type)
            }
            typeCell = cell
            cell.item = item
            tableViewCell = cell
        default:
            break
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name new character"
        case 1:
            return "Set new character level"
        case 2:
            return "Select character type"
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
        }
    }
}
extension CreateCharacterViewModel: CreateCharacterViewControllerDelegate {
    func createCharacterViewControllerDidCancel(_ controller: CreateCharacterViewController) {
        dataModel.newCharacters = [String:Character]()
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createCharacterViewControllerDidFinishAdding(_ controller: CreateCharacterViewController) {
        newCharacterName = nameCell?.createCharacterNameTextField.text
        newCharacterLevel = levelCell!.characterDetailCharacterLevelLabel.text!
        newCharacterType = typeCell?.characterDetailCharacterTypeLabel.text
        if newCharacterName != "" {
            if newCharacterType != "" && newCharacterType != "Tap to select"{
                dataModel.characters[newCharacterName!] = Character(name: newCharacterName!, race: "", type: newCharacterType!, level: Double(newCharacterLevel)!, isActive: false, isRetired: false, assignedTo: dataModel.currentParty.name, playedScenarios: ["None"])
                dataModel.saveCampaignsLocally()
                self.reloadSection!(2)
                delegateVC?.dismissSelf()
            } else {
                delegateVC?.showFormAlert(alertText: "Must specify a character type!", message: "Please select a character type.")
                dataModel.newCharacters = [String:Character]()
                self.reloadSection!(2)
            }
        } else {
            delegateVC?.showFormAlert(alertText: "Can't leave character name blank!", message: "Please choose a name for your character.")
            dataModel.newCharacters = [String:Character]()
            self.reloadSection!(2)
        }
    }
}
extension CreateCharacterViewModel: CharacterDetailCharacterLevelCellDelegate {
    func incrementCharacterLevel(value: Int) {
        let currentLevel = self.currentLevel
        print("Currentlevel: \(self.currentLevel)")
        var newLevel = Int(currentLevel) + value
        print("NewLevel = \(newLevel)")
        if value == -1 && currentLevel == 0 {
            newLevel = 0
        } else if value == 1  && currentLevel == 9 {
            newLevel = 9
        } else {
            print("Adding \(Double(value))")
            newCharacter.level += Double(value)
            self.currentLevel += Double(value)
        }
        if let cell = currentLevelCell as? CharacterDetailCharacterLevelCell {
            print("Getting here?")
            cell.characterDetailCharacterLevelLabel.text = "\(newLevel)"
        }
        //self.updateCharacterLevel()
        //dataModel.saveCampaignsLocally()
    }
}
extension CreateCharacterViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return characterTypePickerData.count
    }
    
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        characterTypePickerDidPick = true
        //selectedCharacterType = characterTypePickerData[row]
        selectedCharacterType = Array(characterTypePickerData.sorted(by: <))[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.textAlignment = .center
        //label?.text =  ("\(characterTypePickerData[row])")
        label?.text = ("\(Array(characterTypePickerData.sorted(by: <))[row])")
        return label!
    }
}
extension CreateCharacterViewModel: CreateCharacterPickerDelegate {
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
}
