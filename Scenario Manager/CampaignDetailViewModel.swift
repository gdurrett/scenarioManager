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
}
protocol CampaignDetailPartyUpdaterDelegate: class {
    func reloadTableAfterSetPartyCurrent()
}
protocol CampaignDetailViewModelItem {
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
    var newAchievementNames = [SeparatedStrings]()
    var eventNumbers = [SeparatedStrings]()
    var isActiveCampaign: Bool?
    var remainingChecksUntilNextLevel = Int()
    var level = Int()
    var sanctuaryDonations = Int()
    var completedGlobalAchievements: Dynamic<[String:Bool]>
    var campaignTitle: Dynamic<String>
    var prosperityLevel: Dynamic<Int>
    var checksToNextLevel: Dynamic<Int>
    var donations: Dynamic<Int>
    var assignedParties: Dynamic<[String]>
    var availableParties: Dynamic<[String]>
    var unavailableEvents: Dynamic<[Event]>
    var availableEvents: Dynamic<[Event]>
    var completedEvents: Dynamic<[Event]>
    var ancientTechCount: Dynamic<Int>
    var currentParty: Dynamic<Party>
    // Convert to dynamic later
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()
    var storedOffsets = [Int: CGFloat]()
    var currentTitleCell = UITableViewCell()
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    var currentEventCell = CampaignDetailEventCell()
    var currentPartyCell = CampaignDetailPartyCell()
    
    var myCompletedEventTitle = String()
    var myAssignedPartyTitle = String()
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
    
