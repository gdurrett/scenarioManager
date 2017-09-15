//
//  Campaign.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Campaign: NSObject, NSCoding {
    
    var parties: [Party]?
    var title: String
    var isUnlocked: [Bool]
    var requirementsMet: [Bool]
    var isCompleted: [Bool]
    var achievements: [String:Bool]
    var isCurrent: Bool
    
    init(title: String, isUnlocked: [Bool], requirementsMet: [Bool], isCompleted: [Bool], achievements: [String:Bool], isCurrent: Bool, parties: [Party]) {
        self.title = title
        self.isUnlocked = isUnlocked
        self.requirementsMet = requirementsMet
        self.isCompleted = isCompleted
        self.achievements = achievements
        self.isCurrent = isCurrent
        self.parties = parties
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "Title") as! String
        isUnlocked = aDecoder.decodeObject(forKey: "IsUnlocked") as! [Bool]
        requirementsMet = aDecoder.decodeObject(forKey: "RequirementsMet") as! [Bool]
        isCompleted = aDecoder.decodeObject(forKey: "IsCompleted") as! [Bool]
        achievements = aDecoder.decodeObject(forKey: "CampaignAchievements") as! [String:Bool]
        isCurrent = aDecoder.decodeBool(forKey: "IsCurrent")
        parties = aDecoder.decodeObject(forKey: "Parties") as? [Party]
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "Title")
        aCoder.encode(isUnlocked, forKey: "IsUnlocked")
        aCoder.encode(requirementsMet, forKey: "RequirementsMet")
        aCoder.encode(isCompleted, forKey: "IsCompleted")
        aCoder.encode(achievements, forKey: "CampaignAchievements")
        aCoder.encode(isCurrent, forKey: "IsCurrent")
        aCoder.encode(parties, forKey: "Parties")
    }
}
