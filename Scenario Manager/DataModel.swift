//
//  DataModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class DataModel {
    
    // Try singleton
    static var sharedInstance = DataModel()
    
    var allScenarios = [Scenario]()
    var achievements = [ String : Bool ]()
    var availableScenarios = [Scenario]()
    var completedScenarios = [Scenario]()
    var requirementsMet = false
    var myAchieves = [String]()
    var or = false
    var unlocksLabel = String()
    var selectedScenario: Scenario?

    
    let defaultUnlocks = [ "13" : ["ONEOF", "15", "17", "20"] ]
    
    private init() {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("Scenarios.plist")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!){
            loadScenarios()
            availableScenarios = allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true && $0.completed == false }
            completedScenarios = allScenarios.filter { $0.completed == true }
            
        } else {
            
            let row0Scenario = Scenario(number: "1", title: "The Black Barrow", completed: false, requirementsMet: true, requirements: ["None": true], isUnlocked: true, unlockedBy: ["None"], unlocks: ["2"], achieves: ["First Steps"], rewards: ["None"])
            allScenarios.append(row0Scenario)
            
            let row1Scenario = Scenario(number: "2", title: "Barrow Lair", completed: false, requirementsMet: false, requirements: ["First Steps": true], isUnlocked: false, unlockedBy: ["1"], unlocks: ["3", "4"], achieves: ["None"], rewards: ["10 Gold Each", "+1 Prosperity"])
            allScenarios.append(row1Scenario)

            let row2Scenario = Scenario(number: "3", title: "Inox Encampment", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": false], isUnlocked: false, unlockedBy: ["2"], unlocks: ["8", "9"], achieves: ["Jekserah's Plans"], rewards: ["15 Gold Each", "+1 Prosperity"])
            allScenarios.append(row2Scenario)

            let row3Scenario = Scenario(number: "4", title: "Crypt of the Damned", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["2"], unlocks: ["5", "6"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row3Scenario)

            let row4Scenario = Scenario(number: "5", title: "Ruinous Crypt", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["4"], unlocks: ["10", "14", "19"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row4Scenario)

            let row5Scenario = Scenario(number: "6", title: "Decaying Crypt", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["4"], unlocks: ["8"], achieves: ["Jekserah's Plans", "Dark Bounty"], rewards: ["5 Gold Each"])
            allScenarios.append(row5Scenario)

            let row6Scenario = Scenario(number: "7", title: "Vibrant Grotto", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement": true, "The Merchant Flees": true], isUnlocked: false, unlockedBy: ["8"], unlocks: ["20"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row6Scenario)

            let row7Scenario = Scenario(number: "8", title: "Gloomhaven Warehouse", completed: false, requirementsMet: false, requirements: ["Jekserah's Plans": true, "The Dead Invade": false], isUnlocked: false, unlockedBy: ["3", "6"], unlocks: ["7", "13", "14"], achieves: ["The Merchant Flees"], rewards: ["+2 Reputation"])
            allScenarios.append(row7Scenario)

            let row8Scenario = Scenario(number: "9", title: "Diamond Mine", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": false], isUnlocked: false, unlockedBy: ["3"], unlocks: ["11", "12"], achieves: ["The Dead Invade"], rewards: ["20 Gold Each", "+1 Prosperity"])
            allScenarios.append(row8Scenario)

            let row9Scenario = Scenario(number: "10", title: "Plane of Elemental Power", completed: false, requirementsMet: false, requirements: ["The Rift Closed": false], isUnlocked: false, unlockedBy: ["5"], unlocks: ["21", "22"], achieves: ["A Demon's Errand"], rewards: ["None"])
            allScenarios.append(row9Scenario)

            let row10Scenario = Scenario(number: "11", title: "Gloomhaven Square A", completed: false, requirementsMet: false, requirements: ["End of the Invasion": false], isUnlocked: false, unlockedBy: ["9"], unlocks: ["16", "18"], achieves: ["End of the Invasion"], rewards: ["15 Gold Each", "-2 Reputation", "+2 Prosperity"])
            allScenarios.append(row10Scenario)

            let row11Scenario = Scenario(number: "12", title: "Gloomhaven Square B", completed: false, requirementsMet: false, requirements: ["End of the Invasion": false], isUnlocked: false, unlockedBy: ["9"], unlocks: ["16", "18", "28"], achieves: ["End of the Invasion"], rewards: ["+4 Reputation"])
            allScenarios.append(row11Scenario)

            let row12Scenario = Scenario(number: "13", title: "Temple of the Seer", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["8"], unlocks: ["ONEOF", "15", "17", "20"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row12Scenario)

            let row13Scenario = Scenario(number: "14", title: "Frozen Hollow", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["8", "18"], unlocks: ["None"], achieves: ["The Power of Enhancement"], rewards: ["None"])
            allScenarios.append(row13Scenario)

            let row14Scenario = Scenario(number: "15", title: "Shrine of Strength", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13"], unlocks: ["None"], achieves: ["None"], rewards: ["20 XP Each"])
            allScenarios.append(row14Scenario)

            let row15Scenario = Scenario(number: "16", title: "Mountain Pass", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13", "20"], unlocks: ["24", "25"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row15Scenario)
            
            let row16Scenario = Scenario(number: "17", title: "Lost Island", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13"], unlocks: ["None"], achieves: ["None"], rewards: ["25 Gold Each"])
            allScenarios.append(row16Scenario)
            
            let row17Scenario = Scenario(number: "18", title: "Abandoned Sewers", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["11", "12", "20"], unlocks: ["14", "23", "26", "43"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row17Scenario)
            
            let row18Scenario = Scenario(number: "19", title: "Forgotten Crypt", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement": true], isUnlocked: false, unlockedBy: ["5"], unlocks: ["27"], achieves: ["Stonebreaker's Censer"], rewards: ["+1 Prosperity"])
            allScenarios.append(row18Scenario)
            
            let row19Scenario = Scenario(number: "20", title: "Necromancer's Sanctum", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": true], isUnlocked: false, unlockedBy: ["7", "13"], unlocks: ["16", "18", "28"], achieves: ["Stonebreaker's Censer"], rewards: ["+1 Prosperity"])
            allScenarios.append(row19Scenario)
            
            let row20Scenario = Scenario(number: "21", title: "Infernal Throne", completed: false, requirementsMet: false, requirements: ["The Rift Closed": false], isUnlocked: false, unlockedBy: ["10"], unlocks: ["None"], achieves: ["The Demon Dethroned"], rewards: ["50 Gold Each", "+1 Prosperity", "Add City Event 78"])
            allScenarios.append(row20Scenario)
            
            let row21Scenario = Scenario(number: "22", title: "Temple of the Elements", completed: false, requirementsMet: false, requirements: ["OR" : true, "A Demon's Errand" : true, "Following Clues" : true], isUnlocked: false, unlockedBy: ["10"], unlocks: ["31", "35", "36"], achieves: ["Artifact: Recovered"], rewards: ["None"])
            allScenarios.append(row21Scenario)
            
            let row22Scenario = Scenario(number: "23", title: "Deep Ruins", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["None"], achieves: ["Through the Ruins", "Ancient Technology"], rewards: ["None"])
            allScenarios.append(row22Scenario)
            
            let row23Scenario = Scenario(number: "24", title: "Echo Chamber", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["16"], unlocks: ["30", "32"], achieves: ["The Voice's Command"], rewards: ["None"])
            allScenarios.append(row23Scenario)
            
            let row24Scenario = Scenario(number: "25", title: "Icecrag Ascent", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["16"], unlocks: ["33", "34"], achieves: ["The Drake's Command"], rewards: ["None"])
            allScenarios.append(row24Scenario)
            
            let row25Scenario = Scenario(number: "26", title: "Ancient Cistern", completed: false, requirementsMet: false, requirements: ["OR" : true, "Water Breathing" : true, "Through the Ruins" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["22"], achieves: ["Following Clues"], rewards: ["10 Gold Each", "+1 Reputation", "+2 Prosperity"])
            allScenarios.append(row25Scenario)
            
            let row26Scenario = Scenario(number: "27", title: "Ruinous Rift", completed: false, requirementsMet: false, requirements: ["Artifact: Lost" : false, "Stonebreaker's Censer" : true], isUnlocked: false, unlockedBy: ["19"], unlocks: ["22"], achieves: ["The Rift Closed"], rewards: ["100 Gold Each (spend on enhancements)"])
            allScenarios.append(row26Scenario)
            
            let row27Scenario = Scenario(number: "28", title: "Outer Ritual Chamber", completed: false, requirementsMet: false, requirements: ["Dark Bounty" : true], isUnlocked: false, unlockedBy: ["20"], unlocks: ["29"], achieves: ["An Invitation"], rewards: ["None"])
            allScenarios.append(row27Scenario)
            
            let row28Scenario = Scenario(number: "29", title: "Sanctuary of Gloom", completed: false, requirementsMet: false, requirements: ["An Invitation" : true], isUnlocked: false, unlockedBy: ["28"], unlocks: ["29"], achieves: ["The Edge of Darkness"], rewards: ["15 XP Each"])
            allScenarios.append(row28Scenario)
            
            let row29Scenario = Scenario(number: "30", title: "Shrine of the Depths", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["30"], unlocks: ["42"], achieves: ["The Scepter and the Voice"], rewards: ["10 Gold Each"])
            allScenarios.append(row29Scenario)
            
            let row30Scenario = Scenario(number: "31", title: "Plane of Night", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement" : true, "Artifact: Recovered" : true], isUnlocked: false, unlockedBy: ["22"], unlocks: ["37", "38", "39", "43"], achieves: ["Artifact: Cleansed"], rewards: ["None"])
            allScenarios.append(row30Scenario)
            
            let row31Scenario = Scenario(number: "32", title: "Decrepit Wood", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["24"], unlocks: ["33", "40"], achieves: ["None"], rewards: ["None"])
            allScenarios.append(row31Scenario)
            
            let row32Scenario = Scenario(number: "33", title: "Savvas Armory", completed: false, requirementsMet: false, requirements: ["OR" : true, "The Voice's Command" : true, "The Drake's Command" : true], isUnlocked: false, unlockedBy: ["25"], unlocks: ["None"], achieves: ["The Voice's Treasure", "The Drake's Treasure"], rewards: ["None"])
            allScenarios.append(row32Scenario)
            
            let row33Scenario = Scenario(number: "34", title: "Scorched Summit", completed: false, requirementsMet: false, requirements: ["The Drake's Command" : true], isUnlocked: false, unlockedBy: ["25"], unlocks: ["None"], achieves: ["The Drake Slain"], rewards: ["20 Gold Each", "+2 Reputation", "+1 Prosperity"])
            allScenarios.append(row33Scenario)
            
            let row34Scenario = Scenario(number: "35", title: "Gloomhaven Battlements A", completed: false, requirementsMet: false, requirements: ["A Demon's Errand" : true, "The Demon Dethroned" : false], isUnlocked: false, unlockedBy: ["22"], unlocks: ["45"], achieves: ["REMOVE", "A Demon's Errand", "City Rule: Demonic", "Artifact: Lost"], rewards: ["30 Gold Each", "-5 Reputation", "-2 Prosperity", "Add City Event 79"])
            allScenarios.append(row34Scenario)
            
            let row35Scenario = Scenario(number: "36", title: "Gloomhaven Battlements B", completed: false, requirementsMet: false, requirements: ["A Demon's Errand" : true, "The Demon Dethroned" : false], isUnlocked: false, unlockedBy: ["22"], unlocks: ["None"], achieves: ["REMOVE", "A Demon's Errand", "The Demon Dethroned"], rewards: ["10 Gold Each", "+4 Reputation", "Add City Event 78"])
            allScenarios.append(row35Scenario)
            
            let row36Scenario = Scenario(number: "37", title: "Doom Trench", completed: false, requirementsMet: false, requirements: ["Water Breathing" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["47"], achieves: ["Through the Trench"], rewards: ["None"])
            allScenarios.append(row36Scenario)
            
            let row37Scenario = Scenario(number: "38", title: "Slave Pens", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["44", "48"], achieves: ["Redthorn's Aid"], rewards: ["+1 Reputation"])
            allScenarios.append(row37Scenario)
            
            let row38Scenario = Scenario(number: "39", title: "Treacherous Divide", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["15", "46"], achieves: ["Across the Divide"], rewards: ["10XP Each"])
            allScenarios.append(row38Scenario)
            
            let row39Scenario = Scenario(number: "40", title: "Ancient Defense Network", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true, "The Voice's Treasure": true], isUnlocked: false, unlockedBy: ["32"], unlocks: ["41"], achieves: ["Ancient Technology"], rewards: ["None"])
            allScenarios.append(row39Scenario)
            
            let row40Scenario = Scenario(number: "41", title: "Timeworn Tomb", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["40"], unlocks: ["None"], achieves: ["The Voice Freed"], rewards: ["50 Gold Each", "25XP Each", "2 ✔️ Each", "+2 Prosperity"])
            allScenarios.append(row40Scenario)
            
            let row41Scenario = Scenario(number: "42", title: "Realm of the Voice", completed: false, requirementsMet: false, requirements: ["The Scepter and the Voice" : true], isUnlocked: false, unlockedBy: ["30"], unlocks: ["None"], achieves: ["REMOVE", "The Voice's Command"], rewards: ["None"])
            allScenarios.append(row41Scenario)
            
            let row42Scenario = Scenario(number: "43", title: "Drake Nest", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["None"], achieves: ["Water Breathing"], rewards: ["None"])
            allScenarios.append(row42Scenario)
            
            let row43Scenario = Scenario(number: "44", title: "Tribal Assault", completed: false, requirementsMet: false, requirements: ["Redthorn's Aid" : true], isUnlocked: false, unlockedBy: ["38"], unlocks: ["None"], achieves: ["None"], rewards: ["Open Spiky-Head Envelope", "+2 Reputation"])
            allScenarios.append(row43Scenario)
            
            let row44Scenario = Scenario(number: "45", title: "Rebel Swamp", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["35"], unlocks: ["49", "50"], achieves: ["None"], rewards: ["20 Gold Each", "-2 Reputation"])
            allScenarios.append(row44Scenario)
            
            let row45Scenario = Scenario(number: "46", title: "Nightmare Peak", completed: false, requirementsMet: false, requirements: ["Across the Divide" : true], isUnlocked: false, unlockedBy: ["39"], unlocks: ["51"], achieves: ["End of Corruption 1"], rewards: ["None"])
            allScenarios.append(row45Scenario)
            
            let row46Scenario = Scenario(number: "47", title: "Lair of the Unseeing Eye", completed: false, requirementsMet: false, requirements: ["Through the Trench" : true], isUnlocked: false, unlockedBy: ["37"], unlocks: ["51"], achieves: ["End of Corruption 2"], rewards: ["None"])
            allScenarios.append(row46Scenario)
            
            let row47Scenario = Scenario(number: "48", title: "Shadow Weald", completed: false, requirementsMet: false, requirements: ["Redthorn's Aid" : true], isUnlocked: false, unlockedBy: ["38"], unlocks: ["51"], achieves: ["End of Corruption 3"], rewards: ["None"])
            allScenarios.append(row47Scenario)
            
            let row48Scenario = Scenario(number: "49", title: "Rebel's Stand", completed: false, requirementsMet: false, requirements: ["City Rule: Demonic" : true], isUnlocked: false, unlockedBy: ["45"], unlocks: ["None"], achieves: ["Annihilation of Order"], rewards: ["50 Gold Each", "-3 Reputation"])
            allScenarios.append(row48Scenario)
            
            let row49Scenario = Scenario(number: "50", title: "Ghost Fortress", completed: false, requirementsMet: false, requirements: ["City Rule: Demonic" : true, "Annihilation of Order": false], isUnlocked: false, unlockedBy: ["45"], unlocks: ["None"], achieves: ["City Rule: Militaristic"], rewards: ["+3 Reputation", "-2 Prosperity"])
            allScenarios.append(row49Scenario)
            
            let row50Scenario = Scenario(number: "51", title: "The Void", completed: false, requirementsMet: false, requirements: ["End of Corruption 1" : true, "End of Corruption 2": true, "End of Corruption 3": true], isUnlocked: false, unlockedBy: ["46", "47", "48"], unlocks: ["None"], achieves: ["End of Gloom"], rewards: ["+5 Reputation", "+5 Prosperity", "Add City Event 81", "Add Road Event 69"])
            allScenarios.append(row50Scenario)
            
            //availableScenarios = allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true }
            availableScenarios = allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true && $0.completed == false }
            completedScenarios = allScenarios.filter { $0.completed == true }
            
            achievements = [
                "None"                      :true,
                "First Steps"               : false,
                "Jekserah's Plans"          : false,
                "Dark Bounty"               : false,
                "The Merchant Flees"        : false,
                "The Dead Invade"           : false,
                "A Demon's Errand"          : false,
                "End of the Invasion"       : false,
                "The Power of Enhancement"  : false,
                "Stonebreaker's Censer"     : false,
                "The Demon Dethroned"       : false,
                "Through the Ruins"         : false,
                "The Voice's Command"       : false,
                "The Drake's Command"       : false,
                "Following Clues"           : false,
                "The Rift Closed"           : false,
                "An Invitation"             : false,
                "The Edge of Darkness"      : false,
                "The Scepter and the Voice" : false,
                "Artifact: Cleansed"        : false,
                "Artifact: Lost"            : false,
                "Artifact: Recovered"       : false,
                "The Voice's Treasure"      : false,
                "The Drake's Treasure"      : false,
                "The Drake Slain"           : false,
                "City Rule: Demonic"        : false,
                "Through the Trench"        : false,
                "Redthorn's Aid"            : false,
                "Across the Divide"         : false,
                "The Voice Freed"           : false,
                "Water Breathing"           : false,
                "End of Corruption 1"       : false,
                "End of Corruption 2"       : false,
                "End of Corruption 3"       : false,
                "Annihilation of Order"     : false,
                "City Rule: Militaristic"   : false,
                "End of Gloom"              : false,
                "The Poison's Source"       : false,
                "Through the Nest"          : false,
                "High Sea Escort"           : false,
                "Grave Job"                 : false,
                "Bravery"                   : false,
                "Fish's Aid"                : false,
                "Bad Business"              : false,
                "Tremors"                   : false,
                "Sin-Ra"                    : false,
                "Debt Collection"           : false,
                "A Map to Treasure"         : false,
                "Chosen by picker"          : false,
                "Ancient Technology"        : false,
                "OR"                        : true,
                
                ]
            
            saveScenarios()
        }
        print("Documents folder is \(documentsDirectory())")
        print("Data file path is \(dataFilePath())")
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Scenarios.plist")
    }
    func saveScenarios() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        // this line is different from before
        archiver.encode(allScenarios, forKey: "Scenarios")
        archiver.encode(achievements, forKey: "Achievements")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    func loadScenarios() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            allScenarios = unarchiver.decodeObject(forKey: "Scenarios") as! [Scenario]
            achievements = unarchiver.decodeObject(forKey: "Achievements") as! [ String : Bool ]
            unarchiver.finishDecoding()
        }
    }
    func updateAvailableScenarios(scenario: Scenario, isCompleted: Bool) {
        
        toggleUnlocks(for: scenario, to: isCompleted)
        let completed = allScenarios.filter { $0.completed == true }
        myAchieves = completed.filter { $0.achieves != ["None"] }.flatMap { $0.achieves }
        
        setAchievements(atches: scenario.achieves, toggle: isCompleted)
        setRequirementsMet()
        
        //availableScenarios = allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true }
        availableScenarios = allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true && $0.completed == false }
        completedScenarios = allScenarios.filter { $0.completed }
        
        saveScenarios()
        
    }
    func setAchievements(atches: [String], toggle: Bool) {
        var remove = false
        for ach in atches {
            if ach == "REMOVE" {
                remove = true
                continue
            }
            if toggle {
                if remove {
                    achievements[ach]! = false
                    remove = false
                } else {
                    if !(ach == "None") {
                        achievements[ach]! = true
                    }
                }
            } else {
                if remove {
                    achievements[ach]! = true
                    remove = false
                } else {
                    if !(ach == "None") && !(myAchieves.contains(ach)){
                        achievements[ach]! = false
                    }
                }
            }
        }
    }
    func setRequirementsMet() {
        for scenario in allScenarios {
            let orPresent = scenario.requirements["OR"] == true
            var tempRequirementsArray = scenario.requirements
            tempRequirementsArray.removeValue(forKey: "OR")
            for (ach, bool) in tempRequirementsArray {
                if orPresent {
                    if achievements[ach]! == bool {
                        scenario.requirementsMet = true
                        break
                    }
                } else if achievements[ach]! != bool && !scenario.completed {
                    scenario.requirementsMet = false
                    break
                } else {
                    scenario.requirementsMet = true
                }
            }
        }
    }
    func toggleUnlocks(for scenario: Scenario, to: Bool) {
        // Don't toggle false if we're already unlocked by a completed scenario
        if to == false && !didAnotherCompletedScenarioUnlockMe(scenario: scenario) {
            //If we're locking a scenario with "ONEOF", we need to restore default unlocks
            if scenario.unlocks.contains("ONEOF") {
                scenario.unlocks = defaultUnlocks[scenario.number]!
            }
            for scen in scenario.unlocks {
                if scen != "ONEOF" {
                    print("Locking \(scenario.title)")
                    getScenario(scenarioNumber: scen)?.isUnlocked = false
                }
            }
        } else { // Go ahead and toggle true
            for scen in scenario.unlocks {
                getScenario(scenarioNumber: scen)?.isUnlocked = true
            }
        }
    }
    func getScenario(scenarioNumber: String) -> Scenario? {
        
        if scenarioNumber == "None" || scenarioNumber == "ONEOF" {
            return nil
        } else {
            let scenInt = Int(scenarioNumber)!-1
            let scenario = allScenarios[scenInt]
            
            return scenario
        }
    }
    func getUnlocks(for scenario: Scenario) -> [String] {
        var unlocks = [String]()
        let myUnlocks = scenario.unlocks.filter { !$0.contains("ONEOF") }
        for scen in myUnlocks {
            if scen == "None" {
                unlocks.append("None")
            } else {
                unlocks.append((getScenario(scenarioNumber: scen)?.number)!)
            }
        }
        return unlocks
    }
    func getUnlockedBys(for scenario: Scenario) -> [String] {
        var unlockedBys = [String]()
        let myUnlocks = scenario.unlockedBy.filter { !$0.contains("ONEOF") }
        for scen in myUnlocks {
            if scen == "None" {
                unlockedBys.append("None")
            } else {
                unlockedBys.append((getScenario(scenarioNumber: scen)?.number)!)
            }
        }
        return unlockedBys
    }
    func getAchieves(for scenario: Scenario) -> [String] {
        var achieves = [String]()
        for ach in scenario.achieves {
            achieves.append(ach)
        }
        return achieves
    }
    func didAnotherCompletedScenarioUnlockMe(scenario: Scenario) -> Bool {
        // Look at calling scenario's unlocks
        for unlock in scenario.unlocks {
            if !(unlock == "None") && !(unlock == "ONEOF") {
                // For each unlock, look at its unlockers (unlockedBy)
                for unlockedBy in getScenario(scenarioNumber: unlock)!.unlockedBy {
                    if (getScenario(scenarioNumber: unlockedBy)!.number == scenario.number) {
                        continue
                    } else {
                        if getScenario(scenarioNumber: unlockedBy)!.completed {
                            return true
                        } else {
                            return false
                        }
                    }
                }
            }
        }
        return false
    }
    func areAnyUnlocksCompleted(scenario: Scenario) -> Bool {
        for scen in scenario.unlocks {
            if let answer = getScenario(scenarioNumber: scen) {
                if answer.completed {
                    return true
                } else {
                    //return false
                    continue
                }
            }
        }
        return false
    }
    
}

class ScenarioNumberAndTitle {
    
    var number: String?
    var title: String?
    
    func returnTitle (number: String) -> String {
        // Need to address "None" case (e.g. first scenario has no unlocker)
        if let title = DataModel.sharedInstance.getScenario(scenarioNumber: number)?.title {
            return title
        } else {
            title = "None"
            return title!
        }
    }
    init(number: String) {
        self.number = number
        self.title = returnTitle(number: number)
    }
}

class SeparatedStrings {
    
    var rowString: String?
    
    init(rowString: String) {
        self.rowString = rowString
    }
}
