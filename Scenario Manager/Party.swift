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
    var isCurrent: Bool
    var scenarioLevel: Int {
        get {
            let levels = characters.map { $0.level }
            let avg = levels.reduce(0.0) { $0 + ($1 / Double(levels.count)) }
            let suggestedLevel = ceil(avg/2)
            return Int(suggestedLevel)
        }
    }
    
    init(name: String, characters: [Character], location: String, achievements: [String:Bool],isCurrent: Bool) {
        self.name = name
        self.characters = characters
        self.location = location
        self.achievements = achievements
        self.isCurrent = isCurrent
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        characters = aDecoder.decodeObject(forKey: "Characters") as! [Character]
        location = aDecoder.decodeObject(forKey: "Location") as! String
        achievements = aDecoder.decodeObject(forKey: "PartyAchievements") as! [String:Bool]
        isCurrent = aDecoder.decodeBool(forKey: "IsCurrent")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(characters, forKey: "Characters")
        aCoder.encode(location, forKey: "Location")
        aCoder.encode(achievements, forKey: "PartyAchievements")
        aCoder.encode(isCurrent, forKey: "IsCurrent")
    }
}
