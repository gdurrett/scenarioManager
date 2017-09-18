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
    var isActiveCampaign: Bool?
    var prosperityLevel = Int()
    
    init(withCampaign campaign: Campaign) {
        super.init()
        
        var level = 1
        var prosperityLevel: Int {
            get {
                switch (campaign.prosperityCount) {
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
        }
        
        self.isActiveCampaign = campaign.isCurrent
        
        // Append campaign title to items
        let titleItem = CampaignDetailViewModelCampaignTitleItem(title: campaign.title)
        items.append(titleItem)
        
        // Append party names to items
        if campaign.parties?.isEmpty != true {
            for party in campaign.parties! {
                partyNames.append(SeparatedStrings(rowString: party.name))
            }
        }
        let partyItem = CampaignDetailViewModelCampaignPartyItem(names: partyNames)
        items.append(partyItem)
        
        // Append achievement names(keys) to items
        let completedAchievements = campaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        if completedAchievements.isEmpty != true {
            for achievement in completedAchievements {
                achievementNames.append(SeparatedStrings(rowString: achievement.key))
            }
        }
        let achievementsItem = CampaignDetailViewModelCampaignAchievementsItem(achievements: achievementNames)
        items.append(achievementsItem)
        
        // Append prosperity level to items
        //let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: campaign.prosperityLevel)
        let prosperityItem = CampaignDetailViewModelCampaignProsperityItem(level: prosperityLevel)
        items.append(prosperityItem)
        
        // Append donations amount to items
        let donationsItem = CampaignDetailViewModelCampaignDonationsItem(amount: campaign.sanctuaryDonations)
        items.append(donationsItem)
    }
    func setCampaignActive() {
       // print("In setCampaignActive, we have \(campaignTitle!)")
        dataModel.loadCampaign(campaign: campaignTitle!)
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
    
    init(level: Int) {
        self.level = level
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
