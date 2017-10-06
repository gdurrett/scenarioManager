//
//  CampaignDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

// Test
protocol CampaignDetailViewModelDelegate: class {
    func refreshCityEvents()
}
import Foundation
import UIKit

enum CampaignDetailViewModelItemType {
    case campaignTitle
    case parties
    case achievements
    case prosperity
    case donations
    case cityEvents
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
    // Convert to dynamic later
    var cityEventItems: CampaignDetailViewModelCityEventsItem?
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()
    var storedOffsets = [Int: CGFloat]()
    var currentTitleCell = UITableViewCell()
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    var currentCityEventsCollectionView: UICollectionView?
    var currentCityEventsCollectionCell: UICollectionViewCell?
    var isCityEventButtonClicked = false
    var textFieldReturningCellType: CampaignDetailViewModelItemType?
    
    weak var delegate: CampaignDetailViewModelDelegate?
    
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
        
        // Append completed achievements to items
        let localCompletedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if localCompletedAchievements.isEmpty != true {
            for achievement in localCompletedAchievements {
                achievementNames.append(SeparatedStrings(rowString: achievement.key))
            }
        }
        let achievementsItem = CampaignDetailViewModelCampaignAchievementsItem(achievements: achievementNames)
        items.append(achievementsItem)
        
        // Append completed city events to items
        cityEventItems = CampaignDetailViewModelCityEventsItem(titles: ["07A", "06B", "03A", "01A", "29A", "13B", "11B", "78A", "16B", "70B", "19A", "21B", "22A", "12B", "28A", "24A", "17B", "27A", "02A", "14B", "05A", "15A", "09B", "33B", "75B"])
        items.append(cityEventItems!)
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
    // Method for adding a new city event
    func addNewCityEvent(name: String) {
        // Check for existing event before adding!
        // Probably need to make this dynamic
        dataModel.currentCampaign.cityEvents?.insert(name, at: 0)
        //dataModel.saveCampaignsLocally()
        //delegate?.refreshCityEvents()
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
                //cell.isActive = (isActiveCampaign == true ? true : false)
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
                let tempAch = Array(self.completedGlobalAchievements.value.keys)
                var achNames = [SeparatedStrings]()
                for ach in tempAch {
                    achNames.append(SeparatedStrings(rowString: ach))
                }
                achievement = achNames[indexPath.row]
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
        case .cityEvents:
            if let item = item as? CampaignDetailViewModelCityEventsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailCityEventsCell.identifier, for: indexPath) as? CampaignDetailCityEventsCell {
                currentCityEventsCollectionView = cell.campaignDetailCityEventsCollectionView
                cell.backgroundColor = UIColor.clear
                item.titles = cityEventItems!.titles
                cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                // Make unselectable until we hit edit button
//                if isCityEventButtonClicked != true {
//                    currentCityEventsCollectionView!.isUserInteractionEnabled = false
//                }
                cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
                cell.items = item
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
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? CampaignDetailCityEventsCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
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
        case .cityEvents:
            let myCell = self.currentCityEventsCollectionCell as! CampaignDetailEventCollectionCell
            let myLabel = myCell.campaignDetailEventCollectionCellLabel
            //let oldTitle = myLabel?.text!
            if textField.text != "" {
                myLabel?.text = textField.text
                textField.isHidden = true
                // Provisional
                myLabel?.isHidden = false
                self.addNewCityEvent(name: myLabel!.text!)
            }
        default:
            break
        }
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
        
            //button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            
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
                button.isEnabled = false
            case .cityEvents:
                if isCityEventButtonClicked == true {
                    button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
                } else {
                    button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
                }
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.editCityEvents(_:)), for: .touchUpInside)
                header.addSubview(button)
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
        self.textFieldReturningCellType = .campaignTitle
    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        let myCell = self.currentTitleCell as! CampaignDetailTitleCell
//        let myTextField = myCell.campaignDetailTitleTextField!
//        myTextField.delegate = self
//        myTextField.isHidden = true
//        myCell.campaignDetailTitleLabel.isHidden = false
//    }
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
    @objc func editCityEvents(_ button: UIButton) {
        isCityEventButtonClicked = true
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        // Make cells selectable
        self.currentCityEventsCollectionView!.isUserInteractionEnabled = true
        self.cityEventItems!.titles.insert("Add", at: 0)
        delegate!.refreshCityEvents()
    }
}
extension CampaignDetailViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Numitems: \(cityEventItems!.titles.count)")
        return cityEventItems!.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = cityEventItems
        var cellToReturn = UICollectionViewCell()
        switch item!.type {
        case .cityEvents:
            if let item = item, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignDetailEventCollectionCell.identifier, for: indexPath) as? CampaignDetailEventCollectionCell {
                cell.item = item.titles[indexPath.row]
                //Hide textField until selected
                cell.campaignDetailEventCollectionCellTextField.isHidden = true
                cellToReturn = cell
            }
        default:
            break
        }
        return cellToReturn
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let item = cityEventItems!.titles[indexPath.row]
        let myEventCell = currentCityEventsCollectionView?.cellForItem(at: indexPath) as! CampaignDetailEventCollectionCell
        self.currentCityEventsCollectionCell = myEventCell
        // Only call if we're on add cell
        if myEventCell.campaignDetailEventCollectionCellLabel.text == "Add" {
            let myEventTextField = myEventCell.campaignDetailEventCollectionCellTextField
            let myEventLabel = myEventCell.campaignDetailEventCollectionCellLabel
            myEventTextField!.delegate = self
            let oldEventText = myEventLabel!.text
            myEventTextField!.text = oldEventText
            myEventTextField!.font = fontDefinitions.detailTableViewNonTitleFont
            myEventTextField!.becomeFirstResponder()
            myEventTextField!.selectedTextRange = myEventTextField!.textRange(from: myEventTextField!.beginningOfDocument, to: myEventTextField!.endOfDocument)
            myEventLabel!.isHidden = true
            myEventTextField!.isHidden = false
            // Need to tell shouldReturn which kind of cell was being edited
            textFieldReturningCellType = .cityEvents
        }
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
class CampaignDetailViewModelCityEventsItem: CampaignDetailViewModelItem {
    
    var type: CampaignDetailViewModelItemType {
        return .cityEvents
    }
    
    var sectionTitle: String {
        return "City Events"
    }
    
    var rowCount: Int {
        return 1
    }
    
    var titles: [String]
    
    init(titles: [String]) {
        self.titles = titles
    }
}
