//
//  CampaignDetailViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

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
    
    var dataModel = DataModel.sharedInstance
    var campaign: Campaign!
    var items = [CampaignDetailViewModelItem]()
    var campaignTitle: String?
    var partyNames = [SeparatedStrings]()
    var achievementNames = [SeparatedStrings]()
    var newAchievementNames = [SeparatedStrings]()
    var isActiveCampaign: Bool?
    var prosperityLevel = Int()
    var remainingChecksUntilNextLevel = Int()
    var level = Int()
    var sanctuaryDonations = Int()
    var completedGlobalAchievements: Dynamic<[String:Bool]>
    
    init(withCampaign campaign: Campaign) {
        self.completedGlobalAchievements = Dynamic(dataModel.completedGlobalAchievements)
        
        var prosperityLevel: Int {
            get {
                print("I think prosperityCount is: \(campaign.prosperityCount)")
                return getProsperityLevel(count: campaign.prosperityCount)
            }
        }
        var remainingChecksUntilNextLevel: Int {
            get {
                return getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: campaign.prosperityCount)), count: campaign.prosperityCount)
            }
        }
        var sanctuaryDonations: Int {
            get {
                print("Do we get donations?")
                return getSanctuaryDonations(campaign: campaign)
            }
        }
        super.init()
        // Need to make dynamic
        
        self.isActiveCampaign = campaign.isCurrent
        
        // Append campaign title to items
        let titleItem = CampaignDetailViewModelCampaignTitleItem(title: campaign.title)
        items.append(titleItem)
        
        // Append prosperity level to items
        let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: getProsperityLevel(count: campaign.prosperityCount), remainingChecksUntilNextLevel: getRemainingChecksUntilNextLevel(level: (getProsperityLevel(count: campaign.prosperityCount)), count: campaign.prosperityCount))
        items.append(prosperityItem)
        
        // Append donations amount to items
        let donationsItem = CampaignDetailViewModelCampaignDonationsItem(amount: campaign.sanctuaryDonations)
        items.append(donationsItem)
        
        // Append party names to items
        if campaign.parties?.isEmpty != true {
            for party in campaign.parties! {
                partyNames.append(SeparatedStrings(rowString: party.name))
            }
        } else {
            self.partyNames.append(SeparatedStrings(rowString: "No parties assigned."))
        }
        let partyItem = CampaignDetailViewModelCampaignPartyItem(names: partyNames)
        items.append(partyItem)
        
        // Append achievement names(keys) to items -> May be able to remove in favor of appending in cellForRowAt in CampaignDetailViewController
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
    // Delegate methods for custom cells
    // Method for CampaignTitle cell
    func setCampaignActive() {
        dataModel.loadCampaign(campaign: campaignTitle!)
        dataModel.saveCampaignsLocally()
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
    func updateCampaignDonationsCount(value: Int) -> Int {
        dataModel.currentCampaign.sanctuaryDonations += value
        return getSanctuaryDonations(campaign:dataModel.currentCampaign)
    }
    // Method for Renaming Campaign Title
    func renameCampaignTitle(oldTitle: String, newTitle: String) {
        if oldTitle != newTitle { // Don't do anything if it's the same title
            dataModel.campaigns.changeKey(from: oldTitle, to: newTitle)
            dataModel.currentCampaign.title = newTitle
            dataModel.saveCampaignsLocally()
            print("New list of campaigns: \(dataModel.campaigns)")
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
