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
//    case events
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
    var isActiveCampaign: Bool?
//    var prosperityLevel = Int()
    var remainingChecksUntilNextLevel = Int()
    var level = Int()
    var sanctuaryDonations = Int()
    var completedGlobalAchievements: Dynamic<[String:Bool]>
    var campaignTitle: Dynamic<String>
    var prosperityLevel: Dynamic<Int>
    var checksToNextLevel: Dynamic<Int>
    var donations: Dynamic<Int>
    var parties: Dynamic<[String]>
    
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()

    var currentTitleCell = UITableViewCell()
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()

    init(withCampaign campaign: Campaign) {
        self.completedGlobalAchievements = Dynamic(dataModel.completedGlobalAchievements)
        self.campaignTitle = Dynamic(dataModel.currentCampaign.title)
        self.prosperityLevel = Dynamic(0)
        self.checksToNextLevel = Dynamic(0)
        self.donations = Dynamic(dataModel.currentCampaign.sanctuaryDonations)
        self.parties = Dynamic(dataModel.currentParties)
        super.init()
        self.prosperityLevel = Dynamic(getProsperityLevel(count: dataModel.currentCampaign.prosperityCount))
        self.checksToNextLevel = Dynamic(getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount)), count: dataModel.currentCampaign.prosperityCount))
        
        self.isActiveCampaign = campaign.isCurrent
        
        // Append campaign title to items
        let titleItem = CampaignDetailViewModelCampaignTitleItem(title: campaignTitle.value)
        items.append(titleItem)
        //print("Appended \(titleItem.title)")
        
        // Append prosperity level to items
        let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: getProsperityLevel(count: campaign.prosperityCount), remainingChecksUntilNextLevel: getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: campaign.prosperityCount)), count: campaign.prosperityCount))
        items.append(prosperityItem)
        
        // Append donations amount to items
        let donationsItem = CampaignDetailViewModelCampaignDonationsItem(amount: donations.value)
        items.append(donationsItem)
        
        // Append party names to items
        if campaign.parties?.isEmpty != true {
            for party in campaign.parties! {
                partyNames.append(SeparatedStrings(rowString: party.name))
            }
        } else {
            self.partyNames.append(SeparatedStrings(rowString: ""))
        }
        let partyItem = CampaignDetailViewModelCampaignPartyItem(names: partyNames)
        items.append(partyItem)
        
        let localCompletedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if localCompletedAchievements.isEmpty != true {
            for achievement in localCompletedAchievements {
                achievementNames.append(SeparatedStrings(rowString: achievement.key))
            }
        }
        let achievementsItem = CampaignDetailViewModelCampaignAchievementsItem(achievements: achievementNames)
        items.append(achievementsItem)
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
        print("Returning \(campaign.sanctuaryDonations)")
        return campaign.sanctuaryDonations
    }
    func getCompletedAchievements(campaign: Campaign) -> [SeparatedStrings] {
        let localCompletedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if localCompletedAchievements.isEmpty != true {
            for achievement in localCompletedAchievements {
                achievementNames.append(SeparatedStrings(rowString: achievement.key))
            }
        }
        return achievementNames
    }
    // See if we can accurately update ourself with completed achievements
    func updateAchievements() {
        self.completedGlobalAchievements.value = dataModel.completedGlobalAchievements
    }
    func updateCampaignTitle() {
        self.campaignTitle.value = dataModel.currentCampaign.title
    }
    func updateProsperityLevel() {
        self.prosperityLevel.value = getProsperityLevel(count: dataModel.currentCampaign.prosperityCount)
    }
    func updateChecksToNextLevel() {
        self.checksToNextLevel.value = getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount)), count: dataModel.currentCampaign.prosperityCount)
    }
    func updateDonations() {
        self.donations.value = dataModel.currentCampaign.sanctuaryDonations
    }
    func updateParties() {
        self.parties.value = dataModel.currentParties
    }
    // Method for CampaignProsperity cell
    func updateProsperityCount(value: Int) -> (Int, Int) {
        let count = dataModel.currentCampaign.prosperityCount
        if value == -1 && count == 0 {
            return (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount), 0)
        } else {
            dataModel.currentCampaign.prosperityCount += value
            return (getProsperityLevel(count: dataModel.currentCampaign.prosperityCount), dataModel.currentCampaign.prosperityCount)
        }
    }
    // Method for CampaignDonations cell
    func updateCampaignDonationsCount(value: Int) {
        dataModel.currentCampaign.sanctuaryDonations += value
        if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
            cell.campaignDetailDonationsLabel.text = "\(dataModel.currentCampaign.sanctuaryDonations)"
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
//        if let cell = self.currentProsperityCell as? CampaignDetailProsperityCell {
//            cell.isActive = true
//        }
//        if let cell = self.currentDonationsCell as? CampaignDetailDonationsCell {
//            cell.isActive = true
//        }
//        if let cell = self.currentTitleCell as? CampaignDetailTitleCell {
//            cell.isActive = true
//        }
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
        self.updateAchievements()
        if self.items[section].type == .achievements {
            return self.completedGlobalAchievements.value.count
        } else {
            return self.items[section].rowCount
        }
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
                
                //viewModel?.campaignTitle =
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
                item.level = prosperityLevel.value
                item.remainingChecksUntilNextLevel = checksToNextLevel.value
                cell.delegate = self
                cell.isActive = (isActiveCampaign == true ? true : false)
                cell.item = item
                currentProsperityCell = cell
                return cell
            }
        case .donations:
            if let item = item as? CampaignDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                cell.backgroundColor = UIColor.clear
                item.amount = donations.value
                cell.delegate = self
                cell.isActive = (self.isActiveCampaign == true ? true : false)
                cell.item = item
                currentDonationsCell = cell
                return cell
            }
        case .parties:
            if let _ = item as? CampaignDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                cell.backgroundColor = UIColor.clear
                var names = [SeparatedStrings]()
                if parties.value.isEmpty != true {
                    for name in parties.value {
                        names.append(SeparatedStrings(rowString: name))
                    }
                } else {
                    names.append(SeparatedStrings(rowString: "No parties assigned"))
                }
                cell.selectionStyle = .none
                let party = names[indexPath.row]
                cell.item = party
                return cell
            }
        case .achievements:
            if let _ = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                cell.backgroundColor = UIColor.clear
                var achievement = SeparatedStrings(rowString: "")
                //if self.isActiveCampaign == true {
                    let tempAch = Array(self.completedGlobalAchievements.value.keys)
                    var achNames = [SeparatedStrings]()
                    for ach in tempAch {
                        achNames.append(SeparatedStrings(rowString: ach))
                    }
                    achievement = achNames[indexPath.row]
