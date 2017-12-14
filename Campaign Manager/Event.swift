//
//  Event.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/8/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class Event: NSObject, NSCoding {
    
    enum eventType: String {
        case road
        case city
    }

    var type: eventType
    var number: String
    var choice: String  // A or B
    var unlocks: String
    var isAvailable: Bool
    var isCompleted: Bool
    
    init(type: eventType, number: String, choice: String, unlocks: String, isAvailable: Bool, isCompleted: Bool) {
        self.type = type
        self.number = number
        self.choice = choice
        self.unlocks = unlocks
        self.isAvailable = isAvailable
        self.isCompleted = isCompleted
    }
    required init?(coder aDecoder: NSCoder) {
        type = eventType(rawValue: (aDecoder.decodeObject(forKey: "Type") as! String))!
        number = aDecoder.decodeObject(forKey: "Number") as! String
        choice = aDecoder.decodeObject(forKey: "Choice") as! String
        unlocks = aDecoder.decodeObject(forKey: "Unlocks") as! String
        isAvailable = aDecoder.decodeBool(forKey: "IsAvailable")
        isCompleted = aDecoder.decodeBool(forKey: "IsCompleted")
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type.rawValue, forKey: "Type")
        aCoder.encode(number, forKey: "Number")
        aCoder.encode(choice, forKey: "Choice")
        aCoder.encode(unlocks, forKey: "Unlocks")
        aCoder.encode(isAvailable, forKey: "IsAvailable")
        aCoder.encode(isCompleted, forKey: "IsCompleted")
    }
}
