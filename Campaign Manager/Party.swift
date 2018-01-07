//
//  Party.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/14/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Party: NSObject, NSCoding {
    
    var name: String
    var characters: [Character]
    var location: String
    var achievements: [String:Bool]
    var reputation: Int
    var isCurrent: Bool
    var assignedTo: String
    var notes: String
    
    var scenarioLevel: Int {
        get {
            let levels = characters.map { $0.level }
            let avg = levels.reduce(0.0) { $0 + ($1 / Double(levels.count)) }
            let suggestedLevel = ceil(avg/2)
            return Int(suggestedLevel)
        }
    }
    
    init(name: String, characters: [Character], location: String, achievements: [String:Bool], reputation: Int, isCurrent: Bool, assignedTo: String, notes: String) {
        self.name = name
        self.characters = characters
        self.location = location
        self.achievements = achievements
        self.reputation = reputation
        self.isCurrent = isCurrent
        self.assignedTo = assignedTo
        self.notes = notes
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        characters = aDecoder.decodeObject(forKey: "Characters") as! [Character]
        location = aDecoder.decodeObject(forKey: "Location") as! String
        achievements = aDecoder.decodeObject(forKey: "PartyAchievements") as! [String:Bool]
        reputation = aDecoder.decodeInteger(forKey: "Reputation")
        isCurrent = aDecoder.decodeBool(forKey: "IsCurrent")
        assignedTo = aDecoder.decodeObject(forKey: "AssignedTo") as! String
        notes = aDecoder.decodeObject(forKey: "Notes") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(characters, forKey: "Characters")
        aCoder.encode(location, forKey: "Location")
        aCoder.encode(achievements, forKey: "PartyAchievements")
        aCoder.encode(reputation, forKey: "Reputation")
        aCoder.encode(isCurrent, forKey: "IsCurrent")
        aCoder.encode(assignedTo, forKey: "AssignedTo")
        aCoder.encode(notes, forKey: "Notes")
    }
}
