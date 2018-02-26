//
//  CampaignDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

enum CampaignDetailViewModelItemType {
    case campaignTitle
    case parties
    case achievements
    case prosperity
    case donations
    case events
    case availableTypes
    case campaignNotes
}
protocol CampaignDetailPartyUpdaterDelegate: class {
    func reloadTableAfterSetPartyCurrent()
}
protocol CampaignDetailViewModelItem  {
    var type: CampaignDetailViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}
class CampaignDetailViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var dataModel = DataModel.sharedInstance
    var campaign: Campaign!
    var items = [CampaignDetailViewModelItem]()
    var partyNames = [SeparatedStrings]()
    var achievementNames = [SeparatedStrings]()
    //var newAchievementNames = [SeparatedStrings]()
    var eventNumbers = [SeparatedStrings]()
    var charTypes: [SeparatedAttributedStrings] {
        get {
            var tempTypes = [SeparatedAttributedStrings]()
            for type in dataModel.availableCharacterTypes {
                if type == "Beast Tyrant" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.beastTyrantString))
                } else if type == "Berserker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.berserkerString))
                } else if type == "Brute" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.bruteString))
                } else if type == "Cragheart" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.cragheartString))
                } else if type == "Elementalist" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.elementalistString))
                } else if type == "Mindthief" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.mindthiefString))
                } else if type == "Nightshroud" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.nightshroudString))
                } else if type == "Plagueherald" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.plagueheraldString))
                } else if type == "Quartermaster" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.quartermasterString))
                } else if type == "Sawbones" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.sawbonesString))
                } else if type == "Scoundrel" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.scoundrelString))
                } else if type == "Soothsinger" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.soothsingerString))
                } else if type == "Spellweaver" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.spellweaverString))
                } else if type == "Summoner" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.summonerString))
                } else if type == "Sunkeeper" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.sunkeeperString))
                } else if type == "Tinkerer" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.tinkererString))
                }
            }
            return tempTypes
        }
    }
    var dynamicCharTypes: Dynamic<[SeparatedAttributedStrings]>
    var lockedCharTypes: [SeparatedAttributedStrings] {
        get {
            var tempTypes = [SeparatedAttributedStrings]()
            for type in dataModel.lockedCharacterTypes {
                if type == "Beast Tyrant" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.beastTyrantString))
                } else if type == "Berserker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.berserkerString))
                } else if type == "Brute" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.bruteString))
                } else if type == "Cragheart" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.cragheartString))
                } else if type == "Elementalist" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.elementalistString))
                } else if type == "Mindthief" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.mindthiefString))
                } else if type == "Nightshroud" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.nightshroudString))
                } else if type == "Plagueherald" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.plagueheraldString))
                } else if type == "Quartermaster" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.quartermasterString))
                } else if type == "Sawbones" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.sawbonesString))
                } else if type == "Scoundrel" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.scoundrelString))
                } else if type == "Soothsinger" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.soothsingerString))
                } else if type == "Spellweaver" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.spellweaverString))
                } else if type == "Summoner" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.summonerString))
                } else if type == "Sunkeeper" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.sunkeeperString))
                } else if type == "Tinkerer" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: dataModel.tinkererString))
                }
            }
            return tempTypes
        }
    }
    var dynamicLockedCharTypes: Dynamic<[SeparatedAttributedStrings]>
    
    var isActiveCampaign: Bool?
    var remainingChecksUntilNextLevel = Int()
    var level = Int()
    var sanctuaryDonations = Int()
    var completedGlobalAchievements: Dynamic<[String:Bool]>
    var campaignTitle: Dynamic<String>
    var prosperityLevel: Dynamic<Int>
    var checksToNextLevel: Dynamic<Int>
    var donations: Dynamic<Int>
    var assignedParties: Dynamic<[Party]?>
    var availableParties: Dynamic<[Party]?>
    var unavailableEvents: Dynamic<[Event]>
    var availableEvents: Dynamic<[Event]>
    var completedEvents: Dynamic<[Event]>
    var ancientTechCount: Dynamic<Int>
    var currentPartyName: Dynamic<String>
    var availableTypes: Dynamic<[String:Bool]>
    var campaignNotes: Dynamic<String>
    // Convert to dynamic later
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()
    var storedOffsets = [Int: CGFloat]()
    var currentTitleCell = UITableViewCell()
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    var currentEventCell = CampaignDetailEventCell()
    var currentPartyCell = CampaignDetailPartyCell()
    var currentNotesCell = CampaignDetailNotesCell()
    
    var myCompletedEventTitle = String()
    var myAssignedPartyTitle = String()
    var myCharacterTypeSwipeButtonTitle = String()
    var myLockedTitle = String()
    
    var selectedEvent: Event?
    var selectedParty: String?
    var selectedEventsSegmentIndex = 1
    var selectedPartiesSegmentIndex = 0
    var selectedEventType = "road"
    var textFieldReturningCellType: CampaignDetailViewModelItemType?
    var disableEventSwipe = false
    var disablePartySwipe = false
    var gotTech = false // Used in cellForRow
    var reloadSection: ((_ section: Int) -> Void)?
    var scrollEventsSection: (() -> Void)?

    var selectedIndex: Int = 0 //For checkmarked row
    var prosperityBonus: Int {
        get {
            return (dataModel.currentCampaign.sanctuaryDonations / 50) == 2 ? 1 : max((dataModel.currentCampaign.sanctuaryDonations / 50) - 1, 0)
        }
    }
    
    // Try party reload delegate
    weak var partyReloadDelegate: CampaignDetailPartyUpdaterDelegate?
    
    // Vars for eventOptionPicker
    var eventOptionPickerData = ["A", "B"]
    var eventOptionPickerDidPick = false
    var selectedEventOption = String()
    // Vars for characterTypePicker
    var characterTypePickerDidPick = false
    
    var selectedCharacterType = SeparatedAttributedStrings(rowString: NSAttributedString(attributedString: NSAttributedString(string: "")))
    
    var dataFilePath: URL

    init(withCampaign campaign: Campaign) {
        self.completedGlobalAchievements = Dynamic(dataModel.completedGlobalAchievements)
        self.campaignTitle = Dynamic(dataModel.currentCampaign.title)
        self.prosperityLevel = Dynamic(0)
        self.checksToNextLevel = Dynamic(0)
        self.donations = Dynamic(dataModel.currentCampaign.sanctuaryDonations)
        self.assignedParties = Dynamic(dataModel.assignedParties)
        self.availableParties = Dynamic(dataModel.availableParties)
        self.unavailableEvents = Dynamic(dataModel.unavailableEvents)
        self.availableEvents = Dynamic(dataModel.availableEvents)
        self.completedEvents = Dynamic(dataModel.completedEvents)
        self.ancientTechCount = Dynamic(dataModel.currentCampaign.ancientTechCount)
        self.currentPartyName = Dynamic(dataModel.currentParty.name)
        self.availableTypes = Dynamic(dataModel.currentCampaign.availableCharacterTypes)
        self.dynamicCharTypes = Dynamic(dataModel.availableCharacterTypesAttributed)
        self.dynamicLockedCharTypes = Dynamic(dataModel.lockedCharacterTypesAttributed)
        self.campaignNotes = Dynamic(dataModel.currentCampaignNotes)
        self.dataFilePath = dataModel.dataFilePath()
        super.init()
        
        self.prosperityLevel = Dynamic(getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus))
        self.checksToNextLevel = Dynamic(getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus)), count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus))
        
        self.isActiveCampaign = campaign.isCurrent
        
        // Append campaign title to items
        let titleItem = CampaignDetailViewModelCampaignTitleItem(title: campaignTitle.value)
        items.append(titleItem)
        
        // Append prosperity level to items
        let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: getProsperityLevel(count: campaign.prosperityCount + self.prosperityBonus), remainingChecksUntilNextLevel: getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: campaign.prosperityCount + self.prosperityBonus)), count: campaign.prosperityCount + self.prosperityBonus))
        items.append(prosperityItem)
        
        // Append donations amount to items
        let donationsItem = CampaignDetailViewModelCampaignDonationsItem(amount: donations.value, prosperityBonusString: "")
        items.append(donationsItem)
        
        // Append available character types
        let tempCharTypes = charTypes.sorted { $0.rowString!.string < $1.rowString!.string }
        //let charTypesItem = CampaignDetailViewModelCharacterTypeItem(availableTypes: charTypes)
        let charTypesItem = CampaignDetailViewModelCharacterTypeItem(availableTypes: tempCharTypes)

        items.append(charTypesItem)
        
        // Append Assigned party
        let partyItem = CampaignDetailViewModelCampaignPartyItem(names: [SeparatedStrings(rowString: self.currentPartyName.value)])
        items.append(partyItem)
        
        // Append completed achievements to items
        let localCompletedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if localCompletedAchievements.isEmpty != true {
            for achievement in localCompletedAchievements {
                if achievement.key.contains("Ancient Technology:1") || achievement.key.contains("Ancient Technology:2") || achievement.key.contains("Ancient Technology:3") || achievement.key.contains("Ancient Technology:4") || achievement.key.contains("Ancient Technology:5") {
                    gotTech = true
                } else {
                    achievementNames.append(SeparatedStrings(rowString: achievement.key))
                }
            }
        }
        if gotTech == true { achievementNames.append(SeparatedStrings(rowString: "Ancient Technology")) }
        let achievementsItem = CampaignDetailViewModelCampaignAchievementsItem(achievements: achievementNames)
        items.append(achievementsItem)
        
        // Append city event items
        for event in campaign.events {
            eventNumbers.append(SeparatedStrings(rowString: event.number))
        }
        let eventItem = CampaignDetailViewModelCampaignEventsItem(numbers: eventNumbers)
        items.append(eventItem)
        let campaignNotesItem = CampaignDetailViewModelCampaignNotesItem(notes: campaignNotes.value)
        items.append(campaignNotesItem)

    }
    // Helper methods
    func getProsperityLevel(count: Int) -> Int {
        switch (count) {
        case 0...3:
            level = 1
        case 4...8:
            level = 2
        case 9...14:
            level = 3
        case 15...21:
            level = 4
        case 22...29:
            level = 5
        case 29...38:
            level = 6
        case 39...49:
            level = 7
        case 50...63:
            level = 8
        case 64:
            level = 9
        default:
            break
        }
        return level
    }
    func getRemainingChecksUntilNextLevel(level: Int, count: Int) -> Int {
        var remaining = 0
        switch (level) {
        case 1:
            remaining = 4 - count
        case 2:
            remaining = 9 - count
        case 3:
            remaining = 15 - count
        case 4:
            remaining = 22 - count
        case 5:
            remaining = 29 - count
        case 6:
            remaining = 39 - count
        case 7:
            remaining = 50 - count
        case 8:
            remaining = 64 - count
        case 9:
            remaining = 0
        default:
            break
        }
        return remaining
    }
    func getSanctuaryDonations(campaign: Campaign) -> Int {
        return campaign.sanctuaryDonations
    }

    func updateAchievements() {
        self.completedGlobalAchievements.value = dataModel.completedGlobalAchievements
    }
    func updateCampaignTitle() {
        self.campaignTitle.value = dataModel.currentCampaign.title
    }
    func updateProsperityLevel() {
        self.prosperityLevel.value = getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + prosperityBonus)
    }
    func updateChecksToNextLevel() {
        self.checksToNextLevel.value = getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus)), count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus)
    }
    func updateDonations() {
        self.donations.value = dataModel.currentCampaign.sanctuaryDonations
    }
    func updateAssignedParties() {
        self.assignedParties.value = dataModel.assignedParties
    }
    func updateAvailableParties() {
        self.availableParties.value = dataModel.availableParties
    }
    func updateCurrentParty() {
        self.currentPartyName.value = dataModel.currentParty.name
    }
    func updateEvents() {
        self.unavailableEvents.value = dataModel.unavailableEvents
        self.completedEvents.value = dataModel.completedEvents
        self.availableEvents.value = dataModel.availableEvents
    }
    func updateAncientTech() {
        self.ancientTechCount.value = dataModel.currentCampaign.ancientTechCount
    }
    func updateAvailableCharTypes() {
        self.availableTypes.value = dataModel.currentCampaign.availableCharacterTypes
        self.dynamicCharTypes.value = dataModel.availableCharacterTypesAttributed
        self.dynamicLockedCharTypes.value = dataModel.lockedCharacterTypesAttributed
    }
    func updateCampaignNotes() {
        self.campaignNotes.value = dataModel.currentCampaignNotes
    }
    func configureEventSwipeButton(for event: Event) {
        let eventTokens = event.number.components(separatedBy: " ")
        let eventInt = Int(eventTokens[1])
        if event.isCompleted {
            myCompletedEventTitle = "Set Uncompleted"
        } else if event.isAvailable && !event.isCompleted {
            myCompletedEventTitle = "Set Completed"
        } else {
            myCompletedEventTitle = "Set Available"
        }
        if event.isAvailable && !event.isCompleted && eventInt! > 30 {
            myLockedTitle = "Set Unavailable"
        } else {
            myLockedTitle = ""
        }
    }
    func configurePartySwipeButton(for partyName: String) {
        if let party = dataModel.parties[partyName] {
            if party.assignedTo == "None" {
                myAssignedPartyTitle = "Assign"
            } else {
                myAssignedPartyTitle = "Unassign"
            }
        }
    }
    func configureCharacterTypeSwipeButton(for type: String) {
        var currentCharacterTypes = [String]()
        for char in dataModel.characters {
            if char.value.assignedTo == dataModel.currentParty.name {
                currentCharacterTypes.append(char.value.type)
            }
        }
        if type == "Brute" || type == "Cragheart" || type == "Mindthief" || type == "Scoundrel" || type == "Spellweaver" || type == "Tinkerer" {
            myCharacterTypeSwipeButtonTitle = "Starting character"
        } else if currentCharacterTypes.contains(type) {
            myCharacterTypeSwipeButtonTitle = "Character type in use"
        }else {
            myCharacterTypeSwipeButtonTitle = "Lock"
        }
    }
    // Methods for CampaignProsperity cell
    func updateCampaignProsperityCount(value: Int) {
        let (level, count) = (self.updateProsperityCount(value: value))
        let remainingChecks = self.getRemainingChecksUntilNextLevel(level: level, count: count)
        let checksText = remainingChecks > 1 ? "checks" : "check"
        // Try updating to catch prosperityBonus increments
        self.updateChecksToNextLevel()
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.campaignDetailProsperityLabel.text = "\(level)      \(remainingChecks) \(checksText) to next level"
        }
    }
    func updateProsperityCount(value: Int) -> (Int, Int) {
        let count = dataModel.currentCampaign.prosperityCount + self.prosperityBonus
        if value == -1 && count == 0 {
            return (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus), 0)
        } else {
            dataModel.currentCampaign.prosperityCount += value
            return (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus), dataModel.currentCampaign.prosperityCount + prosperityBonus)
        }
    }
    // Method for CampaignDonations cell
    func updateCampaignDonationsCount(value: Int) {
        let tempDonationsAmount = dataModel.currentCampaign.sanctuaryDonations + value
        if tempDonationsAmount < 0 {
            // Don't let value go below 0
        } else {
            dataModel.currentCampaign.sanctuaryDonations += value
            if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
                if dataModel.currentCampaign.sanctuaryDonations < 100 { // Don't show this until we've reached initial milestone
                    cell.campaignDetailDonationsLabel.text = "\(dataModel.currentCampaign.sanctuaryDonations)"
                } else {
                    cell.campaignDetailDonationsLabel.text = "\(dataModel.currentCampaign.sanctuaryDonations)      prosperity bonus: +\(prosperityBonus)"
                }
            }
        }
    }
    // Method for Renaming Campaign Title
    func renameCampaignTitle(oldTitle: String, newTitle: String) {
        if dataModel.campaigns[newTitle] == nil && oldTitle != newTitle { // Don't do anything if it's the same title or if there's already a campaign with the new title name
            dataModel.campaigns.changeKey(from: oldTitle, to: newTitle)
            dataModel.currentCampaign.title = newTitle
            for party in dataModel.currentCampaign.parties! {
                party.assignedTo = newTitle
            }
            dataModel.saveCampaignsLocally()
        }
    }

    // Method for changing active campaign
    func setCampaignActive(campaign: String) {
        dataModel.loadCampaign(campaign: campaign)
        dataModel.saveCampaignsLocally()
        for (section, header) in headersToUpdate {
            createSectionButton(forSection: section, inHeader: header)
        }
    }
    func setPartyActive(party: String) {
        dataModel.loadParty(party: party)
        dataModel.currentParty = dataModel.parties[party]
        dataModel.saveCampaignsLocally()
    }
}
extension CampaignDetailViewModel: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CampaignDetailTitleCellDelegate, CampaignDetailProsperityCellDelegate, CampaignDetailDonationsCellDelegate {
    
    // TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        self.updateEvents()
        self.updateAssignedParties()
        self.updateAchievements()
        self.updateAncientTech()
        
        if self.items[section].type == .achievements {
            if self.completedGlobalAchievements.value.count == 0 {
                return 1
            } else {
                if self.dataModel.currentCampaign.ancientTechCount > 1 {
                    return self.completedGlobalAchievements.value.count - (self.ancientTechCount.value - 1)
                } else {
                    return self.completedGlobalAchievements.value.count
                }
            }
        } else if self.items[section].type == .availableTypes {
            return dataModel.availableCharacterTypesAttributed.count
        } else if self.items[section].type == .events {
            switch selectedEventsSegmentIndex {
            case 0:
                let myCount = self.unavailableEvents.value.filter { $0.type.rawValue == self.selectedEventType }
                returnValue = myCount.count
            case 1:
                let myCount = self.availableEvents.value.filter { $0.type.rawValue == self.selectedEventType }
                returnValue = myCount.count
            case 2:
                let myCount = self.completedEvents.value.filter { $0.type.rawValue == self.selectedEventType }.count
                if myCount == 0 {
                    returnValue = 1
                } else {
                    returnValue = myCount
                }
            default:
                break
            }
        } else if self.items[section].type == .parties {
            returnValue = 1
        } else {
            returnValue = self.items[section].rowCount
        }
        return returnValue
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.section]
        switch item.type {
        case .campaignTitle:
            if let item = item as? CampaignDetailViewModelCampaignTitleItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailTitleCell.identifier, for: indexPath) as? CampaignDetailTitleCell {
                cell.backgroundColor = UIColor.clear
                item.title = campaignTitle.value
                // Set global title cell to this cell
                currentTitleCell = cell
                // Set text field to hidden until edit is requested
                cell.campaignDetailTitleTextField.isHidden = true
                cell.selectionStyle = .none
                cell.delegate = self
                // Give proper status to isActive button in this cell
                cell.isActive = (self.isActiveCampaign == true ? true : false)
                cell.item = item
                return cell
            }
        case .prosperity:
            if let item = item as? CampaignDetailViewModelCampaignProsperityItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailProsperityCell.identifier, for: indexPath) as? CampaignDetailProsperityCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                self.updateChecksToNextLevel()
                item.level = prosperityLevel.value //+ self.prosperityBonus
                item.remainingChecksUntilNextLevel = checksToNextLevel.value
                cell.delegate = self
                cell.item = item
                currentProsperityCell = cell
                return cell
            }
        case .donations:
            if let item = item as? CampaignDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.amount = donations.value
                if dataModel.currentCampaign.sanctuaryDonations < 100 {
                    item.prosperityBonusString = ""
                } else {
                    item.prosperityBonusString = "     prosperity bonus: +\(self.prosperityBonus)"
                }
                cell.delegate = self
                cell.isActive = (self.isActiveCampaign == true ? true : false)
                cell.item = item
                currentDonationsCell = cell
                return cell
            }
        case .parties:
            if let _ = item as? CampaignDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                currentPartyCell = cell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                let party = SeparatedStrings(rowString: self.currentPartyName.value)
                cell.item = party
                return cell
            }
        case .achievements:
            if let _ = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                cell.backgroundColor = UIColor.clear
                var achievement = SeparatedStrings(rowString: "")
                var tempAch = Array(self.completedGlobalAchievements.value.keys).sorted(by: <)
                if tempAch.isEmpty { tempAch = ["No completed global achievements"] }
                var achNames = [SeparatedStrings]()
                gotTech = false
                for ach in tempAch {
                    if ach.contains("Ancient Technology:1") || ach.contains("Ancient Technology:2") || ach.contains("Ancient Technology:3") || ach.contains("Ancient Technology:4") || ach.contains("Ancient Technology:5") {
                        gotTech = true
                    } else {
                        achNames.append(SeparatedStrings(rowString: ach))
                    }
                }
                if gotTech == true { achNames.insert(SeparatedStrings(rowString: ("Ancient Technology (\(dataModel.currentCampaign.ancientTechCount))")), at: 0) }
                achievement = achNames[indexPath.row]
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
        case .events:
            if let _ = item as? CampaignDetailViewModelCampaignEventsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailEventCell.identifier, for: indexPath) as? CampaignDetailEventCell {
                var names = [SeparatedStrings]()
                cell.backgroundColor = UIColor.clear
                currentEventCell = cell
                switch selectedEventsSegmentIndex {
                case 0:
                    let tempArray = Array(self.unavailableEvents.value).filter { $0.type.rawValue == selectedEventType }
                    for event in tempArray {
                        names.append(SeparatedStrings(rowString: event.number))
                    }
                case 1:
                    let tempArray = Array(self.availableEvents.value).filter { $0.type.rawValue == selectedEventType }
                    for event in tempArray {
                        names.append(SeparatedStrings(rowString: event.number))
                    }
                case 2:
                    let tempArray = Array(self.completedEvents.value).filter { $0.type.rawValue == selectedEventType }
                    for event in tempArray {
                        names.append(SeparatedStrings(rowString: event.number))
                    }
                default:
                    break
                }
                var eventName = SeparatedStrings(rowString: "")

                if names.isEmpty {
                    if self.selectedEventType == "road" {
                        eventName.rowString = "No completed Road events"
                    } else {
                        eventName.rowString = "No completed City events"
                    }
                    disableEventSwipe = true // Don't allow swipe action on this cell!
                } else {
                    eventName = names[indexPath.row]
                    disableEventSwipe = false
                }
                cell.item = eventName
                return cell
            }
        case .availableTypes:
            if let _ = item as? CampaignDetailViewModelCharacterTypeItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAvailableTypeCell.identifier, for: indexPath) as? CampaignDetailAvailableTypeCell {
                let type = dataModel.availableCharacterTypesAttributed[indexPath.row]
                //let type = item.availableTypes[indexPath.row]
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.item = type
                return cell
            }
        case .campaignNotes:
            if let item = item as? CampaignDetailViewModelCampaignNotesItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailNotesCell.identifier, for: indexPath) as? CampaignDetailNotesCell {
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                item.notes = dataModel.currentCampaignNotes
                currentNotesCell = cell
                cell.item = item
                return cell
            }
        }
        return UITableViewCell()
    }
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.items[section].sectionTitle == "Events" {
            return 80
        } else {
            return 50
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 7 {
            return 600
        } else {
            return 60
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.items[section].sectionTitle == "Events" {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "CampaignDetailEventsHeader") as! CampaignDetailEventsHeader
            // Set up segmented control in custom header
            headerView.getSegment.addTarget(self, action: #selector(self.getEventSegmentControlValue(sender:)), for: .valueChanged)
            headerView.getSegment.selectedSegmentIndex = self.selectedEventsSegmentIndex
            
            if selectedEventType == "city" {
                headerView.roadButton.setTitleColor(colorDefinitions.tabBarUnselectedItemTintColor, for: .normal)
                headerView.cityButton.setTitleColor(colorDefinitions.scenarioTitleFontColor, for: .normal)
            } else {
                headerView.roadButton.setTitleColor(colorDefinitions.scenarioTitleFontColor, for: .normal)
                headerView.cityButton.setTitleColor(colorDefinitions.tabBarUnselectedItemTintColor, for: .normal)
            }
            headerView.roadButton.addTarget(self, action: #selector(self.pressedRoadButton(button:)), for: .touchUpInside)
            headerView.cityButton.addTarget(self, action: #selector(self.pressedCityButton(button:)), for: .touchUpInside)
            headerView.campaignDetailEventsHeaderTitle.text = "Events"
            // Return contentView of headerView so it doesn't disappear
            return headerView.contentView
        } else {
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
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sectionNumber = indexPath.section
        var returnValue = [UITableViewRowAction]()
        if sectionNumber == 3 {
            let type = dataModel.availableCharacterTypes[indexPath.row]
            self.configureCharacterTypeSwipeButton(for: type)
            let swipeToggleLocked = UITableViewRowAction(style: .normal, title: self.myCharacterTypeSwipeButtonTitle) { action, index in
                if self.myCharacterTypeSwipeButtonTitle == "Lock" {
                    self.dataModel.currentCampaign.availableCharacterTypes[type] = false
                    self.updateAvailableCharTypes()
                    self.toggleSection(section: 3)
                    self.dataModel.saveCampaignsLocally()
                } else if self.myCharacterTypeSwipeButtonTitle == "Starting character" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSwipeAlertStarting"), object: nil)
                } else if self.myCharacterTypeSwipeButtonTitle == "Character type in use" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showSwipeAlertUsed"), object: nil)
                }
            }
            swipeToggleLocked.backgroundColor = colorDefinitions.scenarioSwipeBGColor
            return [swipeToggleLocked]
        } else if sectionNumber == 6 {
            var event = dataModel.currentCampaign.events[0] // Just to allocate an event for use below
            switch selectedEventsSegmentIndex {
            case 0:
                event = unavailableEvents.value.filter { $0.type.rawValue == selectedEventType }[indexPath.row]
            case 1:
                event = availableEvents.value.filter { $0.type.rawValue == selectedEventType }[indexPath.row]
            case 2:
                event = completedEvents.value.filter { $0.type.rawValue == selectedEventType }[indexPath.row]
            default:
                break
            }
            self.configureEventSwipeButton(for: event)
            self.selectedEvent = event
            
            let swipeToggleComplete = UITableViewRowAction(style: .normal, title: self.myCompletedEventTitle) { action, index in
                if self.myCompletedEventTitle == "Set Available" {
                    event.isAvailable = true // Set to available if unavailable
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 6)
                    self.scrollEventsSection!()
                } else if self.myCompletedEventTitle == "Set Completed" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showEventChoiceOptionPicker"), object: nil)
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 6)
                    self.scrollEventsSection!()
                } else {
                    event.isCompleted = false // Set uncompleted if completed
                    event.isAvailable = true
                    self.stripOptionChoiceFromEventName(event: event)
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 6)
                    self.scrollEventsSection!()
                }
            }
            let swipeToggleUnavailable = UITableViewRowAction(style: .normal, title: self.myLockedTitle) { action, index in
                if self.myLockedTitle == "Set Unavailable" {
                    event.isCompleted = false
                    event.isAvailable = false
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 6)
                }
            }
            swipeToggleComplete.backgroundColor = colorDefinitions.scenarioSwipeBGColor
            swipeToggleUnavailable.backgroundColor = colorDefinitions.scenarioSwipeBGColor
            if myLockedTitle == "" {
                returnValue = [swipeToggleComplete]
            } else {
                returnValue = [swipeToggleComplete, swipeToggleUnavailable]
            }
        }
        return returnValue
    }
    // Implemented due to possibility of an event row with no actual data (just a string saying "No completed events")
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var returnValue: Bool
        if indexPath.section == 6 {
            if disableEventSwipe == false {
                returnValue = true
            } else {
                returnValue = false
            }
        } else if indexPath.section == 5 {
            if disablePartySwipe == false {
                returnValue = true
            } else {
                returnValue = false
            }
        } else {
            returnValue = true
        }
        return returnValue
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    // Delegate methods for textField in cell
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch self.textFieldReturningCellType! {
        case .campaignTitle:
            let myCell = self.currentTitleCell as! CampaignDetailTitleCell
            let myLabel = myCell.campaignDetailTitleLabel
            let oldTitle = myLabel!.text!
            if textField.text != "" {
                myLabel?.text = textField.text
                textField.isHidden = true
                self.renameCampaignTitle(oldTitle: oldTitle, newTitle: textField.text!)
            }
            myLabel?.isHidden = false
        default:
            break
        }
        return true
    }
    // Helper Methods
    func stripOptionChoiceFromEventName(event: Event) {
        let eventTokens = event.number.components(separatedBy: " ")
        let eventString = ("\(eventTokens[0]) \(eventTokens[1])")
        event.number = eventString
        toggleSection(section: 6)
        self.dataModel.saveCampaignsLocally()
    }
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        //let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
            let itemType = self.items[section].type
            
            switch itemType {
                
            case .prosperity:
                button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
                header.addSubview(button)
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .trailingMargin, relatedBy: .equal, toItem: header, attribute: .trailingMargin, multiplier: 0.99, constant: 0))
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 0.5, constant: 0))
            case .donations:
                button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
                header.addSubview(button)
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .trailingMargin, relatedBy: .equal, toItem: header, attribute: .trailingMargin, multiplier: 0.99, constant: 0))
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 0.5, constant: 0))
            case .achievements:
                break
            case .campaignTitle:
                break
            case .parties:
                break
            case .events:
                break
            case .availableTypes:
                button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showCharacterTypePicker(_:)), for: .touchUpInside)
                header.addSubview(button)
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .trailingMargin, relatedBy: .equal, toItem: header, attribute: .trailingMargin, multiplier: 0.99, constant: 0))
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 0.5, constant: 0))
            case .campaignNotes:
                button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.enableNotesTextField(_:)), for: .touchUpInside)
                header.addSubview(button)
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .trailingMargin, relatedBy: .equal, toItem: header, attribute: .trailingMargin, multiplier: 0.99, constant: 0))
                header.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: header, attribute: .centerY, multiplier: 0.5, constant: 0))
            }
    }
    fileprivate func configureCheckmark(for cell: UITableViewCell, activeStatus: Bool) {
        if activeStatus == true {
            cell.accessoryType = .checkmark
        }
    }
    @objc func pressedRoadButton(button: UIButton) {
        selectedEventType = "road"
        DispatchQueue.main.async {
            self.toggleSection(section: 6)
            self.scrollEventsSection!()
        }
    }
    @objc func pressedCityButton(button: UIButton) {
        button.setTitleColor(colorDefinitions.scenarioTitleFontColor, for: .normal)
        selectedEventType = "city"
        DispatchQueue.main.async {
            self.toggleSection(section: 6)
            self.scrollEventsSection!()
        }
    }
    @objc func getEventSegmentControlValue(sender: UISegmentedControl) {
        self.selectedEventsSegmentIndex = sender.selectedSegmentIndex
        self.toggleSection(section: 6)
        self.scrollEventsSection!()
    }
    @objc func getPartySegmentControlValue(sender: UISegmentedControl) {
        self.selectedPartiesSegmentIndex = sender.selectedSegmentIndex
        self.toggleSection(section: 5)
    }
    @objc func enableNotesTextField(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        let myCell = self.currentNotesCell
        let myTextField = myCell.NotesField!
        myTextField.isUserInteractionEnabled = true
        myTextField.delegate = self
        myTextField.font = UIFont(name: "Nyala", size: 20)
        myTextField.becomeFirstResponder()
        button.addTarget(self, action: #selector(self.disableNotesTextField(_:)), for: .touchUpInside)
    }
    @objc func disableNotesTextField(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        let myCell = self.currentNotesCell
        let myTextField = myCell.NotesField!
        myTextField.isUserInteractionEnabled = false
        setNotes(text: myTextField.text)
        
        button.addTarget(self, action: #selector(self.enableNotesTextField(_:)), for: .touchUpInside)
    }
    @objc func showUIStepperInCampaignProsperityCell(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        let myCell = self.currentProsperityCell as! CampaignDetailProsperityCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
    }
    @objc func showUIStepperInCampaignDonationsCell(_ button: UIButton) {
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        let myCell = self.currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
    }
    @objc func hideUIStepperInCampaignProsperityCell(_ button: UIButton) {
        let myCell = self.currentProsperityCell as! CampaignDetailProsperityCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        dataModel.saveCampaignsLocally()
    }
    @objc func hideUIStepperInCampaignDonationsCell(_ button: UIButton) {
        let myCell = self.currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        self.updateChecksToNextLevel()
        self.updateProsperityLevel()
        toggleSection(section: 1)
        dataModel.saveCampaignsLocally()
    }
    @objc func editEvents(_ button: UIButton) {
        self.toggleSection(section: 5)
        button.setImage(UIImage(named: "quill-drawing-a-line_selected"), for: .normal)
        button.removeTarget(self, action: #selector(self.editEvents(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.doneEditingEvents(_:)), for: .touchUpInside)
    }
    @objc func doneEditingEvents(_ button: UIButton) {
        self.toggleSection(section: 5)
        button.setImage(UIImage(named: "quill-drawing-a-line_unselected"), for: .normal)
        button.removeTarget(self, action: #selector(self.doneEditingEvents(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.editEvents(_:)), for: .touchUpInside)
        dataModel.saveCampaignsLocally()
    }
    @objc func showCharacterTypePicker(_ button: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showCharacterAvailableTypePicker"), object: nil)
    }
    // Called from VC to hide any controls left visible
    func hideAllControls() {
        let myDonationsCell = self.currentDonationsCell as! CampaignDetailDonationsCell
        myDonationsCell.myStepperOutlet.isHidden = true
        myDonationsCell.myStepperOutlet.isEnabled = false
        myDonationsCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        let myProsperityCell = self.currentProsperityCell as! CampaignDetailProsperityCell
        myProsperityCell.myStepperOutlet.isHidden = true
        myProsperityCell.myStepperOutlet.isEnabled = false
        myProsperityCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
    }
    // Set notes
    func setNotes(text: String) {
        dataModel.currentCampaignNotes = text
        dataModel.saveCampaignsLocally()
    }
}

extension CampaignDetailViewModel: SelectCampaignViewControllerDelegate, CampaignDetailViewControllerDelegate {

    func selectCampaignViewControllerDidCancel(_ controller: SelectCampaignViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func selectCampaignViewControllerDidFinishSelecting(_ controller: SelectCampaignViewController) {
        let campaignTitle = controller.selectedCampaign!
        setCampaignActive(campaign: campaignTitle)
        setPartyActive(party: dataModel.currentCampaign.parties![0].name)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateAfterNewCampaignSelected"), object: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    func toggleSection(section: Int) {
        reloadSection?(section)
    }
    func callScrollEventsSection() {
        scrollEventsSection?()
    }
    func campaignDetailVCDidTapDelete(_ controller: CampaignDetailViewController) {
        if dataModel.campaigns.count > 1 {
            let campaignForParty = dataModel.campaigns[self.campaignTitle.value]
            // Remove characters too
            for party in campaignForParty!.parties! {
                for char in dataModel.characters.values {
                    if char.assignedTo == party.name {
                        dataModel.characters.removeValue(forKey: char.name)
                    }
                }
                dataModel.parties.removeValue(forKey: party.name)
            }
            dataModel.campaigns.removeValue(forKey: self.campaignTitle.value)
            let myCampaign = Array(dataModel.campaigns.values)
            setCampaignActive(campaign: myCampaign.first!.title)
            setPartyActive(party: dataModel.currentCampaign.parties!.first!.name)
            self.updateCurrentParty()
        } else {
            controller.showDisallowDeletionAlert()
        }
    }
    // Delegate methods called from CampaignDetailVC
    func setEventOptionChoice() {
        if eventOptionPickerDidPick == false { selectedEventOption = "A" }
        self.selectedEvent!.number.append(" - Option: \(selectedEventOption)")
        self.selectedEvent!.isCompleted = true // Set to completed
        self.selectedEvent!.isAvailable = false // But no longer available
        toggleSection(section: 6)
        self.dataModel.saveCampaignsLocally()
    }
    func setCharacterType() {
        var charTypeString = String()
        if characterTypePickerDidPick == false {
            charTypeString = lockedCharTypes[0].rowString!.string.replacingOccurrences(of: " ", with: "")
            let cleanedString = charTypeString.replacingOccurrences(of: "\u{fffc}", with: "")
            dataModel.currentCampaign.availableCharacterTypes[cleanedString] = true
            self.updateAvailableCharTypes()
        } else {
            charTypeString = selectedCharacterType.rowString!.string.replacingOccurrences(of: " ", with: "")
            let cleanedString = charTypeString.replacingOccurrences(of: "\u{fffc}", with: "")
            if dataModel.currentCampaign.availableCharacterTypes[cleanedString] != nil {
                dataModel.currentCampaign.availableCharacterTypes[cleanedString] = true
            } else {
                print("Didn't find it!")
            }
            self.updateAvailableCharTypes()
        }
        toggleSection(section: 3)
        self.dataModel.saveCampaignsLocally()
    }
}
// MARK: PickerView Delegate Methods
extension CampaignDetailViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var returnValue = Int()
        if pickerView.tag == 5 {
            returnValue = 1
        } else if pickerView.tag == 20 {
            returnValue = 1
        }
        return returnValue
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnValue = Int()
        if pickerView.tag == 5 {
            returnValue = eventOptionPickerData.count
        } else if pickerView.tag == 20 {
            returnValue = dynamicLockedCharTypes.value.count
        }
        return returnValue
    }
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 5 {
            eventOptionPickerDidPick = true
            selectedEventOption = row == 0 ? "A" : "B"
        } else if pickerView.tag == 20 {
            characterTypePickerDidPick = true
            selectedCharacterType = Array(dynamicLockedCharTypes.value)[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.textAlignment = .center
        if pickerView.tag == 5 {
            label?.text =  ("\(selectedEvent!.number) - \(eventOptionPickerData[row])")
        } else if pickerView.tag == 20 {
            label?.attributedText = Array(dynamicLockedCharTypes.value)[row].rowString!
        }
        return label!
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView.tag == 20 {
            return 60.0
        } else {
            return 30.0
        }
    }
}
// MARK ViewModelItem Classes
class CampaignDetailViewModelCampaignTitleItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .campaignTitle
    }
    
    var sectionTitle: String {
        return "Campaign Title"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
class CampaignDetailViewModelCampaignPartyItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .parties
    }
    
    var sectionTitle: String {
        return "Active Party"
    }
    
    var rowCount: Int {
        return names.count
    }
    
    var names: [SeparatedStrings]
    
    init(names: [SeparatedStrings]) {
        self.names = names
    }
}
class CampaignDetailViewModelCampaignAchievementsItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .achievements
    }

    var sectionTitle: String {
        return "Global Achievements"
    }
    
    var rowCount: Int {
        return achievements.count
    }
    
    var achievements: [SeparatedStrings]
    
    init(achievements: [SeparatedStrings]) {
        self.achievements = achievements
    }
}
class CampaignDetailViewModelCampaignProsperityItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .prosperity
    }
    
    var sectionTitle: String {
        return "Prosperity"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var level: Int
    var remainingChecksUntilNextLevel: Int
    
    init(level: Int, remainingChecksUntilNextLevel: Int) {
        self.level = level
        self.remainingChecksUntilNextLevel = remainingChecksUntilNextLevel
    }
}
class CampaignDetailViewModelCampaignDonationsItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .donations
    }
    
    var sectionTitle: String {
        return "Sanctuary Donations"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var amount: Int
    var prosperityBonusString: String
    
    init(amount: Int, prosperityBonusString: String) {
        self.amount = amount
        self.prosperityBonusString = prosperityBonusString
    }
}
class CampaignDetailViewModelCampaignEventsItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .events
    }

    var sectionTitle: String {
        return "Events"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var numbers: [SeparatedStrings]
    
    init(numbers: [SeparatedStrings]) {
        self.numbers = numbers
    }
}
class CampaignDetailViewModelCharacterTypeItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .availableTypes
    }
    
    var sectionTitle: String {
        return "Unlocked character types"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var availableTypes: [SeparatedAttributedStrings]
    
    init(availableTypes: [SeparatedAttributedStrings]) {
        self.availableTypes = availableTypes
    }
}
class CampaignDetailViewModelCampaignNotesItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .campaignNotes
    }
    
    var sectionTitle: String {
        return "Campaign Notes"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var notes: String
    
    init(notes: String) {
        self.notes = notes
    }
}
