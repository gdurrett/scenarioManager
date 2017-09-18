//
//  Campaign.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Campaign: NSObject, NSCoding {
    

    var title: String
    var parties: [Party]?
    var achievements: [String:Bool]
    var prosperityCount: Int
    var sanctuaryDonations: Int
    var events: [String]?
    var isUnlocked: [Bool]
    var requirementsMet: [Bool]
    var isCompleted: [Bool]
    var isCurrent: Bool
    private var level = 1
    
    init(title: String, parties: [Party], achievements: [String:Bool], prosperityCount: Int, sanctuaryDonations: Int, events: [String], isUnlocked: [Bool], requirementsMet: [Bool], isCompleted: [Bool], isCurrent: Bool) {
        self.title = title
        self.parties = parties
        self.achievements = achievements
        self.prosperityCount = prosperityCount
        self.sanctuaryDonations = sanctuaryDonations
        self.events = events
        self.isUnlocked = isUnlocked
        self.requirementsMet = requirementsMet
        self.isCompleted = isCompleted
        self.isCurrent = isCurrent
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "Title") as! String
        parties = aDecoder.decodeObject(forKey: "Parties") as? [Party]
        achievements = aDecoder.decodeObject(forKey: "CampaignAchievements") as! [String:Bool]
        prosperityCount = aDecoder.decodeInteger(forKey: "ProsperityCount")
        sanctuaryDonations = aDecoder.decodeInteger(forKey: "SanctuaryDonations")
        events = aDecoder.decodeObject(forKey: "Events") as? [String]
        isUnlocked = aDecoder.decodeObject(forKey: "IsUnlocked") as! [Bool]
        requirementsMet = aDecoder.decodeObject(forKey: "RequirementsMet") as! [Bool]
        isCompleted = aDecoder.decodeObject(forKey: "IsCompleted") as! [Bool]
        isCurrent = aDecoder.decodeBool(forKey: "IsCurrent")
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "Title")
        aCoder.encode(parties, forKey: "Parties")
        aCoder.encode(achievements, forKey: "CampaignAchievements")
        aCoder.encode(prosperityCount, forKey: "ProsperityCount")
        aCoder.encode(sanctuaryDonations, forKey: "SanctuaryDonations")
        aCoder.encode(events, forKey: "Events")
        aCoder.encode(isUnlocked, forKey: "IsUnlocked")
        aCoder.encode(requirementsMet, forKey: "RequirementsMet")
        aCoder.encode(isCompleted, forKey: "IsCompleted")
        aCoder.encode(isCurrent, forKey: "IsCurrent")
    }
}
