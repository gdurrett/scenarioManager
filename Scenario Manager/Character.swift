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
    var goal: String
    var type: String
    var level: Double
    var isActive: Bool
    var isRetired: Bool
    var assignedTo: String?
    var playedScenarios: [String]?
    
    init(name: String, goal: String, type: String, level: Double, isActive: Bool, isRetired: Bool, assignedTo: String, playedScenarios: [String]) {
        self.name = name
        self.goal = goal
        self.type = type
        self.level = level
        self.isActive = isActive
        self.isRetired = isRetired
        self.assignedTo = assignedTo
        self.playedScenarios = playedScenarios
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        goal = aDecoder.decodeObject(forKey: "Goal") as! String
        type = aDecoder.decodeObject(forKey: "Type") as! String
        level = aDecoder.decodeDouble(forKey: "Level")
        isActive = aDecoder.decodeBool(forKey: "IsActive")
        isRetired = aDecoder.decodeBool(forKey: "IsRetired")
        assignedTo = aDecoder.decodeObject(forKey: "AssignedTo") as? String
        playedScenarios = aDecoder.decodeObject(forKey: "PlayedScenarios") as? [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(goal, forKey: "Goal")
        aCoder.encode(type, forKey: "Type")
        aCoder.encode(level, forKey: "Level")
        aCoder.encode(isActive, forKey: "IsActive")
        aCoder.encode(isRetired, forKey: "IsRetired")
        aCoder.encode(assignedTo, forKey: "AssignedTo")
        aCoder.encode(playedScenarios, forKey: "PlayedScenarios")
    }
}
