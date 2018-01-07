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
    case partyNotes
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
    var assignedAndActiveCharacters: Dynamic<[Character]>
    var allCharacters: Dynamic<[String]>
    var assignedParties: Dynamic<[Party]?>
    var currentParty: Dynamic<Party>
    var partyNotes: Dynamic<String>
    
    // Other
    var currentPartyCell = UITableViewCell()
    var currentReputationCell = UITableViewCell()
    var currentNotesCell = UITableViewCell()
    var shopPriceModifier = 0
    var myAssignedPartyTitle = String()
    var selectedCampaignSegmentIndex = 0
    var reloadSection: ((_ section: Int) -> Void)?
    var textFieldReturningCellType: PartyDetailViewModelItemType?
    var assignedCharacterNames = [SeparatedStrings]()
    var eventAchievementsPickerDidPick = false
    var eventAchievementsPickerDataDefaults = [ "A Map to Treasure", "Bad Business", "Debt Collection", "Fish's Aid", "Grave Job", "High Sea Escort", "Sin-Ra", "The Poison's Source", "Tremors", "Water Staff"]
    var eventAchievementsPickerData: Set<String> {
        get {
            var alreadyAchieved = [String]()

            for ach in eventAchievementsPickerDataDefaults {
                for party in dataModel.parties {
                    if party.value.achievements[ach] == true {
                        alreadyAchieved.append(ach)
                    }
                }
            }

            let tempDefaults = Set(eventAchievementsPickerDataDefaults)
            return tempDefaults.symmetricDifference(alreadyAchieved)
        }
    }

    var selectedEventAchievement: String?
    
    var partyScenarioLevel: Int {
        get {
            var sumOfLevels = Double()
            let numberOfCharacters = Double(assignedCharacters.value.filter { $0.isActive == true }.count)
            for character in self.assignedCharacters.value.filter({ $0.isActive == true }) {
                sumOfLevels += character.level
            }
            if numberOfCharacters == 0 {
                return 1
            } else {
                return Int(ceil((sumOfLevels/numberOfCharacters)/2))
            }
        }
    }
    init(withParty party: Party) {
        self.completedPartyAchievements = Dynamic(dataModel.completedPartyAchievements)
        self.partyName = Dynamic(dataModel.currentParty.name)
        self.assignedCampaign = Dynamic(dataModel.assignedCampaign) //String
        self.availableCampaigns = Dynamic(dataModel.availableCampaigns) // [String]
        self.reputation = Dynamic(dataModel.currentParty.reputation) //Int
        self.availableCharacters = Dynamic(dataModel.availableCharacters) // [Character]
        self.assignedCharacters = Dynamic(dataModel.assignedCharacters) // [Character]
        self.assignedAndActiveCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isActive == true }) // [Character]
        self.allCharacters = Dynamic(Array(dataModel.characters.keys)) // [String]
        self.assignedParties = Dynamic(dataModel.assignedParties)
        self.currentParty = Dynamic(dataModel.currentParty)
        self.partyNotes = Dynamic(dataModel.currentPartyNotes)
        super.init()
        
        
        // Append party name to items
        let partyNameItem = PartyDetailViewModelPartyNameItem(name: partyName.value, normalScenarioLevel: ("scenario level: \(self.partyScenarioLevel)"))
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
        // Append party notes
        let partyNotesItem = PartyDetailViewModelPartyNotesItem(notes: partyNotes.value)
        items.append(partyNotesItem)
    }
    // Helper methods
    func toggleSection(section: Int) {
        reloadSection?(section)
    }
    func updateCurrentPartyName() {
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
    func updateAssignedAndActiveCharacters() {
        self.assignedAndActiveCharacters.value = Array(dataModel.assignedCharacters.filter { $0.isActive == true })
    }
    func updateAssignedParties() {
        if dataModel.assignedParties != nil {
            self.assignedParties.value = Array(dataModel.assignedParties!)
        }
    }
    func updateCurrentParty() {
        self.currentParty.value = dataModel.currentParty
    }
    func updatePartyNotes() {
        self.partyNotes.value = dataModel.currentPartyNotes
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
    // Method for setting current party
    func setPartyActive(party: String) {
        //dataModel.loadParty(party: party)
        dataModel.currentParty = dataModel.parties[party]
        dataModel.saveCampaignsLocally()
    }
    // Method for Renaming Party
    func renameParty(oldTitle: String, newTitle: String) {
        if dataModel.parties[newTitle] == nil && oldTitle != newTitle { // Don't do anything if it's the same title or if there's already a party with the new title name
            dataModel.parties.changeKey(from: oldTitle, to: newTitle)
            dataModel.currentParty.name = newTitle
            for character in self.assignedCharacters.value {

                if character.assignedTo == oldTitle {
                    character.assignedTo = newTitle
                }
            }
            dataModel.saveCampaignsLocally()
        }
    }
}
// MARK: Table Delegate and Datasource extension. Other cell delegate methods.
extension PartyDetailViewModel: UITableViewDataSource, UITableViewDelegate, PartyDetailReputationCellDelegate, UITextViewDelegate {
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
            if self.assignedAndActiveCharacters.value.count == 0 {
                return 1
            } else {
                return self.assignedAndActiveCharacters.value.count
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
                //item.name = partyName.value
                item.name = ("\(partyName.value)")
                item.normalScenarioLevel = ("scenario level: \(partyScenarioLevel)")
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
                cell.selectionStyle = .none
                item.reputation = reputation.value
                item.modifier = self.getShopPriceModifier(modifier: reputation.value)
                cell.item = item
                return cell
            }
        case .assignedCampaign:
            if let _ = item as? PartyDetailViewModelPartyCampaignItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAssignedCampaignCell.identifier, for: indexPath) as? PartyDetailAssignedCampaignCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.item = self.assignedCampaign.value
                //cell.item = item.assignedCampaign
                return cell
            }
        case .characters:
            if let _ = item as? PartyDetailViewModelPartyCharactersItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAssignedCharactersCell.identifier, for: indexPath) as? PartyDetailAssignedCharactersCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                if self.assignedCharacters.value.isEmpty || self.assignedAndActiveCharacters.value.isEmpty {
                    cell.item = SeparatedStrings(rowString: "No assigned characters")
                    cell.partyDetailAssignedCharacterInfo.isHidden = true
                } else {
                    cell.partyDetailAssignedCharacterInfo.isHidden = false
                    cell.item = SeparatedStrings(rowString: self.assignedAndActiveCharacters.value[indexPath.row].name)
                    cell.partyDetailAssignedCharacterInfo.text = ("level \(Int(self.assignedAndActiveCharacters.value[indexPath.row].level)) \(self.assignedAndActiveCharacters.value[indexPath.row].type)")
                }
                return cell
            }
        case .achievements:
            if let _ = item as? PartyDetailViewModelPartyAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailAchievementsCell.identifier, for: indexPath) as? PartyDetailAchievementsCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                var achievement = SeparatedStrings(rowString: "")
                var tempAch = Array(self.completedPartyAchievements.value.keys).sorted(by: <)
                if tempAch.isEmpty { tempAch = ["No completed party achievements"] }
                var achNames = [SeparatedStrings]()
                for ach in tempAch {
                    achNames.append(SeparatedStrings(rowString: ach))
                }
                achievement = achNames[indexPath.row]
                cell.item = achievement
                return cell
            }
        case .partyNotes:
            if let item = item as? PartyDetailViewModelPartyNotesItem, let cell = tableView.dequeueReusableCell(withIdentifier: PartyDetailNotesCell.identifier, for: indexPath) as? PartyDetailNotesCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.notes = dataModel.currentPartyNotes
                currentNotesCell = cell
                cell.item = item
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
            return 50
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 5 {
            return 600
        } else {
            return 60
        }
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
    // Create section buttons
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        
        let itemType = self.items[section].type
        
        switch itemType {
            
        case .partyName:
            break
        case .reputation:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showUIStepperInPartyReputationCell(_:)), for: .touchUpInside)
            header.addSubview(button)
            break //Temporary!
        case .achievements:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.showEventAchievementsPicker(_:)), for: .touchUpInside)
            header.addSubview(button)
        case .assignedCampaign:
            break //Temporary!
        case .characters:
            break
        case .partyNotes:
            button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(self.enableNotesTextField(_:)), for: .touchUpInside)
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
            cell.partyDetailReputationLabel.text = "\(reputation.value)    shop price modifier: \(sign)\(getShopPriceModifier(modifier: reputation.value))"
        }
    }
    // MARK: selector methods
    @objc func enableNotesTextField(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        let myCell = self.currentNotesCell as! PartyDetailNotesCell
        let myTextField = myCell.NotesField!
        myTextField.isUserInteractionEnabled = true
        myTextField.delegate = self
        myTextField.font = UIFont(name: "Nyala", size: 20)
        myTextField.becomeFirstResponder()
        button.addTarget(self, action: #selector(self.disableNotesTextField(_:)), for: .touchUpInside)
    }
    @objc func disableNotesTextField(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        let myCell = self.currentNotesCell as! PartyDetailNotesCell
        let myTextField = myCell.NotesField!
        myTextField.isUserInteractionEnabled = false
        setNotes(text: myTextField.text)
        
        button.addTarget(self, action: #selector(self.enableNotesTextField(_:)), for: .touchUpInside)
    }
    @objc func showUIStepperInPartyReputationCell(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
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
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        dataModel.saveCampaignsLocally()
    }
    @objc func showEventAchievementsPicker(_ button: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showEventAchievementsPicker"), object: nil)
    }
    func hideAllControls() {
        let myReputationCell = self.currentReputationCell as! PartyDetailReputationCell
        myReputationCell.myStepperOutlet.isHidden = true
        myReputationCell.myStepperOutlet.isEnabled = false
        myReputationCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
    }
    func setNotes(text: String) {
        dataModel.currentPartyNotes = text
        //dataModel.currentParty.notes = text
        dataModel.saveCampaignsLocally()
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
extension PartyDetailViewModel: SelectPartyViewControllerDelegate {
    func selectPartyViewControllerDidCancel(_ controller: SelectPartyViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func selectPartyViewControllerDidFinishSelecting(_ controller: SelectPartyViewController) {
        print("Before switch, notes is: \(dataModel.currentPartyNotes)")
        dataModel.currentParty = controller.selectedParty
        self.updateCurrentPartyName()
        self.updateAssignedParties()
        print("After switch, notes is: \(dataModel.currentPartyNotes)")
        self.dataModel.saveCampaignsLocally()
        // Let CharacterDetailVC know that we've swapped characters
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAfterNewCampaignSelected"), object: nil)
        controller.dismiss(animated: true, completion: nil)
    }
}
extension PartyDetailViewModel: PartyDetailViewControllerDelegate {
    func partyDetailVCDidTapDelete(_ controller: PartyDetailViewController) {
        let currentParty = dataModel.currentParty.name
        if dataModel.assignedParties!.count > 1 {
            for character in dataModel.characters {
                let charName = character.value.name
                if character.value.assignedTo == currentParty {
                    dataModel.characters.removeValue(forKey: charName)
                }
            }
            dataModel.parties.removeValue(forKey: currentParty)
            dataModel.currentCampaign.parties = dataModel.currentCampaign.parties!.filter { $0.name != currentParty }
            let myParties = Array(dataModel.parties)
            myParties[0].value.isCurrent = true
            setPartyActive(party: myParties[0].value.name)
            self.updateAssignedAndActiveCharacters() // See if this works
            //self.updateCurrentParty()
            controller.partyDetailTableView.reloadData()
        } else {
            controller.showDisallowDeletionAlert()
        }
    }
}
extension PartyDetailViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eventAchievementsPickerData.count
    }
    
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventAchievementsPickerDidPick = true
        selectedEventAchievement = Array(eventAchievementsPickerData.sorted(by: <))[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.textAlignment = .center
        label?.text = ("\(Array(eventAchievementsPickerData.sorted(by: <))[row])")
        return label!
    }
}
extension PartyDetailViewModel: EventAchievementsPickerDelegate {
    
    func setEventAchievement() {
        if eventAchievementsPickerDidPick == false {
            selectedEventAchievement = Array(eventAchievementsPickerData).sorted(by: <)[0]
        }
        dataModel.currentParty.achievements[selectedEventAchievement!] = true
        self.updateAchievements()
        for scenario in dataModel.allScenarios {
            var tempRequirementsArray = scenario.requirements
            tempRequirementsArray.removeValue(forKey: "OR")
            for (ach, _) in tempRequirementsArray {
                if ach == selectedEventAchievement {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showUnlockScenarioAlert"), object: nil, userInfo: ["Scenario": scenario.title])
                }
            }
        }
        dataModel.saveCampaignsLocally()
        self.reloadSection!(4)
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
    var normalScenarioLevel: String
    
    init(name: String, normalScenarioLevel: String) {
        self.name = name
        self.normalScenarioLevel = normalScenarioLevel
    }
}
class PartyDetailViewModelPartyCharactersItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .characters
    }
    
    var sectionTitle: String {
        return "Active Characters"
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
class PartyDetailViewModelPartyNotesItem: PartyDetailViewModelItem {
    
    var type: PartyDetailViewModelItemType {
        return .partyNotes
    }
    
    var sectionTitle: String {
        return "Party Notes"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var notes: String
    
    init(notes: String) {
        self.notes = notes
    }
}