//                } else {
//                    print("Showing inactive")
//                    achievement = item.achievements[indexPath.row]
//                }
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
            //        case .events:
            //            break
        }
        return UITableViewCell()
    }
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
        headersToUpdate[section] = header
        // Test custom edit button in header view (if active campaign)
        createSectionButton(forSection: section, inHeader: header!)
    }
    // Delegate methods for textField in cell
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let myCell = self.currentTitleCell as! CampaignDetailTitleCell
        let myLabel = myCell.campaignDetailTitleLabel
        let oldTitle = myLabel!.text!
        if textField.text != "" {
            myLabel?.text = textField.text
            textField.isHidden = true
            self.renameCampaignTitle(oldTitle: oldTitle, newTitle: textField.text!)
        }
        myLabel?.isHidden = false
        return true
    }
    // Helper Methods
    func updateCampaignProsperityCount(value: Int) {
        let (level, count) = (self.updateProsperityCount(value: value))
        let remainingChecks = self.getRemainingChecksUntilNextLevel(level: level, count: count)
        let checksText = remainingChecks > 1 ? "checks" : "check"
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.campaignDetailProsperityLabel.text = "\(level) (\(remainingChecks) \(checksText) to next level)"
        }
    }
    func createSectionButton(forSection section: Int, inHeader header: UITableViewHeaderFooterView) {
        
        //let myCell = self.currentTitleCell as! CampaignDetailTitleCell
        
        //if myCell.isActive == true {
            let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
            button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            
            let itemType = self.items[section].type
            
            switch itemType {
                
            case .prosperity:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .donations:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .achievements:
                break
            case .campaignTitle:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.enableTitleTextField(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .parties:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showAvailableParties(_:)), for: .touchUpInside)
            }
        //}
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
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let myCell = self.currentTitleCell as! CampaignDetailTitleCell
        let myTextField = myCell.campaignDetailTitleTextField!
        myTextField.delegate = self
        myTextField.isHidden = true
        myCell.campaignDetailTitleLabel.isHidden = false
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
    }
    @objc func hideUIStepperInCampaignDonationsCell(_ button: UIButton) {
        let myCell = self.currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
    }
    @objc func showAvailableParties(_ button: UIButton) {
        
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
    
    func campaignDetailVCDidTapDelete(_ controller: CampaignDetailViewController) {
        if dataModel.campaigns.count > 1 {
            dataModel.campaigns.removeValue(forKey: self.campaignTitle.value)
            let myCampaign = Array(dataModel.campaigns.values)
            setCampaignActive(campaign: myCampaign.first!.title)
        } else {
            controller.showDisallowDeletionAlert()
        }
    }
}

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
        return "Parties"
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
    
    init(amount: Int) {
        self.amount = amount
    }
}