    // Vars for partyPicker
    var partyPickerData = [String]()
    var partyPickerDidPick: Bool = false
    var selectedPartyOption = String()
    
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
        self.currentParty = Dynamic(dataModel.currentParty)
        super.init()
        self.prosperityLevel = Dynamic(getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus))
        self.checksToNextLevel = Dynamic(getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus)), count: dataModel.currentCampaign.prosperityCount + self.prosperityBonus))
        
        self.isActiveCampaign = campaign.isCurrent
        
        // Set data for partyPicker
        self.partyPickerData = Array(dataModel.parties.keys)
        //self.partyPickerData = ["Test 1", "Test 2"]
        
        // Append campaign title to items
        let titleItem = CampaignDetailViewModelCampaignTitleItem(title: campaignTitle.value)
        items.append(titleItem)
        
        // Append prosperity level to items
        let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: getProsperityLevel(count: campaign.prosperityCount + self.prosperityBonus), remainingChecksUntilNextLevel: getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: campaign.prosperityCount + self.prosperityBonus)), count: campaign.prosperityCount + self.prosperityBonus))
        items.append(prosperityItem)
        
        // Append donations amount to items
        let donationsItem = CampaignDetailViewModelCampaignDonationsItem(amount: donations.value, prosperityBonusString: "")
        items.append(donationsItem)
        
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
        
        // Append party names to items
        if campaign.parties?.isEmpty != true {
            for party in campaign.parties! {
                partyNames.append(SeparatedStrings(rowString: party.name))
                print("Appending party: \(party.name)")
            }
        } else {
            self.partyNames.append(SeparatedStrings(rowString: ""))
        }
        let partyItem = CampaignDetailViewModelCampaignPartyItem(names: partyNames)
        items.append(partyItem)

        
        // Append city event items
        for event in campaign.events {
            eventNumbers.append(SeparatedStrings(rowString: event.number))
        }
        let eventItem = CampaignDetailViewModelCampaignEventsItem(numbers: eventNumbers)
        items.append(eventItem)

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
//    func getCompletedAchievements(campaign: Campaign) -> [SeparatedStrings] {
//        let localCompletedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
//        if localCompletedAchievements.isEmpty != true {
//            for achievement in localCompletedAchievements {
//                achievementNames.append(SeparatedStrings(rowString: achievement.key))
//            }
//        }
//        return achievementNames
//    }

    // See if we can accurately update ourself with completed achievements
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
        self.currentParty.value = dataModel.currentParty
    }
    func updateEvents() {
        self.unavailableEvents.value = dataModel.unavailableEvents
        self.completedEvents.value = dataModel.completedEvents
        self.availableEvents.value = dataModel.availableEvents
    }
    func updateAncientTech() {
        self.ancientTechCount.value = dataModel.currentCampaign.ancientTechCount
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
    // Methods for CampaignProsperity cell
    func updateCampaignProsperityCount(value: Int) {
        let (level, count) = (self.updateProsperityCount(value: value))
        let remainingChecks = self.getRemainingChecksUntilNextLevel(level: level, count: count)
        let checksText = remainingChecks > 1 ? "checks" : "check"
        // Try updating to catch prosperityBonus increments
        self.updateChecksToNextLevel()
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.campaignDetailProsperityLabel.text = "\(level)          \(remainingChecks) \(checksText) to next level"
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
}
extension CampaignDetailViewModel: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CampaignDetailTitleCellDelegate, CampaignDetailProsperityCellDelegate, CampaignDetailDonationsCellDelegate {
    
    // TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        self.updateEvents()
        self.updateAssignedParties()
        self.updateAvailableParties()
        self.updateAchievements()
        self.updateAncientTech()
        
        // May need an updateEvents() too?
        //let item = self.items[section]
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
        } else if self.items[section].type == .events {
            //probably bring this into local variable
            switch selectedEventsSegmentIndex {
            case 0:
                let myCount = self.unavailableEvents.value.filter { $0.type.rawValue == self.selectedEventType }
                returnValue = myCount.count
                //returnValue = self.unavailableEvents.value.count
            case 1:
                let myCount = self.availableEvents.value.filter { $0.type.rawValue == self.selectedEventType }
                returnValue = myCount.count
                //returnValue = self.availableEvents.value.count
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
            switch selectedPartiesSegmentIndex {
            case 0:
                returnValue = self.assignedParties.value.count == 0 ? 1 : self.assignedParties.value.count
            case 1:
                returnValue = self.availableParties.value.count == 0 ? 1 : self.availableParties.value.count
            default:
                break
            }
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
                // Give proper status to isActive button in this cell
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
                item.amount = donations.value
                if dataModel.currentCampaign.sanctuaryDonations < 100 {
                    item.prosperityBonusString = ""
                } else {
                    item.prosperityBonusString = "      prosperity bonus: +\(self.prosperityBonus)"
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
                let party = SeparatedStrings(rowString: self.currentParty.value.name)
                cell.item = party
                return cell
            }
        case .achievements:
            if let _ = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                cell.backgroundColor = UIColor.clear
                var achievement = SeparatedStrings(rowString: "")
                var tempAch = Array(self.completedGlobalAchievements.value.keys)
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
                if gotTech == true { achNames.append(SeparatedStrings(rowString: ("Ancient Technology (\(dataModel.currentCampaign.ancientTechCount))"))) }
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
//        } else if self.items[section].sectionTitle == "Parties" {
//            let headerView = tableView.dequeueReusableCell(withIdentifier: "CampaignDetailPartiesHeader") as! CampaignDetailPartiesHeader
//            headerView.getSegment.addTarget(self, action: #selector(self.getPartySegmentControlValue(sender:)), for: .valueChanged)
//            headerView.getSegment.selectedSegmentIndex = self.selectedPartiesSegmentIndex
//
//            headerView.campaignDetailPartiesHeaderTitle.text = "Parties"
//            return headerView.contentView
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
        if sectionNumber == 5 {
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
                    self.toggleSection(section: 5)
                    self.scrollEventsSection!()
                } else if self.myCompletedEventTitle == "Set Completed" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showEventChoiceOptionPicker"), object: nil)
                    event.isCompleted = true // Set to completed
                    event.isAvailable = false // But no longer available
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 5)
                    self.scrollEventsSection!()
                } else {
                    event.isCompleted = false // Set uncompleted if completed
                    event.isAvailable = true
                    self.stripOptionChoiceFromEventName(event: event)
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 5)
                    self.scrollEventsSection!()
                }
            }
            let swipeToggleUnavailable = UITableViewRowAction(style: .normal, title: self.myLockedTitle) { action, index in
                if self.myLockedTitle == "Set Unavailable" {
                    event.isCompleted = false
                    event.isAvailable = false
                    self.updateEvents()
                    self.dataModel.saveCampaignsLocally()
                    self.toggleSection(section: 5)
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
        if indexPath.section == 5 {
            if disableEventSwipe == false {
                returnValue = true
            } else {
                returnValue = false
            }
        } else if indexPath.section == 4 {
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
//        if indexPath.section == 4 && selectedPartiesSegmentIndex == 0 {
//            var party = String()
//            switch selectedPartiesSegmentIndex {
//            case 0:
//                party = assignedParties.value[indexPath.row]
//            case 1:
//                party = availableParties.value[indexPath.row]
//            default:
//                break
//            }
//            print("Selected party: \(party)")
//        }
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
        toggleSection(section: 5)
        self.dataModel.saveCampaignsLocally()
    }
    func createSectionButton(forSection section: Int, inHeader header: UIView) {
        
        let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
        
            let itemType = self.items[section].type
            
            switch itemType {
                
            case .prosperity:
                button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .donations:
                button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .achievements:
                break
            case .campaignTitle:
                button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.enableTitleTextField(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .parties:
                button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showPartyPicker(button:)), for: .touchUpInside)
                header.addSubview(button)
            case .events:
                break
            }
    }
    fileprivate func configureCheckmark(for cell: UITableViewCell, activeStatus: Bool) {
        if activeStatus == true {
            cell.accessoryType = .checkmark
        }
    }
    @objc func showPartyPicker(button: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPartyPicker"), object: nil)
    }
    @objc func pressedRoadButton(button: UIButton) {
        selectedEventType = "road"
        DispatchQueue.main.async {
            self.toggleSection(section: 5)
            self.scrollEventsSection!()
        }
    }
    @objc func pressedCityButton(button: UIButton) {
        button.setTitleColor(colorDefinitions.scenarioTitleFontColor, for: .normal)
        selectedEventType = "city"
        DispatchQueue.main.async {
            self.toggleSection(section: 5)
            self.scrollEventsSection!()
        }
    }
    @objc func getEventSegmentControlValue(sender: UISegmentedControl) {
        self.selectedEventsSegmentIndex = sender.selectedSegmentIndex
        self.toggleSection(section: 5)
        self.scrollEventsSection!()
    }
    @objc func getPartySegmentControlValue(sender: UISegmentedControl) {
        self.selectedPartiesSegmentIndex = sender.selectedSegmentIndex
        print("Setting Segment Index to: \(sender.selectedSegmentIndex)")
        self.toggleSection(section: 4)
    }
    @objc func enableTitleTextField(_ sender: UIButton) {
        let myCell = self.currentTitleCell as! CampaignDetailTitleCell
        let myTextField = myCell.campaignDetailTitleTextField!
        myTextField.delegate = self
        let oldText = myCell.campaignDetailTitleLabel.text
        myTextField.text = oldText
        myTextField.font = fontDefinitions.detailTableViewTitleFont
        myTextField.becomeFirstResponder()
        myTextField.selectedTextRange = myCell.campaignDetailTitleTextField.textRange(from: myCell.campaignDetailTitleTextField.beginningOfDocument, to: myCell.campaignDetailTitleTextField.endOfDocument)
        myCell.campaignDetailTitleLabel.isHidden = true
        myTextField.isHidden = false
        self.textFieldReturningCellType = .campaignTitle
    }
    @objc func showUIStepperInCampaignProsperityCell(_ button: UIButton) {
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        let myCell = self.currentProsperityCell as! CampaignDetailProsperityCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
    }
    @objc func showUIStepperInCampaignDonationsCell(_ button: UIButton) {
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
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
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
        dataModel.saveCampaignsLocally()
    }
    @objc func hideUIStepperInCampaignDonationsCell(_ button: UIButton) {
        let myCell = self.currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
        self.updateChecksToNextLevel()
        self.updateProsperityLevel()
        toggleSection(section: 1)
        dataModel.saveCampaignsLocally()
    }
    @objc func editEvents(_ button: UIButton) {
        self.toggleSection(section: 5)
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        button.removeTarget(self, action: #selector(self.editEvents(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.doneEditingEvents(_:)), for: .touchUpInside)
    }
    @objc func doneEditingEvents(_ button: UIButton) {
        self.toggleSection(section: 5)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
        button.removeTarget(self, action: #selector(self.doneEditingEvents(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(self.editEvents(_:)), for: .touchUpInside)
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
            if !(campaignForParty?.parties?.isEmpty)! {
                for party in (campaignForParty?.parties!)! {
                        party.assignedTo = "None" // Make sure to set to None since we're deleting associated campaign.
                }
            }
            dataModel.campaigns.removeValue(forKey: self.campaignTitle.value)
            let myCampaign = Array(dataModel.campaigns.values)
            setCampaignActive(campaign: myCampaign.first!.title)
            controller.campaignDetailTableView.reloadData()
        } else {
            controller.showDisallowDeletionAlert()
        }
    }
//    func showEventOptionPicker(_ controller: CampaignDetailViewController) {
//        controller.delegate = self
//        controller.showEventOptionPicker()
//    }
    // Delegate methods called from CampaignDetailVC
    func setEventOptionChoice() {
        self.selectedEvent!.number.append(" - Option: \(selectedEventOption)")
        toggleSection(section: 5)
        self.dataModel.saveCampaignsLocally()
    }
    func setPartyChoice() {
        //var myParty = Party(name: "Temp", characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: "")
//        for party in dataModel.parties {
//            if party.value.name == selectedPartyOption {
//                myParty = party.value
//                dataModel.parties[selectedPartyOption]!.isCurrent = true
//            } else {
//                party.value.isCurrent = false
//            }
//        }
        
        print("Setting \(dataModel.parties[selectedPartyOption]!.name) isCurrent to true")
        //self.dataModel.saveCampaignsLocally()
        dataModel.currentParty = dataModel.parties[selectedPartyOption] // See if we can do the 'set'
        updateCurrentParty()
        toggleSection(section: 4)
        self.dataModel.saveCampaignsLocally()
    }
}
// MARK: PickerView Delegate Methods
extension CampaignDetailViewModel: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var returnValue = Int()
        if pickerView.tag == 5 {
            returnValue = 1
        } else if pickerView.tag == 10 {
            returnValue = 1
        }
        return returnValue
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnValue = Int()
        if pickerView.tag == 5 {
            returnValue = eventOptionPickerData.count
        } else if pickerView.tag == 10 {
            returnValue = partyPickerData.count
        }
        return returnValue
    }
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 5 {
            eventOptionPickerDidPick = true
            selectedEventOption = row == 0 ? "A" : "B"
        } else if pickerView.tag == 10 {
            partyPickerDidPick = true
            selectedPartyOption = partyPickerData[row]
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
        } else if pickerView.tag == 10 {
            label?.text = ("\(partyPickerData[row])")
        }

        return label!
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
