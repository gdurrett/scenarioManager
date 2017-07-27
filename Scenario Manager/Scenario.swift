//
//  Scenario.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 6/28/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Scenario: NSObject, NSCoding {
    
    var achieves = [String]()
    var available = false
    var completed = false
    var number = "0"
    var requirementsMet = false
    var requirements = [String: Bool]()
    var rewards = [String]()
    var title = ""
    var isUnlocked = false
    var unlockedBy = [String]()
    var unlocks = [String]()
 
//    override init() {
//        super.init()
//    }

    init(number: String, title: String, completed: Bool, requirementsMet: Bool, requirements: [String: Bool], isUnlocked: Bool, unlockedBy: [String], unlocks: [String], achieves: [String], rewards: [String]) {
//    override init() {
        self.number = number
        self.title = title
        self.completed = completed
        self.isUnlocked = isUnlocked
        self.requirementsMet = requirementsMet
        self.requirements = requirements
        self.unlockedBy = unlockedBy
        self.unlocks = unlocks
        self.achieves = achieves
        self.rewards = rewards
    }
    
    // Must implement in order to allow Scenarios to be loaded
    required init?(coder aDecoder: NSCoder) {
        number = aDecoder.decodeObject(forKey: "Number") as! String
        title = aDecoder.decodeObject(forKey: "Title") as! String
        //available = aDecoder.decodeBool(forKey: "Available")
        completed = aDecoder.decodeBool(forKey: "Completed")
        isUnlocked = aDecoder.decodeBool(forKey: "IsUnlocked")
        requirementsMet = aDecoder.decodeBool(forKey: "RequirementsMet")
        requirements = aDecoder.decodeObject(forKey: "Requirements") as! [String: Bool  ]
        unlockedBy = aDecoder.decodeObject(forKey: "UnlockedBy") as! [String]
        unlocks = aDecoder.decodeObject(forKey: "Unlocks") as! [String]
        achieves = aDecoder.decodeObject(forKey: "Achieves") as! [String]
        rewards = aDecoder.decodeObject(forKey: "Rewards") as! [String]
        
        super.init()
    }
    
    // Must implement in order to allow Scenarios to be saved
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "Number")
        aCoder.encode(title, forKey: "Title")
        //aCoder.encode(available, forKey: "Available")
        aCoder.encode(completed, forKey: "Completed")
        aCoder.encode(requirementsMet, forKey: "RequirementsMet")
        aCoder.encode(requirements, forKey: "Requirements")
        aCoder.encode(isUnlocked, forKey: "IsUnlocked")
        aCoder.encode(unlockedBy, forKey: "UnlockedBy")
        aCoder.encode(unlocks, forKey: "Unlocks")
        aCoder.encode(achieves, forKey: "Achieves")
        aCoder.encode(rewards, forKey: "Rewards")
    }
}
