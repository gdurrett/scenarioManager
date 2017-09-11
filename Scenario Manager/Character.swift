//
//  Character.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Character: NSObject, NSCoding {
    
    var name: String
    var race: String
    var type: String
    var level: Int32
    var isRetired: Bool
    
    init(name: String, race: String, type: String, level: Int32, isRetired: Bool) {
        self.name = name
        self.race = race
        self.type = type
        self.level = level
        self.isRetired = isRetired
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        race = aDecoder.decodeObject(forKey: "Race") as! String
        type = aDecoder.decodeObject(forKey: "Type") as! String
        level = aDecoder.decodeInt32(forKey: "Level")
        isRetired = aDecoder.decodeBool(forKey: "IsRetired")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(race, forKey: "Race")
        aCoder.encode(type, forKey: "Type")
        aCoder.encode(level, forKey: "Level")
        aCoder.encode(isRetired, forKey: "IsRetired")
    }
}
